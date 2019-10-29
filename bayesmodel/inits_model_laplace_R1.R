# Data preparation ----
  dat_raw <- read.csv("data/data_itg2019-10-24.csv")
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
  Y <- D$Sec_recap*20-10 #Conversion from recapture section ID to distance (m) to the downstream end
  Mu <- D$Sec_cap*20-10 #Conversion from capture section ID to distance (m) to the downstream end
  Yrecap <- D$Yrecap
  ##Explanatory
  Size <- c(scale(D$St_Size) ) # standardized body size
  Stream <- as.numeric(D$Stream) - 1
  Flow <- as.numeric(D$Q99 > 0); FQ <- "Q99" # presence/absence of 99 percentile disturbance
  #Flow <- as.numeric(D$Q90 > 0); FQ <- "Q90" # presence/absence of 90 percentile disturbance
  Temp <- c(scale(D$Temp) ) # standardized water temperature
  ##Control
  Interval <- D$Interval
  DL <- D$DL
  UL <- D$UL
  IND_ID <- as.numeric(factor(D$IND_ID, levels = unique(D$IND_ID)) )

#Run JAGS----
  Djags <- list( Y = Y, Mu = Mu, Yrecap = Yrecap,
                 Nsample = length(Y), DL = DL, UL = UL,
                 Size = Size, Stream = Stream, Flow = Flow, Temp = Temp,
                 log.Int = log(Interval) )
  para <- c("b", "sigma", "mu.phi")
  inits <- replicate(3, list(b = c(3.5, rep(NA, 5)), .RNG.name="base::Wichmann-Hill", .RNG.seed = NA), simplify = FALSE)
  for(i in 1:3){ inits[[i]]$.RNG.seed <- i }
  
  library(runjags)
  m <- read.jagsfile("bayesmodel/model_laplace_R1.R")
  post <- run.jags(m$model, monitor = para, data = Djags,
                   n.chains = 3, inits = inits, method = "parallel",
                   burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                   n.sims = 3, modules = "glm")

# Output ----
  #summary(post)
  source("function_jags2bugs.R")
  re <- jags2bugs(post$mcmc)
  print(re, 2)
  PP <- sapply(1:ncol(re$sims.matrix), function(x) mean(re$sims.matrix[,x]>0) )
  PN <- 1-PP
  write.csv(cbind(re$summary[,c(5,3,7,8,9)], PP, PN), paste0("result/summary_", species, Sys.Date(), FQ,".csv") )
  write.csv(re$sims.matrix, paste0("result/MCMCsample_", species, Sys.Date(), FQ,".csv") )
