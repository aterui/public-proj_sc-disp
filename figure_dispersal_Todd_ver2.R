# Script for figure 2
# Data and text ----
  source("function_figure.R")
  dat <- read.csv("data/VectorData_MERGE2019-11-19.csv")
  Panel <- rbind( c("(a)", "(b)", "(c)"),
                  c("(d)", "(e)", "(f)"),
                  c("(g)", "(h)", "(i)") )
  Size <- c("Small", "Median", "Large")
  Species <- c("BHC", "CRC", "STJ")
  xlim <- 350

# Plot ----
  pdf("figure_dispersal_Todd_ver2.pdf", 6, 6)
  par(mfrow = c(3, 3), mar = c(1,2,1,0), oma=c(5,5,2,1))
  for(i in 1:3){
    # Select species
    SP <- Species[i]
    dd <- dat[dat$Species==SP,]
    
    # Scale body size with mean 0 SD 0.5
    scl.size <- scale(dd$Size1, scale = sd(dd$Size1)*2)
    Q.scl.size <- quantile(scl.size, c(0.2,0.5,0.8), na.rm = T)
    # Unscaled body size
    Q.unscl.size <- quantile(dd$Size1, c(0.2,0.5,0.8), na.rm = T)
    
    # parameters
    est <- read.csv(paste0("result/summary_8000", SP, "2019-11-20Q99.csv") )
    b1 <- est[which(est$X=="b[1]"),"X50."] # Intercept
    b2 <- est[which(est$X=="b[2]"),"X50."] # Flow
    b3 <- est[which(est$X=="b[3]"),"X50."] # Size
    b4 <- est[which(est$X=="b[4]"),"X50."] # Flow*Size
    b6 <- est[which(est$X=="b[6]"),"X50."] # Stream
    
    # rate parameter
    lambda0 <- sapply(Q.scl.size, function(x) 1/exp(b1 + b2*0 + (b3 + b4*0)*x + b6*1) ) # b6*1 Todd
    lambda1 <- sapply(Q.scl.size, function(x) 1/exp(b1 + b2*1 + (b3 + b4*1)*x + b6*1) ) # b6*1 Todd

    x <- seq(-xlim, xlim, length = 500); Ylim <- 0.030
    for(j in 1:3){
      figure(lambda1 = lambda1[j], lambda0 = lambda0[j],
             xlim = xlim, ylim = Ylim,
             xlab = ifelse(i==3, T, F), ylab = ifelse(j==1, T, F))
      text(x = -10, y = Ylim, adj = 0.5,
           labels = paste0(Panel[i,j]," ", SP, ", ", Size[j], " (", Q.unscl.size[j], " mm)") )
    }
  }  
  mtext(text = "Distance (m)", 1, outer = T, line = 2)
  mtext(text = "Probability density", 2, outer = T, line = 2.5)
  dev.off()
