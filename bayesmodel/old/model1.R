model{
  # --- Dispersal model ---
  ## --- Liklihood ---
  for(i in 1:Nsample){
    Y[i] ~ ddexp(0, theta[i])T(DL[i],UL[i])
    log(theta[i]) <- log.theta[i] + log(20)
    log.theta[i] <-  log.s.theta[Period[i]]
  }
    
  for(t in 1:Nperiod){
    log.s.theta[t] ~ dnorm(log.mu.theta, tau[1])
    s.theta[t] <- exp(log.s.theta[t])
  }
  
  ## --- Prior ---
  log.mu.theta <- log(mu.theta)
  mu.theta ~ dunif(0, 10)
  
  for(n in 1){
    tau[n] <- pow(sigma[n], -2)
    sigma[n] ~ dunif(0, 10)
  }
}