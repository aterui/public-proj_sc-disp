model{
  # Priors
  ninfo <- 0.001
  for(k in 1:6){ b[k] ~ dnorm(0,ninfo) }
  
  mu ~ dnorm(0,ninfo)
  tau ~ dscaled.gamma(2.5, 1); sigma <- 1/sqrt(tau)
  phi ~ dunif(0,1)

  # Observation model
  for(n in 1:Nsample){
    Yrecap[n] ~ dbern(p[n])
    p[n] <- phi*q[n]
    q[n] <- pdexp(UL[n], Mu[n], theta[n]) - pdexp(DL[n], Mu[n], theta[n])
  }

  # Dispersal model
  for(n in 1:Nsample){
    Y[n] ~ ddexp(Mu[n], theta[n])
    theta[n] <- 1/delta[n]
    log(delta[n]) <- b[1] + b[2]*Flow[n] + b[3]*Size[n] + b[4]*Flow[n]*Size[n] +
                     b[5]*Temp[n] + b[6]*Stream[n] + log.Int[n] - log(60) 
    log.Int[n] ~ dnorm(mu, tau)
  }
  
  # Bayesian p-value
  for(n in 1:Nsample){
    Y.new[n] ~ ddexp(Mu[n], theta[n]) # ideal data
    Y.resid[n] <- Y[n] - delta[n]
    Y.new.resid[n] <- Y.new[n] - delta[n]
    sq.Y.resid[n] <- pow(Y.resid[n], 2)
    sq.Y.new.resid[n] <- pow(Y.new.resid[n], 2)
  }
  
  fit <- sum(sq.Y.resid[]) # summed square for residuals
  fit.new <- sum(sq.Y.new.resid[]) # summed square for new residuals
  bpvalue <- step(fit.new - fit)
}