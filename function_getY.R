getY <- function(X, start = 1){
          Y <- NULL
          for(i in start:(ncol(X)-1) ){
            y <- X[,i+1] - X[,i]
            Y <- cbind(Y,y)
          }
        return(Y)
        }