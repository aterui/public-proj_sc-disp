model{
  # --- Dispersal model ---
  ## --- Liklihood ---
  for(i in 1:Nsample){
    Y[i] ~ dt(0, mu.theta, df[i])T(DL[i],UL[i])
    df[i] <- s.df[Period[i]]
  }
  
  mu.theta <- pow(mu.sigma,-2)
  mu.sigma ~ dnorm(0, 0.0001)T(0, 100)
  
  for(k in 1:Nperiod){
    s.df[k] ~ dexp(0.01)T(2,)
  }
}