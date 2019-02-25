model{
  ninfo <- 0.001
  for(k in 1:2){
    beta[k] ~ dnorm(0,ninfo)
  }
  
  mu ~ dnorm(0,0.001)
  tau <- pow(sigma,-2); sigma ~ dnorm(0,0.001)T(0,100)
  
  for(i in 1:N){
    Y[i] ~ ddexp(0,rate[i])
    rate[i] <- 1/delta[i]
    log(delta[i]) <- beta[1]+beta[2]*std.size[i]
    std.size[i] <- (size[i]-mu_size)/sd_size
    size[i] ~ dnorm(mu,tau)T(0,)
  }
}