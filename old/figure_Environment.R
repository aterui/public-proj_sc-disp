rm(list = ls(all.names = TRUE))
library(devEMF)

# Start and End dates for each occasion ----
  file <- sapply(c("BHC","CRC","STJ"), function(x)paste0("data/", x, "_Mdate2019-11-13.csv") )
  stJ <- endJ <- maxJ <- minJ <- list(NULL)
  Stream <- c("Indian", "Todd")

  for(k in 1:2){
    ## Null matrix for two streams Indian/Todd
    maxJ[[k]] <- minJ[[k]] <- matrix(nrow = length(file), ncol = 14)
    for(i in 1:length(file)){
      JH <- read.csv(file[i]) # Julian date History for species i
      ## minimum and maximum Julian dates for each occasion, species i and stream k
      minJ[[k]][i,] <- apply(JH[JH$Stream == Stream[k], which(colnames(JH)=="X1"):ncol(JH)], 2, min, na.rm=T)    
      maxJ[[k]][i,] <- apply(JH[JH$Stream == Stream[k], which(colnames(JH)=="X1"):ncol(JH)], 2, max, na.rm=T)
    }
    stJ[[k]] <- apply(minJ[[k]], 2, min) # minimum across species
    endJ[[k]] <- apply(maxJ[[k]], 2, max) # maximum across species
  }
  stJ_Indian <- stJ[[1]]; stJ_Todd <- stJ[[2]]
  endJ_Indian <- endJ[[1]]; endJ_Todd <- endJ[[2]]
  
  ## row: occasion, column: start and end date for each occasion
  IntIndian <- cbind(stJ_Indian[1:length(stJ_Indian)-1],
                     stJ_Indian[2:length(stJ_Indian)])
  IntTodd <- cbind(stJ_Todd[1:length(stJ_Todd)-1],
                   stJ_Todd[2:length(stJ_Todd)])
  
  ## Julian date range
  Jrange <- range(c(unlist(stJ), unlist(endJ)))
  
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
  #pdf(file = "figure_WaterLevel.pdf", height = 5, width = 8)  
  emf(file = "figure_WaterLevel.emf", height = 5, width = 8)  
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
  #pdf(file = "figure_WaterTemp.pdf", height = 5, width = 8)  
  emf(file = "figure_WaterTemp.emf", height = 5, width = 8)  
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