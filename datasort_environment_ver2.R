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
  
# Flood frequency ----
  ## Read data
  WL <- read.csv("data/WaterLevel_edit.csv")
  WL <- WL[WL$Jdate >= Jrange[1]&WL$Jdate <= Jrange[2],]
  
  ## List
  FLOW_I <- FLOW_T <- list(NULL)
  for(t in 1:nrow(IntIndian)){
    ## Get water level data for each occasion t
    FLOW_I[[t]] <- WL$Indian_WL[which(WL$Jdate >= IntIndian[t,1] & WL$Jdate <= IntIndian[t,2])]
    FLOW_T[[t]] <- WL$Todd_WL[which(WL$Jdate >= IntTodd[t,1] & WL$Jdate <= IntTodd[t,2])]
  }
  
  ## Median flow
  ### Median water level
  Q50_Indian <- unlist(lapply(FLOW_I, median) )
  Q50_Todd <- unlist(lapply(FLOW_T, median) )
  Q50 <- cbind(Q50_Indian, Q50_Todd)
  ### Save data
  write.csv(Q50, paste0("data/Env_Q50_", Sys.Date(), ".csv"))
  
  ## Quntile 99 and its frequency
  ### 99% water level Indian
  Q99I <- quantile(WL$Indian_WL, c(0.99)) 
  Q99T <- quantile(WL$Todd_WL, c(0.99))
  ### Count days exceeding 99% water level
  QF99_Indian <- unlist(lapply(FLOW_I, function(x) sum(x >= Q99I)) )
  QF99_Todd <- unlist(lapply(FLOW_T, function(x) sum(x >= Q99T)) )
  QF99 <- cbind(QF99_Indian, QF99_Todd)
  ### Save data
  write.csv(QF99, paste0("data/Env_QF99_", Sys.Date(), ".csv"))
  
# Water temperature ----
  ## Read data
  WT <- read.csv("data/WaterTemp.csv"); WT <- WT[is.na(WT$Indian_Temp)==0,]
  WT$Date <- as.Date(WT$Date)
  WT$Jdate <- julian.Date(WT$Date)
  WT <- WT[WT$Jdate >= Jrange[1]&WT$Jdate <= Jrange[2],]
  
  ## List
  Temp_I <- Temp_T <- list(NULL)
  for(t in 1:nrow(IntIndian)){
    ### Get temperature data for each occasion t
    Temp_I[[t]] <- WT$Indian_Temp[which(WT$Jdate >= IntIndian[t,1] & WT$Jdate <= IntIndian[t,2])]
    Temp_T[[t]] <- WT$Todd_Temp[which(WT$Jdate >= IntTodd[t,1] & WT$Jdate <= IntTodd[t,2])]
  }
  
  ## Mean temperature matrix 
  ### Mean temperature for each stream
  Temp_mu_Indian <- unlist(lapply(Temp_I, mean) )
  Temp_mu_Todd <- unlist(lapply(Temp_T, mean) )
  Temp_mu <- cbind(Temp_mu_Indian, Temp_mu_Todd)
  ### Save data
  write.csv(Temp_mu, paste0("data/Env_Temp_mu_", Sys.Date(), ".csv") )
  