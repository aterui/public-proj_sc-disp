source("datasort_Todd.R")
X <- NULL
msize <- apply(size,1,mean,na.rm=T)
for(i in 2:ncol(Y)){
  x <- Y[,i]-Y[,i-1]; X <- cbind(X,x)
}

plot(0,xlim=range(msize),ylim=range(abs(X),na.rm=T))
for(i in 1:12){
  points(msize,abs(X[,i]))
}