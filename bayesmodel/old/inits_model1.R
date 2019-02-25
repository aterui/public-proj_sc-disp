#source("datasort_Todd.R")

n.ad <- 100
n.iter <- 1E+3
n.thin <- max(3, ceiling(n.iter/500))
burn <- ceiling(max(10, n.iter/2))
Sample <- ceiling(n.iter/n.thin)

# data load for JAGS-------------------------------------------------------------------------
Ylist <- list(NULL)
for(j in 1:4){
  X <- NULL
  for(i in (3*j-2):(3*j) ){
    x <- c( (mat[, i+1] - mat[,i] ) )#c(na.omit(mat[,i+1]-mat[,i]))
    X <- c(X, x)
    Ylist[[j]] <- X
  }
}
Y <- c(Ylist[[2]])

#y = rep(NA, length(Y)), lim = cbind(Y-10,Y+10), isCensored = rep(1,length(Y))
Djags <- list(y = Y, N = length(Y), zeros = rep(0,length(Y)) )
para <- c("rate","p")
inits <- replicate(3, list(p = 0.5,rate = c(0.2, 0.01),# y = Y,
                           .RNG.name="base::Wichmann-Hill", .RNG.seed=NA), simplify = FALSE)
for(i in 1:3){ inits[[i]]$.RNG.seed <- i+1 }


library(runjags)
m <- read.jagsfile("bayesmodel/model1.R")
post <- run.jags(m$model, monitor = para, data = Djags,
                 n.chains = 3, inits =inits, method = "parallel",
                 burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                 n.sims = 3)
summary(post)
