model{
  ninfo <- 0.01
  
  # Prior ----
  for(k in 1:2){ a[k] ~ dnorm(0, ninfo) }
  for(k in 1:4){ b[k] ~ dnorm(0, ninfo) }
  
  for(t in 1:(Nt-1)){
    mu.phi[t] ~ dunif(0, 1)
  }
  tau.s ~ dscaled.gamma(2.5, 1)
  
  xi ~ dunif(0, 1)
  tau.jd ~ dscaled.gamma(2.5, 1)
  
  # Likelihood ----
  for(i in 1:Nind){
    for(t in ObsF[i]:(Nt-1) ){
      # CJS model
      ## Observation process
      y[i,t+1] ~ dbern(xi*zs[i,t+1])#*z[i,t+1])
      
      ## State process
      #z[i,t+1] ~ dbern(phi[i,t]*z[i,t])
      #phi[i,t] <- mu.phi[t]
      
      # Dispersal model
      ## zs: indicator variable for stay or not (1 if stay)
      zs[i,t+1] <- step(s[i,t+1] - 1.5)
      s[i,t+1] <- step(UL[i] - x[i,t+1]) + step(x[i,t+1])
      
      x[i,t+1] ~ ddexp(x[i,t], theta[i,t])
      theta[i,t] <- 1/delta[i,t]
      log(delta[i,t]) <-  a[Str[i]] + b[1]*Flow[Str[i],t] + b[2]*Size[i] + b[3]*Flow[Str[i],t]*Size[i] + 
                          b[4]*Temp[Str[i],t] + log(jd[i,t+1]-jd[i,t]) - log(60)
      
      # Growth model
      #log.size[i,t+1] ~ dnorm(log.size[i,t], tau.s)
    }
  }
  
  for(t in 1:Nt){
    for(i in 1:Nind){
      jd[i,t] <- exp(log.jd[i,t])
      log.jd[i,t] ~ dnorm(log.mu.JD[t], tau.jd)
    }
  }
  
}

data{
  for(n in XID){
    x[IndID[n], OccID[n]] <- X[n]
    z[IndID[n], OccID[n]] <- Z[n]
    log.jd[IndID[n], OccID[n]] <- log(JD[n])
  }
  
  for(n in 1:Ns){
    y[IndID[n], OccID[n]] <- Y[n]
  }
}