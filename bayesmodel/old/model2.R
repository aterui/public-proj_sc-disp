model{
  # --- Observation model ---
  for(i in 1:Nsample){
    Yrecap[i] ~ dbern(p[i])
    p[i] <- z[i]*phi
    
    z[i] ~ dbern(psi[i])
    psi[i] <- pdexp(UL[i], 0, s.theta[Period[i]]) - pdexp(DL[i], 0, s.theta[Period[i]])
  }
  phi ~ dunif(0,1)
  
  # --- Dispersal model ---
  ## --- Liklihood ---
  for(i in 1:Nsample){
    Y[i] ~ ddexp(0, theta[i])
    log(theta[i]) <- log.theta[i]
    log.theta[i] <-  log.s.theta[Period[i]]
  }
  
  for(k in 1:Nperiod){
    log.s.theta[k] ~ dnorm(log.mu.theta, tau[1])
    s.theta[k] <- exp(log.s.theta[k])
  }
  
  ## --- Prior ---
  log.mu.theta <- log(mu.theta)
  mu.theta ~ dunif(0, 10)
  
  for(n in 1:2){
    tau[n] <- pow(sigma[n], -2)
    sigma[n] ~ dunif(0, 10)
  }
}