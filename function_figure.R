ddexp <- function(x, lambda) 0.5*lambda*exp(-lambda*abs(x))

figure <- function(lambda1, lambda0,
                   xlab = T, ylab = T,
                   xlim = 500, ylim = 0.035){
  x <- seq(-xlim, xlim, length = 500)
  
  ##Without disturbance
  den0 <- ddexp(x, lambda0)
  plot(den0 ~ x, type = "n", ann = F, axes = F, xlim = range(x), ylim = c(0, ylim))
  polygon(c(x, rev(x)), c(den0, rep(0, length(x) ) ), col = grey(0, 0.2), border = NA)
  if(xlab == T) axis(1, labels = T) else axis(1, labels = F)
  if(ylab == T) axis(2, las = 2, labels = T) else axis(2, las = 2, labels = F)
  box(bty = "l")
  
  ##With disturbance
  den1 <- ddexp(x, lambda1)
  lines(den1 ~ x, lty = 1, lwd = 1.5)
}

