rm(list = ls(all.names = TRUE))

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
  