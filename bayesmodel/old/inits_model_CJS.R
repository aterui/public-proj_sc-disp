# Data preparation ----
  rm(list = ls(all.names = TRUE))
  species <- "CRC"
  
  ## Capture-recapture data
  file1 <- paste0("data/Vector_", species, "2019-11-14.csv")
  dat <- read.csv(file1) # Capture History

  ## Environmental data
  QF99 <- read.csv("data/Env_QF99_2019-11-14.csv")
  Q99 <- as.matrix(QF99[,c("QF99_Indian", "QF99_Todd")] > 0)
  Temp_mu <- read.csv("data/Env_Temp_mu_2019-11-14.csv")
  
# MCMC setting  
  n.ad <- 100
  n.iter <- 5E+2
  n.thin <- max(3, ceiling(n.iter/500))
  burn <- ceiling(max(10, n.iter/2))
  Sample <- ceiling(n.iter/n.thin)

# Data for JAGS ----
  ##Response
  Y <- dat$Y
  Z <- ifelse(Y==0, NA, 1)
  X <- dat$Section*20 - 10
  JD <- dat$Julian
  ObsF <- tapply(dat$Occasion, dat$IND_ID, min)
  
  Str <- tapply(dat$Stream, dat$IND_ID, function(x) ifelse(unique(x)=="Indian", 1, 2) )
  Size <- tapply(dat$Size, dat$IND_ID, mean, na.rm = T)
  Flow <- t(apply(Q99, 2, as.numeric) )
  Temp <- t(as.matrix(Temp_mu[,c("Temp_mu_Indian", "Temp_mu_Todd")]) )

  Ns <- length(Y)
  Nind <- length(unique(dat$IND_ID) )
  Nt <- length(unique(dat$Occasion) )
  UL <- tapply(dat$Stream, dat$IND_ID, function(x)ifelse(unique(x)=="Indian", 740, 520) )
    
  log.mu.JD <- tapply(dat$Julian, dat$Occasion, function(x)mean(log(x), na.rm = T))
#Run JAGS----
  Djags <- list(X = X, Y = Y, Z = Z, JD = JD,
                ObsF = ObsF, XID = which(is.na(X)==0),
                UL = UL,
                Ns = Ns, Nind = Nind, Nt = Nt,
                IndID = dat$IND_ID, OccID = dat$Occasion,
                Size = Size,
                Str = Str, Flow = Flow, Temp = Temp,
                log.mu.JD = log.mu.JD )
  
  para <- c("a", "b", "mu.phi", "xi", "mu.jd", "log.mu.g", "tau.g")
  inits <- replicate(3, list(a = rep(1,2), b = rep(0,4), mu.phi = rep(0.9, 13),
                             .RNG.name="base::Wichmann-Hill", .RNG.seed = NA), simplify = FALSE)
  for(i in 1:3){ inits[[i]]$.RNG.seed <- i+1 }
  
  library(runjags)
  m <- read.jagsfile("bayesmodel/model_CJS.R")
  post <- run.jags(m$model, monitor = para, data = Djags,
                   n.chains = 3, inits = inits, method = "parallel",
                   burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                   n.sims = 3, modules = "glm")

# Output ----
  source("function_jags2bugs.R")
  re <- jags2bugs(post$mcmc)
  print(re, 2)
