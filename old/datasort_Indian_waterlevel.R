D <- read.csv("data/waterlevel.csv")
D <- na.omit(D[D$st_occation >= 3, ])
Indian_mean <- exp(tapply(log(D$Indian_WL), D$st_occation, mean))
Indian_CV <- tapply(log(D$Indian_WL), D$st_occation, sd)

y2 <- read.csv("result/IndianBHC2018-07-18.csv")
Y2 <- y2$X50.[1:13]
plot(Y2^-1 ~ Indian_CV, cex = 2)
