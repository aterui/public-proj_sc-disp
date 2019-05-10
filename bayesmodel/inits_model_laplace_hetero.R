# Data preparation ----
  dat_raw <- read.csv("data/data_itg2019-03-13.csv")
  dat <- dat_raw[dat_raw$species=="STJ",] # species: "STJ", "BHC", "CRC"
  species <- unique(dat$species)
  D <- dat[is.na(dat$St_Size)==0,]
  
  n.ad <- 100
  n.iter <- 3E+3
  n.thin <- max(3, ceiling(n.iter/500))
  burn <- ceiling(max(10, n.iter/2))
  Sample <- ceiling(n.iter/n.thin)

# Data for JAGS ----
  ##Response
  Y <- D$Y*20 #Conversion from section displacement to meter displacement (D$Y is the number of sections displaced)
  Yrecap <- D$Yrecap
  ##Explanatory
  Size <- c(scale(D$St_Size) ) # standardized body size
  Stream <- as.numeric(D$Stream) - 1
  Disturb <- as.numeric(D$Q99 > 0) # presence/absence of 99 percentile disturbance
  Temp <- c(scale(D$Temp) ) # standardized water temperature
  ##Control
  Interval <- D$Interval
  DL <- c(D$DL*20)
  UL <- c(D$UL*20)

#Run JAGS----
  Djags <- list( Y = Y, Yrecap = Yrecap, Nsample = length(Y), DL = DL, UL = UL,
                 Size = Size, Stream = Stream, Disturb = Disturb, Temp = Temp,
                 Interval = Interval )
  para <- c("b", "sigma", "m.phi", "var.phi")
  inits <- replicate(3, list(b = c(3.5, rep(NA, 4)), .RNG.name="base::Wichmann-Hill", .RNG.seed = NA), simplify = FALSE)
  for(i in 1:3){ inits[[i]]$.RNG.seed <- i }
  
  library(runjags)
  m <- read.jagsfile("bayesmodel/model_laplace_hetero.R")
  post <- run.jags(m$model, monitor = para, data = Djags,
                   n.chains = 3, inits = inits, method = "parallel",
                   burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                   n.sims = 3)

# Output ----
  #summary(post)
  source("function_jags2bugs.R")
  re <- jags2bugs(post$mcmc)
  print(re, 2)
  PP <- sapply(1:ncol(re$sims.matrix), function(x) mean(re$sims.matrix[,x]>0) )
  write.csv(cbind(re$summary[,c(5,3,7,8,9)],PP ), paste0("result/summary_hetero_", species, Sys.Date(),".csv") )
  write.csv(re$sims.matrix, paste0("result/MCMCsample_hetero_", species, Sys.Date(),".csv") )
