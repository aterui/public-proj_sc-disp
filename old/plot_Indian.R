#D <- read.csv("data/Vdata_Indian_MTS2018-07-18.csv"); species <- "MTS"
#D <- read.csv("data/Vdata_Indian_CRC2018-07-18.csv"); species <- "CRC"
#D <- read.csv("data/Vdata_Indian_BHC2018-07-18.csv"); species <- "BHC"

year <- c( rep(2016, 5), rep(2017, 6), rep(2018,2) )
m <- c(3,5,7,9,11,1,3,5,7,9,11,1,3)

filename <- paste0("figure/Indian", species, ".pdf")
pdf(filename, width = 12, height = 6)
par(mfrow = c(3,6), mar = c(3,3,2,1))
plot(0, type="n", ann = F, axes = F)
for(t in 1:length(unique(D$Period)) ){
  y <- na.omit(D$Y[D$Period == t])
  plot(table(y)/length(y), xlim = c(-max(abs(D$Y), na.rm = T), max(abs(D$Y), na.rm = T)), ann = F, axes = F)
  mtext(paste0(year[t],"-month",m[t]), cex = 0.8)
  legend("topright", legend = paste0("N = ", length(y)), bty = "n" )
  axis(1); axis(2, las = 2); box(bty="l")
}
dev.off()