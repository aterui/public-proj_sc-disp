model{
  ninfo <- 0.001
  tau <- pow(sigma,-2); sigma ~ dunif(0,10)
  
  for(j in 1:6){ b[j] ~ dnorm(0, ninfo) }
  d ~ dunif(0,30)
  
  for(i in 1:Nsample){
    x[i] <- step(Dispersal[i] - d)
    
    Y[i] ~ dnorm(mu[i],tau)
    mu[i] <- b[1] + b[2]*Temp[i] + b[3]*Disturb[i] + b[4]*x[i] + b[5]*Disturb[i]*x[i] + b[6]*Stream[i]
  }

}