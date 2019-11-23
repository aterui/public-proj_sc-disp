model{
  ninfo <- 0.01
  
  # Prior ----
  for(k in 1:2){ a[k] ~ dnorm(0, ninfo) }
  for(k in 1:4){ b[k] ~ dnorm(0, ninfo) }
  
  for(t in 1:(Nt-1)){
    mu.phi[t] ~ dunif(0, 1)
  }
  tau.s ~ dscaled.gamma(2.5, 1)
  
  xi ~ dunif(0, 1)
  tau.jd ~ dscaled.gamma(2.5, 1)
  
  # Likelihood ----
  for(n in 1:Ns){
    x[IndID[n],OccID[n]] ~ ddexp(x[IndID[n],OccID[n]-1], )
  }
  
  for(t in 1:Nt){
    for(i in 1:Nind){
      jd[i,t] <- exp(log.jd[i,t])
      log.jd[i,t] ~ dnorm(log.mu.JD[t], tau.jd)
    }
  }
  
}

data{
  for(n in XID){
    x[IndID[n], OccID[n]] <- X[n]
    z[IndID[n], OccID[n]] <- Z[n]
    log.jd[IndID[n], OccID[n]] <- log(JD[n])
  }
  
  for(n in 1:Ns){
    y[IndID[n], OccID[n]] <- Y[n]
  }
}