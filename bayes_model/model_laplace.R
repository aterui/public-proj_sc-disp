model{
  ninfo <- 0.01

# priors ------------------------------------------------------------------

  ## slope
  for(k in 1:6) {
    b[k] ~ dnorm(0,ninfo)
  }

  ## capture prob.
  for(t in 1:Nt) {
    logit(phi.g[t]) <- logit.phi[t]
    logit.phi[t] ~ dnorm(logit.mu.phi, tau.phi)
  }
  
  logit(mu.phi) <- logit.mu.phi
  logit.mu.phi ~ dnorm(0, ninfo)
  tau.phi ~ dscaled.gamma(2.5, 1)
  sigma.phi <- 1/sqrt(tau.phi)
  
  ## interval
  mu ~ dnorm(0, ninfo)
  tau ~ dscaled.gamma(2.5, 1)
  sigma <- 1/sqrt(tau)

# likelihood --------------------------------------------------------------
  
  for(n in 1:Nsample) {
    ## observation model
    Y[n] ~ dbern(phi[n]*zs[n])
    zs[n] <- step(s[n] - 1.5)
    s[n] <- step(UL[n] - X[n]) + step(X[n])
    phi[n] <- phi.g[Occ[n]]

    ## dispersal model
    X[n] ~ ddexp(Mu[n], theta[n])
    theta[n] <- 1/delta[n]
    log(delta[n]) <- b[1] + 
                     b[2] * Flow[n] + b[3] * scl.Size[n] + b[4] * Flow[n] * scl.Size[n] +
                     b[5] * scl.Temp[n] + b[6] * Stream[n] + log.Int[n] - log(60) 
    log.Int[n] ~ dnorm(mu, tau)
  }

# log likelihood ----------------------------------------------------------
  
  for(n in XID) {
    loglik[n] <- logdensity.dexp(X[n], Mu[n], theta[n])
  }

# prediction --------------------------------------------------------------
  
  # wd: with disturbance, wod: without disturbance
  for(i in 1:100) {
    log(delta_wod[i]) <- b[1] + b[2] * 0 + b[3] * X_length[i] + b[4] * 0 * X_length[i] + b[6] * 0.5   
    log(delta_wd[i]) <- b[1] + b[2] * 1 + b[3] * X_length[i] + b[4] * 1 * X_length[i] + b[6] * 0.5   
  }
  
  log(delta_l20_wod) <- b[1] + b[2] * 0 + b[3] * L20 + b[4] * 0 * L20 + b[6] * 0.5   
  log(delta_l20_wd) <- b[1] + b[2] * 1 + b[3] * L20 + b[4] * 1 * L20 + b[6] * 0.5   

  log(delta_l50_wod) <- b[1] + b[2] * 0 + b[3] * L50 + b[4] * 0 * L50 + b[6] * 0.5   
  log(delta_l50_wd) <- b[1] + b[2] * 1 + b[3] * L50 + b[4] * 1 * L50 + b[6] * 0.5   

  log(delta_l80_wod) <- b[1] + b[2] * 0 + b[3] * L80 + b[4] * 0 * L80 + b[6] * 0.5   
  log(delta_l80_wd) <- b[1] + b[2] * 1 + b[3] * L80 + b[4] * 1 * L80 + b[6] * 0.5   
  
}