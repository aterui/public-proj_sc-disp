#D <- read.csv("data/Vdata_Todd_STJ2018-07-16.csv"); species <- "STJ"
D <- read.csv("data/Vdata_Todd_BHC2018-07-16.csv"); species <- "BHC"
#D <- read.csv("data/Vdata_Todd_CRC2018-07-16.csv"); species <- "CRC"
n.ad <- 100
n.iter <- 1E+3
n.thin <- max(3, ceiling(n.iter/500))
burn <- ceiling(max(10, n.iter/2))
Sample <- ceiling(n.iter/n.thin)

# data load for JAGS-------------------------------------------------------------------------
Y <- D$Y
Yrecap <- D$Yrecap
UL <- D$UL
DL <- D$DL
Period <- D$Period

Djags <- list( Y = Y, Yrecap = Yrecap, Nsample = length(Y),
               Period = Period, Nperiod = length( unique(Period) ),
               DL = DL, UL = UL)
para <- c("mu.sigma", "s.df")
inits <- replicate(3, list(.RNG.name="base::Wichmann-Hill", .RNG.seed=NA), simplify = FALSE)
for(i in 1:3){ inits[[i]]$.RNG.seed <- i+3 }

library(runjags)
m <- read.jagsfile("bayesmodel/model3.R")
post <- run.jags(m$model, monitor = para, data = Djags,
                 n.chains = 3, inits = inits, method = "parallel",
                 burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                 n.sims = 3)
source("function_jags2bugs.R")
re <- jags2bugs(post$mcmc)

if( all(re$summary[,"Rhat"] < 1.1) ){
  write.csv(re$summary, paste0("result/Todd", species, Sys.Date(), ".csv") )
}else{
  print("False")
}