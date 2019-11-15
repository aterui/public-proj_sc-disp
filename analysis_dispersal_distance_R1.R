
SP <- "STJ"

dat <- read.csv("data/data_itg2019-10-24.csv")
dd <- dat[dat$species==SP,]
scl.size <- quantile(scale(dd$St_Size), c(0.2,0.5,0.8), na.rm = T)

est <- read.csv(paste0("result/summary_", SP, "2019-10-31Q99.csv") )
lambda0 <- sapply(scl.size, function(x) 1/exp(est[1,"X50."] + est[3,"X50."]*x) )
lambda1 <- sapply(scl.size, function(x) 1/exp(est[1,"X50."] + est[2,"X50."] + (est[3,"X50."] + est[4,"X50."])*x) )

delta0 <- 1/lambda0
delta1 <- 1/lambda1
var0 <- 2*delta0^2
var1 <- 2*delta1^2

quantile(dd$St_Size, c(0.2,0.5,0.8), na.rm = T)
