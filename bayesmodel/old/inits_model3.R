#source("datasort_Todd.R")
source("getfirst.R")
n.ad <- 100
n.iter <- 1E+3
n.thin <- max(3, ceiling(n.iter/500))
burn <- ceiling(max(10, n.iter/2))
Sample <- ceiling(n.iter/n.thin)

# data load for JAGS-------------------------------------------------------------------------
Y <- NULL
for(i in 2:ncol(mat)){ y <- mat[,i]-mat[,i-1]; Y <- cbind(Y,y) }
Y <- Y[,1:10]

Djags <- list(Y = Y, N = nrow(Y), Nt = ncol(Y), size = size[1:nrow(Y),1:ncol(Y)],
              mu_size = mean(size,na.rm=T), sd_size = sd(size,na.rm=T))
para <- c("beta","Beta","sigma.b")
inits <- replicate(3, list(beta = matrix(rep(c(0,0),ncol(Y)),2,ncol(Y)),
                           .RNG.name="base::Wichmann-Hill",
                           .RNG.seed=NA), simplify = FALSE)
for(i in 1:3){ inits[[i]]$.RNG.seed <- i+1 }


library(runjags)
m <- read.jagsfile("bayesmodel/model3.R")
post <- run.jags(m$model, monitor = para, data = Djags,
                 n.chains = 3, inits =inits, method = "parallel",
                 burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                 n.sims = 3)
re <- summary(post)
round(re,2)
