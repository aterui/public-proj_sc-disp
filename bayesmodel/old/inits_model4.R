#source("datasort_Todd.R")
source("getfirst.R")
n.ad <- 100
n.iter <- 3E+3
n.thin <- max(3, ceiling(n.iter/500))
burn <- ceiling(max(10, n.iter/2))
Sample <- ceiling(n.iter/n.thin)

# data load for JAGS-------------------------------------------------------------------------
Ylist <- Slist <- list(NULL)
for(j in 1:4){
  X <- S <- NULL
  for(i in (3*j-2):(3*j)){
    x <- c(na.omit(mat[,i+1]-mat[,i]))
    rm <- na.action(na.omit(mat[,i+1]-mat[,i]))
    X <- c(X,x)
    S <- c(S,size[-rm,i])
    Ylist[[j]] <- X
    Slist[[j]] <- S
  }
}
Y <- c(Ylist[[4]])
TL <- c(Slist[[4]])

Djags <- list(Y = Y, N = length(Y), size = TL,
              mu_size = mean(TL,na.rm=T), sd_size = sd(TL,na.rm=T))
para <- c("beta")
inits <- replicate(3, list(.RNG.name="base::Wichmann-Hill",
                           .RNG.seed=NA), simplify = FALSE)
for(i in 1:3){ inits[[i]]$.RNG.seed <- i+1 }


library(runjags)
m <- read.jagsfile("bayesmodel/model4.R")
post <- run.jags(m$model, monitor = para, data = Djags,
                 n.chains = 3, inits =inits, method = "parallel",
                 burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                 n.sims = 3)
re <- summary(post)
round(re,2)
