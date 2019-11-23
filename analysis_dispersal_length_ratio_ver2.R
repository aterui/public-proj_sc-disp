mu <- list(NULL)
L <- c(740,520)
SP <- c("BHC", "CRC", "STJ")
for(i in 1:3){
  est <- read.csv(paste0("result/summary_", SP[i], "2019-10-31Q99.csv") )
  mean <- c(exp(est[est$X=="b[1]", "X50."]),
            exp(est[est$X=="b[1]", "X50."] + est[est$X=="b[6]", "X50."]) )
  mu[[i]] <- L/mean
}

range(unlist(mu))