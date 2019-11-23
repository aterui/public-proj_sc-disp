
# Data preparation ----
  rm(list = ls(all.names = TRUE))
  species <- "BHC" #BHC, CRC, STJ

  ## Fish data
  dat_raw <- read.csv("data/VectorData_MERGE2019-11-19.csv")
  dat <- dat_raw[dat_raw$Species == species,]

  ## Environmental data
  QF99 <- read.csv("data/Env_QF99_2019-11-19.csv")
  Q50 <- read.csv("data/Env_Q50_2019-11-19.csv")
  Temp_raw <- read.csv("data/Env_Temp_mu_2019-11-19.csv")
  
  ## unique individual
  length(unique(dat$IND_ID))

# MCMC ----
  n.ad <- 100
  n.iter <- 8E+3
  n.thin <- max(3, ceiling(n.iter/500))
  burn <- ceiling(max(10, n.iter/2))
  Sample <- ceiling(n.iter/n.thin)

# Data for JAGS ----
  ##Response
  Y <- dat$Y
  X <- dat$X2*20 - 10
  Mu <- dat$X1*20 - 10
  
  ##Explanatory
  scl.Size <- (dat$Size1-mean(dat$Size1))/(2*sd(dat$Size1))
  #Flow <- apply(QF99[,c("QF99_Indian", "QF99_Todd")], 2, function(x)ifelse(x > 0, 1, 0) ); FQ <- "Q99"
  Flow <- as.matrix(Q50[,c("Q50_Indian", "Q50_Todd")] ); FQ <- "Q50"; Flow <- (Flow - mean(Flow))/(2*sd(Flow))
  Temp <- as.matrix(Temp_raw[,c("Temp_mu_Indian", "Temp_mu_Todd")])
  scl.Temp <- (Temp - mean(Temp))/(sd(Temp)*2)
  Stream <- ifelse(dat$Stream == "Indian", 0, 1)
  
  ##Control
  Interval <- dat$JD2 - dat$JD1
  UL <- ifelse(dat$Stream == "Indian", 740, 520)
  
  ##Index
  Occ <- dat$Occasion1
  Str <- ifelse(dat$Stream == "Indian", 1, 2)
  XID <- which(is.na(X)==0)
  
  ##Sample size
  Nsample <- length(Y)
  Nt <- length(unique(Occ))

#Run JAGS----
  Djags <- list( Y = Y, X = X, Mu = Mu,
                 Nsample = Nsample, Nt = Nt,
                 UL = UL, scl.Size = scl.Size, Stream = Stream,
                 Flow = Flow, scl.Temp = scl.Temp,
                 log.Int = log(Interval),
                 Str = Str, Occ = Occ, XID = XID )
  
  para <- c("b", "sigma", "mu.phi", "sigma.phi", "mu", "sigma", "loglik")
  inits <- replicate(3, list(b = c(3.5, rep(0.3, 5)), 
                             .RNG.name="base::Wichmann-Hill", .RNG.seed = NA), simplify = FALSE)
  for(i in 1:3){ inits[[i]]$.RNG.seed <- i }
  
  library(runjags)
  m <- read.jagsfile("bayesmodel/model_laplace_ver3.R")
  post <- run.jags(m$model, monitor = para, data = Djags,
                   n.chains = 3, inits = inits, method = "parallel",
                   burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                   n.sims = 3, modules = "glm")
  
# Output ----
  source("function_jags2bugs.R")
  re <- jags2bugs(post$mcmc)
  print(re, 2)
  PP <- sapply(1:ncol(re$sims.matrix), function(x) mean(re$sims.matrix[,x]>0) )
  PN <- 1-PP

# WAIC ----
  library(loo)
  loglik <- sapply(XID, function(i) unlist( post$mcmc[, paste0("loglik[", i, "]") ] ) )
  WAIC <- waic(loglik)
  
# Save output  
  write.csv(cbind(re$summary[,c(1,5,3,7,8,9)], PP, PN), paste0("result/summary_", n.iter, species, Sys.Date(), FQ,".csv") )
  write.csv(re$sims.matrix, paste0("result/MCMCsample_", n.iter, species, Sys.Date(), FQ,".csv") )
  write.csv(WAIC$estimates, paste0("result/WAIC_", n.iter, species, Sys.Date(), FQ,".csv") )
  