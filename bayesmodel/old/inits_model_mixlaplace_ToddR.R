#D <- read.csv("data/Vdata_Todd_STJ2019-01-06.csv"); species <- "STJ"
D <- read.csv("data/Vdata_Indian_STJ2019-01-06.csv"); species <- "STJ"
#D <- read.csv("data/Vdata_Todd_BHC2019-01-06.csv"); species <- "BHC"
#D <- read.csv("data/Vdata_Indian_BHC2019-01-06.csv"); species <- "BHC"

n.ad <- 100
n.iter <- 2E+3
n.thin <- max(3, ceiling(n.iter/500))
burn <- ceiling(max(10, n.iter/2))
Sample <- ceiling(n.iter/n.thin)

# data load for JAGS-------------------------------------------------------------------------
Y <- c(na.omit(D$Y))*20
Cvalue <- cbind(Y-10, Y+10)

Djags <- list( X = rep(1, length(Y)), y = rep(NA, length(Y)),
               Cvalue = Cvalue, Nsample = length(Y), ones = rep(1, length(Y)) )
para <- c("p", "rate")
inits <- replicate(3, list(p = 0.9, rate = c(0.01, 0.005), y = Y,
                           .RNG.name="base::Wichmann-Hill", .RNG.seed=NA), simplify = FALSE)
for(i in 1:3){ inits[[i]]$.RNG.seed <- i+3 }

library(runjags)
m <- read.jagsfile("bayesmodel/model_mixlaplace.R")
post <- run.jags(m$model, monitor = para, data = Djags,
                 n.chains = 3, inits = inits, method = "parallel",
                 burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                 n.sims = 3)
source("function_jags2bugs.R")
re <- jags2bugs(post$mcmc)
print(re,3)