getY_binary <- function(X, start = 1){
  Y <- matrix(ncol = ncol(X), nrow = nrow(X) )
  for( i in start:(ncol(X) - 1) ){
    Y[,i+1] <- ifelse( is.na(X[,i]), NA, ifelse(is.na(X[,i+1]), 0, 1) )
  }
  return(Y)
}