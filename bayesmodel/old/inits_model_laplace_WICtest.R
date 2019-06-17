# Data preparation ----
  dat_raw <- read.csv("data/data_itg2019-03-29.csv")
  dat <- dat_raw[dat_raw$species=="CRC",] # species: "STJ", "BHC", "CRC"
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
  #Flow <- as.numeric(D$Q99 > 0); flow <- "Q99" # presence/absence of 99 percentile disturbance
  #Flow <- as.numeric(D$Q90 > 0); flow <- "Q90" # presence/absence of 99 percentile disturbance
  Flow <- c(scale(D$flow50) ); flow <- "Q50"
  Temp <- c(scale(D$Temp) ) # standardized water temperature
  ##Control
  Interval <- D$Interval
  DL <- c(D$DL*20)
  UL <- c(D$UL*20)
  
  #Run JAGS----
  Djags <- list( Y = Y, Yrecap = Yrecap, Nsample = length(Y), DL = DL, UL = UL,
                 Size = Size, Stream = Stream, Flow = Flow, Temp = Temp,
                 Interval = Interval )
  para <- c("b", "sigma", "phi", "test", "logLik")
  inits <- replicate(3, list(b = c(3.5, rep(NA, 4)), .RNG.name="base::Wichmann-Hill", .RNG.seed = NA), simplify = FALSE)
  for(i in 1:3){ inits[[i]]$.RNG.seed <- i }
  
  library(runjags)
  m <- read.jagsfile("bayesmodel/model_WAICtest.R")
  post <- run.jags(m$model, monitor = para, data = Djags,
                   n.chains = 3, inits = inits, method = "parallel",
                   burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                   n.sims = 3)

# Output ----
  library(loo)
  source("function_jags2bugs.R")
  re <- jags2bugs(post$mcmc)
  filename <- paste0("result/summary_", species, Sys.Date(), flow, ".csv")
  write.csv(re$summary, filename)
  
  logLik <- sapply(1:length(Y), function(i) unlist(re$sims.matrix[, paste("logLik[", i, "]", sep = "")] ) )
  waic(logLik)
  re$mean$test
  