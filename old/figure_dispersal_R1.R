# Script for figure 2
# Data and text ----
  source("function_figure.R")
  dat <- read.csv("data/data_itg2019-10-24.csv")
  Panel <- rbind( c("(a)", "(b)", "(c)"),
                  c("(d)", "(e)", "(f)"),
                  c("(g)", "(h)", "(i)") )
  Size <- c("Small", "Median", "Large")
  Species <- c("BHC", "CRC", "STJ")
  xlim <- 350
  
# Plot ----
  pdf("figure_dispersal_R1.pdf", 6, 6)
    par(mfrow = c(3, 3), mar = c(1,2,1,0), oma=c(5,5,2,1))
    for(i in 1:3){
      SP <- Species[i]
      dd <- dat[dat$species==SP,]
      scl.size <- quantile(scale(dd$St_Size), c(0.2,0.5,0.8), na.rm = T)
      unscl.size <- quantile(dd$St_Size, c(0.2,0.5,0.8), na.rm = T)
      
      est <- read.csv(paste0("result/summary_", SP, "2019-10-31Q99.csv") )
      lambda0 <- sapply(scl.size, function(x) 1/exp(est[1,"X50."] + est[3,"X50."]*x + est[6,"X50."]*0.5) )
      lambda1 <- sapply(scl.size, function(x) 1/exp(est[1,"X50."] + est[2,"X50."] + (est[3,"X50."] + est[4,"X50."])*x + est[6,"X50."]*0.5) )
      
      x <- seq(-xlim, xlim, length = 500); Ylim <- 0.025
      for(j in 1:3){
        figure(lambda1 = lambda1[j], lambda0 = lambda0[j],
               xlim = xlim, ylim = Ylim,
               xlab = ifelse(i==3, T, F), ylab = ifelse(j==1, T, F))
        text(x = -10, y = Ylim, adj = 0.5,
             labels = paste0(Panel[i,j]," ", SP, ", ", Size[j], " (", unscl.size[j], " mm)") )
      }
    }  
    mtext(text = "Distance (m)", 1, outer = T, line = 2)
    mtext(text = "Probability density", 2, outer = T, line = 2.5)
  dev.off()
