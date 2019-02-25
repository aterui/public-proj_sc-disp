source("datasort_Indian.R")
library(MASS)

Y <- y <- lambda <- NULL
for(i in 1:(ncol(mat)-1)){
  x <- na.omit(abs(mat[,i+1]-mat[,i]))
  y <- abs(mat[,i+1]-mat[,i])
  Y <- cbind(Y,y)
  lambda[i] <- fitdistr(x,densfun="exponential")$estimate
}

pdf("Indian.pdf")
plot(Y~size[,1:12], xlab="Body size", ylab="Distance moved (m)",pch=21,col=NA,bg=grey(0,0.25))
dev.off()
#x <- na.omit(c(Y))
#hist(x,breaks=seq(0,500,20))