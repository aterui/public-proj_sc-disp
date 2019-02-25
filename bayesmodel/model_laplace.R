model{
  # Priors
  ninfo <- 0.001
  for(i in 1:5){ b[i] ~ dnorm(0,ninfo) }
  
  mu ~ dnorm(0,ninfo)
  for(i in 1){ tau[i] <- pow(sigma[i],-2); sigma[i] ~ dnorm(0,ninfo)T(0,100) }
  phi ~ dunif(0,1)
  
  # Observation model
  for (i in 1:Nsample){
    Yrecap[i] ~ dbern(p[i])
    p[i] <- phi*q[i]
    q[i] <- pdexp(UL[i], 0, theta[i]) - pdexp(DL[i], 0, theta[i])
  }
  
  # Dispersal model
  for(i in 1:Nsample){
    Y[i] ~ ddexp(0, theta[i])
    theta[i] <- 1/delta[i]
    log(delta[i]) <- b[1] + b[2]*Disturb[i] + b[3]*Size[i] + b[4]*Temp[i] + b[5]*Stream[i]
                          + log(Interval[i]) - log(60)
    Interval[i] ~ dnorm(mu, tau[1])T(0,)
  }
  
}