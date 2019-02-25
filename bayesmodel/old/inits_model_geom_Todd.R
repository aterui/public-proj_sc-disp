D <- read.csv("data/Vdata_Todd_STJ2018-07-17.csv"); species <- "STJ"
#D <- read.csv("data/Vdata_Todd_BHC2018-07-17.csv"); species <- "BHC"

n.ad <- 100
n.iter <- 1E+3
n.thin <- max(3, ceiling(n.iter/500))
burn <- ceiling(max(10, n.iter/2))
Sample <- ceiling(n.iter/n.thin)

# data load for JAGS-------------------------------------------------------------------------
Y <- abs(D$Y)
Yrecap <- D$Yrecap
Period <- D$Period

Djags <- list( Y = Y, Yrecap = Yrecap, Nsample = length(Y),
               Period = Period, Nperiod = length( unique(Period) ),
               DL = DL, UL = UL)
para <- c("p", "rate")
inits <- replicate(3, list(p = rep(0.9,13), alpha = 10, beta = 10, .RNG.name="base::Wichmann-Hill", .RNG.seed=NA), simplify = FALSE)
for(i in 1:3){ inits[[i]]$.RNG.seed <- i+3 }

library(runjags)
m <- read.jagsfile("bayesmodel/model_geom.R")
post <- run.jags(m$model, monitor = para, data = Djags,
                 n.chains = 3, inits = inits, method = "parallel",
                 burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                 n.sims = 3)
source("function_jags2bugs.R")
re <- summary(post)#jags2bugs(post$mcmc)
plot(table(Y)/length(na.omit(Y)))
points(0:16, dgeom(0:16, re[1,"Median"]) )

#if( all(re$summary[,"Rhat"] < 1.1) ){
#  write.csv(re$summary, paste0("result/Todd", species, Sys.Date(), ".csv") )
#}else{
#  print("False")
#}