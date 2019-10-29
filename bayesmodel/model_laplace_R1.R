model{
  # Priors
  ninfo <- 0.001
  for(i in 1:6){ b[i] ~ dnorm(0,ninfo) }
  
  mu ~ dnorm(0,ninfo)
  for(i in 1){ tau[i] ~ dscaled.gamma(2.5, 1); sigma[i] <- 1/sqrt(tau[i]) }
  phi ~ dunif(0,1)
  
  # Observation model
  for (i in 1:Nsample){
    Yrecap[i] ~ dbern(p[i])
    p[i] <- phi*q[i]
    q[i] <- pdexp(UL[i], Mu[i], theta[i]) - pdexp(DL[i], Mu[i], theta[i])
  }

  # Dispersal model
  for(i in 1:Nsample){
    Y[i] ~ ddexp(Mu[i], theta[i])
    theta[i] <- 1/delta[i]
    log(delta[i]) <- b[1] + b[2]*Flow[i] + b[3]*Size[i] + b[4]*Flow[i]*Size[i] +
                     b[5]*Temp[i] + b[6]*Stream[i] + log.Int[i] - log(60) 
    log.Int[i] ~ dnorm(mu, tau[1])
  }
  
}