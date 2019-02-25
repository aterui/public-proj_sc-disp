#source("datasort_Todd.R")
source("getfirst.R")

n.ad <- 100
n.iter <- 1E+3
n.thin <- max(3, ceiling(n.iter/500))
burn <- ceiling(max(10, n.iter/2))
Sample <- ceiling(n.iter/n.thin)

# data load for JAGS-------------------------------------------------------------------------
Y <- mat[1:100,1:13]
Nt <- ncol(Y)
lim <- array(0,dim=c(nrow(Y),ncol(Y),2))
lim[,,1] <- ifelse(is.na(Y)==F,Y-10,lim); lim[,,2] <- ifelse(is.na(Y)==F,Y+10,lim)
isCensored <- ifelse(is.na(Y)==T,NA,1)

Djags <- list(y = matrix(NA,nrow = nrow(Y),ncol = ncol(Y)),
              lim = lim, isCensored = isCensored,
              N = nrow(Y), Nt = Nt, FirstCatch = apply(Y,1,get.first),
              zeros = matrix(0, nrow=nrow(Y), ncol=Nt))
para <- c("rate","p")
inits <- replicate(3, list(mu.p = 0.2, mu.log.delta = c(2,5),
                           y = ifelse(is.na(Y)==T,NA,Y),
                           .RNG.name="base::Wichmann-Hill", .RNG.seed=NA), simplify = FALSE)
for(i in 1:3){ inits[[i]]$.RNG.seed <- i+1 }


library(runjags)
m <- read.jagsfile("bayesmodel/model2.R")
post <- run.jags(m$model, monitor = para, data = Djags,
                 n.chains = 3, inits =inits, method = "parallel",
                 burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                 n.sims = 3)
#summary(post)
