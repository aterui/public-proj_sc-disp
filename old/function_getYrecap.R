getYrecap <- function(X, start = 1){
  Y <- NULL
  for( i in start:(ncol(X) - 1) ){
    y <- ifelse( is.na(X[,i]), NA, ifelse(is.na(X[,i+1]), 0, 1) )
    Y <- cbind(Y, y)
  }
  return(Y)
}