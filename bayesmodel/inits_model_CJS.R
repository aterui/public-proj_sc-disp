# Data preparation ----
  rm(list = ls(all.names = TRUE))
  species <- "CRC"
  
  ## Capture-recapture data
  file1 <- paste0("data/MatrixData/", species, "_Mcap2019-11-13.csv")
  file2 <- paste0("data/MatrixData/", species, "_Msec2019-11-13.csv")
  file3 <- paste0("data/MatrixData/", species, "_Msize2019-11-13.csv")
  file4 <- paste0("data/MatrixData/", species, "_Mdate2019-11-13.csv")
  
  CH <- read.csv(file1) # Capture History
  LH <- read.csv(file2) # Location History
  SH <- read.csv(file3) # Size History
  JH <- read.csv(file4) # Julian date History
  
  ## Environmental data
  QF99 <- read.csv("data/Env_QF99_2019-11-14.csv")
  Q99 <- as.matrix(QF99[,c("QF99_Indian", "QF99_Todd")] > 0)
  Temp_mu <- read.csv("data/Env_Temp_mu_2019-11-14.csv")
  
# MCMC setting  
  n.ad <- 100
  n.iter <- 3E+3
  n.thin <- max(3, ceiling(n.iter/500))
  burn <- ceiling(max(10, n.iter/2))
  Sample <- ceiling(n.iter/n.thin)

# Data for JAGS ----
  ##Response
  X_raw <- as.matrix(LH[,which(colnames(LH)=="X1"):ncol(LH)]) # Section ID
  X <- X_raw*20 - 10 # Section ID to distance data
  Y <- as.matrix(CH[,which(colnames(CH)=="X1"):ncol(CH)])
  J <- as.matrix(JH[,which(colnames(JH)=="X1"):ncol(JH)])
  Interval <- t(apply(J, 1, diff) ); Interval[is.na(Interval)] <- 60
  log.Interval <- log(Interval)
  FH <- apply(Y, 1, function(x) min(which(is.na(x)==0)))
  
  Size <- as.matrix(SH[,which(colnames(SH)=="X1"):ncol(SH)])
  Flow <- t(apply(Q99, 2, as.numeric) )
  Temp <- t(as.matrix(Temp_mu[,c("Temp_mu_Indian", "Temp_mu_Todd")]) )
  Str <- ifelse(CH$Stream == "Indian", 1, 2)
  
#Run JAGS----
  Djags <- list(X = X, Y = Y, FH = FH,
                log.Interval = log.Interval, Nind = nrow(Y), Nt = ncol(Y),
                Str = Str, Flow = Flow, Temp = Temp)
  para <- c("a", "b")
  inits <- replicate(3, list(a = rep(3,2), b = rep(0,3),
                             .RNG.name="base::Wichmann-Hill", .RNG.seed = NA), simplify = FALSE)
  for(i in 1:3){ inits[[i]]$.RNG.seed <- i }
  
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
