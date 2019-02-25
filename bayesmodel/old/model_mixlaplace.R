model{
  # --- constant ---
  C <- 1E+4
  ninfo <- 0.001
  
  # --- Prior ---
  rate[1] ~ dgamma(ninfo,ninfo)
  rate[2] ~ dgamma(ninfo,ninfo)T(0,rate[1])
  p ~ dunif(0, 1)
  
  # --- Likelihood ---
  for(i in 1:Nsample){
    ## ones trick
    ones[i] ~ dbern(psi[i])
    psi[i] <- L[i]/C
    
    ## Likelihood function
    L[i] <- 0.5*( stayer[i] + mover[i] )
    stayer[i] <- (1 - p)*rate[1]*exp( -rate[1]*abs(y[i]) )
    mover[i] <- p*rate[2]*exp( -rate[2]*abs(y[i]) )
    
    ## NA imputation
    X[i] ~ dinterval(y[i], Cvalue[i,])
    y[i] ~ dunif(-10000, 10000)
    #y[i] ~ dnorm(Y[i], 0.01)T(Cvalue[i,1], Cvalue[i,2])
  }
}