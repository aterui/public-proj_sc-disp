# --- Data preparation ---
  source("function_growth.R")
  dat <- read.csv("data/data_itg2019-01-16.csv")
  dat <- dat[dat$species=="STJ",] # species: "STJ", "BHC", "CRC"
  D <- dat[is.na(dat$St_Size)==0,]
  D$growth <- fg(L0 = D$St_Size, L1 = D$End_Size, duration = D$Interval)
  D <- D[is.na(D$growth)==0,]
  
  n.ad <- 100
  n.iter <- 2E+3
  n.thin <- max(3, ceiling(n.iter/500))
  burn <- ceiling(max(10, n.iter/2))
  Sample <- ceiling(n.iter/n.thin)

# --- Data load for JAGS ---
  ##Response
  Y <- D$growth*100 #Transfer from section displacement to meter displacement
  ##Explanatory
  Stream <- as.numeric(D$Stream) - 1
  Disturb <- as.numeric(D$Q99 > 0)
  Temp <- c(scale(D$Temp) )
  Dispersal <- abs(D$Y)
  
  Djags <- list( Y = Y, Nsample = length(Y),
                 Stream = Stream, Disturb = Disturb, Temp = Temp, Dispersal = Dispersal)

  para <- c("b", "sigma", "d")
  inits <- replicate(3, list(.RNG.name="base::Wichmann-Hill", .RNG.seed=NA), simplify = FALSE)
  for(i in 1:3){ inits[[i]]$.RNG.seed <- i }
  
  library(runjags)
  m <- read.jagsfile("bayesmodel/model_growth.R")
  post <- run.jags(m$model, monitor = para, data = Djags,
                   n.chains = 3, inits = inits, method = "parallel",
                   burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                   n.sims = 3)

# --- Output ---  
  #summary(post)
  source("function_jags2bugs.R")
  re <- jags2bugs(post$mcmc)
  print(re, 4)
