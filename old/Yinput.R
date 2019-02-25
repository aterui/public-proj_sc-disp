#source("datasort_Todd.R")
Ylist <- list(NULL)
for(j in 1:4){
  X <- NULL
  for(i in (3*j-2):(3*j)){
    x <- c(na.omit(mat[,i+1]-mat[,i]))
    X <- c(X,x)
    Ylist[[j]] <- X
  }
}
Y <- c(Ylist[[1]])