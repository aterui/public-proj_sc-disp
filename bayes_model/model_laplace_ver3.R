model{
  ninfo <- 0.01

  # Priors ----
  ## Slope
  for(k in 1:6){ b[k] ~ dnorm(0,ninfo) }
  
  ## Capture prob.
  for(t in 1:Nt){
    logit(phi.g[t]) <- logit.phi[t]
    logit.phi[t] ~ dnorm(logit.mu.phi, tau.phi)
  }
  logit(mu.phi) <- logit.mu.phi
  logit.mu.phi ~ dnorm(0, ninfo)
  tau.phi ~ dscaled.gamma(2.5, 1); sigma.phi <- 1/sqrt(tau.phi)
  
  ## Interval
  mu ~ dnorm(0, ninfo)
  tau ~ dscaled.gamma(2.5, 1); sigma <- 1/sqrt(tau)
  
  # Likelihood ----
  for(n in 1:Nsample){
    ## Observation model
    Y[n] ~ dbern(phi[n]*zs[n])
    zs[n] <- step(s[n] - 1.5)
    s[n] <- step(UL[n] - X[n]) + step(X[n])
    phi[n] <- phi.g[Occ[n]]
      
    ## Dispersal model
    X[n] ~ ddexp(Mu[n], theta[n])
    theta[n] <- 1/delta[n]
    log(delta[n]) <- b[1] + 
                     b[2]*Flow[Occ[n],Str[n]] + b[3]*scl.Size[n] + b[4]*Flow[Occ[n],Str[n]]*scl.Size[n] +
                     b[5]*scl.Temp[Occ[n],Str[n]] + b[6]*Stream[n] + log.Int[n] - log(60) 
    log.Int[n] ~ dnorm(mu, tau)
  }
  
  # log likelihood ----
  for(n in XID){ loglik[n] <- logdensity.dexp(X[n], Mu[n], theta[n]) }

}