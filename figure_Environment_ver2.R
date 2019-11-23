# Call library ----
  rm(list = ls(all.names = TRUE))
  library(stringr)

# Data ----
  ## Define data source
  d1 <- read.csv("data/Indian_final.csv"); d1 <- d1[,1:which(colnames(d1)=="COMMENTS")]; d1$Stream <- "Indian"
  d2 <- read.csv("data/Todd_final.csv"); d2 <- d2[,1:which(colnames(d2)=="COMMENTS")]; d2$Stream <- "Todd"
  dat <- rbind(d1, d2)

  ## Re-define
  dat$Year <- str_sub(dat$Date, start = 1, end = 4)
  dat$Month <- str_sub(dat$Date, start = 5, end = 6)
  dat$Day <- str_sub(dat$Date, start = 7, end = 8)
  dat$as.date <- as.Date(paste(dat$Year,dat$Month,dat$Day, sep="/"))
  dat$Julian <- julian(dat$as.date)

# Data sort ----
  ## remove 1-2 occasions; these are trial period so inappropriate for analysis
  dat$Occasion <- dat$Occasion - 2
  dat <- dat[dat$Occasion > 0,]
  
  datI <- dat[dat$Stream=="Indian",]
  datT <- dat[dat$Stream=="Todd",]
  stIndian <- tapply(datI$Julian, datI$Occasion, min)
  stTodd <- tapply(datT$Julian, datT$Occasion, min)
  
  ## row: occasion, column: start and end date for each occasion
  IntIndian <- cbind(stIndian[1:(length(stIndian)-1)], stIndian[2:length(stIndian)])
  IntTodd <- cbind(stTodd[1:(length(stTodd)-1)], stTodd[2:length(stTodd)])
  Jrange <- range(dat$Julian, na.rm = T)
  
# Water level and Temperature data ----
  ## Water level
  WL <- read.csv("data/WaterLevel_edit.csv")
  WL <- WL[WL$Jdate >= Jrange[1]&WL$Jdate <= Jrange[2],]
  
  ## Water temperature
  WT <- read.csv("data/WaterTemp.csv"); WT <- WT[is.na(WT$Indian_Temp)==0,]
  WT$Date <- as.Date(WT$Date)
  WT$Jdate <- julian.Date(WT$Date)
  WT <- WT[WT$Jdate >= Jrange[1]&WT$Jdate <= Jrange[2],]
  
# Plot data ----
  ## Water level
  pdf(file = "figure_WaterLevel.pdf", height = 5, width = 8)  
  #emf(file = "figure_WaterLevel.emf", height = 5, width = 8)  
  par(mfrow = c(1, 2), oma = c(2,2,0,0))
    plot(Indian_WL ~ Jdate, data = WL, type = "l", col = grey(0,0.4), ann = F, axes = F)
    axis(1); axis(2, las = 2); box(bty = "l")
    abline(v = c(IntIndian[,1], max(IntIndian)), lty = 3, col = grey(0,0.4) )
    abline(h = quantile(WL$Indian_WL, 0.99), col = rgb(1,0,0,0.4) )  
    mtext("Indian", 3, line = 0.5)
    
    plot(Todd_WL ~ Jdate, data = WL, type = "l", col = grey(0,0.4), bty = "l", ann = F, axes = F)
    axis(1); axis(2, las = 2); box(bty = "l")
    abline(v = c(IntTodd[,1], max(IntTodd)), lty = 3, col = grey(0,0.4) )
    abline(h = quantile(WL$Todd_WL, 0.99), col = rgb(1,0,0,0.4) )  
    mtext("Todd", 3, line = 0.5)
    
    mtext("Julian date", 1, outer = T)
    mtext("Water level (m)", 2, outer = T)
  dev.off()
  
  ## Water temperature
  pdf(file = "figure_WaterTemp.pdf", height = 5, width = 8)  
  #emf(file = "figure_WaterTemp.emf", height = 5, width = 8)  
  par(mfrow = c(1, 2), oma = c(2,2,0,0))
    plot(Indian_Temp ~ Jdate, data = WT, type = "l", col = grey(0,0.4), ann = F, axes = F)
    axis(1); axis(2, las = 2); box(bty = "l")
    abline(v = c(IntIndian[,1], max(IntIndian)), lty = 3, col = grey(0,0.4) )
    mtext("Indian", 3, line = 0.5)
    
    plot(Todd_Temp ~ Jdate, data = WT, type = "l", col = grey(0,0.4), bty = "l", ann = F, axes = F)
    axis(1); axis(2, las = 2); box(bty = "l")
    abline(v = c(IntTodd[,1], max(IntTodd)), lty = 3, col = grey(0,0.4) )
    mtext("Todd", 3, line = 0.5)
    
    mtext("Julian date", 1, outer = T)
    mtext("Water temperature (Celsius)", 2, outer = T)
  dev.off()