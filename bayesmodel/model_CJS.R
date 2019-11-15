model{
  ninfo <- 0.01
  
  # Prior ----
  for(k in 1:2){ a[k] ~ dnorm(0, ninfo) }
  for(k in 1:3){ b[k] ~ dnorm(0, ninfo) }

  # CJS model ----
  
  # Dispersal model ----
  for(i in 1:Nind){
    for(t in FH[i]:(Nt-1) ){
      X[i,t+1] ~ ddexp(X[i,t], theta[i,t])
      theta[i,t] <- 1/delta[i,t]
      log(delta[i,t]) <-  a[Str[i]] + b[1]*Flow[Str[i],t] + b[2]*Size[i,t] + b[3]*Temp[Str[i],t] +
                          log.Interval[i,t] - log(60)
    }
  }

}

