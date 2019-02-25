model{
  # --- constant ---
  C <- 1E+10
  ninfo <- 1E-4
  
  # --- Prior ---
  alpha ~ dunif(0,100)
  beta ~ dunif(0,100)
  
  # --- Likelihood ---
  for(i in 1:Nsample){
    ## zero trick
    zeros[i] ~ dpois(lambda[i])
    lambda[i] <- -log(L[i]) + C
    
    ## Likelihood function
    f[i] <- p[Period[i]]*pow( (1 - p[Period[i]]), z[i])
    g[i] <- p[Period[i]]*pow( (1 - p[Period[i]]), z[i])
    z[i] <- Y[i] - 1
    
    ## NA imputation
    Y[i] ~ dunif(-10000, 10000)
  }
  
  for(j in 1:Nperiod){
    p[j] ~ dbeta(alpha, beta)
    rate[j] <- -(1/20)*log(1 - p[j])
  }
  
}