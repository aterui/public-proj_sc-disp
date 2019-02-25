getG <- function(X, start = 1){
  G <- NULL
  for(i in start:(ncol(X)-1) ){
    g <- log(X[,i+1]) - log(X[,i])
    G <- cbind(G,g)
  }
  return(G)
}