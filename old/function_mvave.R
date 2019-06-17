mvave <- function(x, n){
  for(i in 1:(length(x)-n+1) ){
    y[i] <- mean(x[i:(i+n-1)])
  }
  return(as.numeric(y))
}