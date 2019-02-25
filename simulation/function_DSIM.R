
  nbf <- function(x){ c(2, lapply(2:(length(x) - 1), function(k) c(k - 1, k + 1)), length(x)-1) }
  # N_patch: number of patches
  # R: Resource abundance
  # nbID: patch ID of neighbors
  # rs: Relative selection probability
  
  N_patch <- 100; N_time <- 365
  N_ind <- 1000
  X <- matrix(NA, nrow = N_ind, ncol = N_time)
  X[,1] <- ceiling( runif(N_ind, 0, N_patch) ) # initial location
  nbID <- nbf(1:N_patch)
  
  
  dtb <- rbinom(N_time, 1, 0.01); dtb[1] <- 1
  shape <- 0.05; rate <- 0.01
  for(t in 1:(N_time-1) ){
    if(dtb[t] == 1){
      # RS: relative habitat selection matrix
      R <- rgamma(N_patch, shape = shape, rate = rate) # E(R) = s/r; Var(R) = s/r^2
      e <- lapply(1:N_patch, function(i) mean(R[ nbID[[i]] ])/(R[i] + mean(R[nbID[[i]]]) ) )
      e <- unlist(e)
      rs <- lapply(1:N_patch, function(i) R[ nbID[[i]] ]/sum(R[ nbID[[i]] ]) )
      RS <- matrix(0, N_patch, N_patch)
    }
    
    for(i in 1:N_patch){ RS[i, nbID[[i]]] <- rs[[i]] }
    E <- sapply(X[,t], function(i) rbinom(1, 1, e[i]) )
    x <- sapply(1:N_ind, function(k) sample(1:N_patch, 1, prob = RS[X[k,t],]) )
    X[,t+1] <- X[,t]
    for(k in which(E==1)){ X[k,t+1] <- x[k] }
  }  
  
  Y <- abs(X[,200]-X[,51])  
  x <- 0:max(Y)
  plot(table(Y)/N_ind )
  #lines(dgeom(0:max(Y), prob = mean(Y==0)) ~ x)
  