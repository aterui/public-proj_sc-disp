# --- Data preparation ---
  ##Water level
  WL <- read.csv("data/WaterLevel_edit.csv")
  ##Water temperature
  WT <- read.csv("data/WaterTemp_data.csv"); WT <- WT[is.na(WT$Indian_Temp)==0,]
  WT$Date <- as.Date(WT$Date)
  WT$Jdate <- julian.Date(WT$Date)
  
  ##Todd
    ###Compile by-species data
    dat1 <- read.csv("data/Vdata_Todd_STJ2019-01-13.csv"); dat1$species <- "STJ"
    dat2 <- read.csv("data/Vdata_Todd_BHC2019-01-13.csv"); dat2$species <- "BHC"
    dat3 <- read.csv("data/Vdata_Todd_CRC2019-01-13.csv"); dat3$species <- "CRC"
    datT <- rbind(dat1, dat2, dat3)
    datT$Stream <- "Todd"
    
    ###Extract date range for each capture-recapture session
    date_range_Todd <- cbind( tapply(datT$St_Date, datT$Period, min), tapply(datT$End_Date, datT$Period, max, na.rm=T) )
      ####Water level
      WLTodd <- sapply(1:nrow(date_range_Todd), function(x){
                ##### in-funcion: extract water level data during each capture-recapture interval
                WL$Todd_WL[which(WL$Jdate == date_range_Todd[x,1]):which(WL$Jdate == date_range_Todd[x,2])]
                })
      ####Water temperature
      WTTodd <- sapply(1:nrow(date_range_Todd), function(x){
                ##### in-funcion: extract water temp data during each capture-recapture interval
                stID <- min(which(WT$Jdate == date_range_Todd[x,1]) )
                endID <- max(which(WT$Jdate == date_range_Todd[x,2]) )
                WT$Todd_Temp[stID:endID]
                })
      
    ###Quantiles for water level (whole time series)
    QT <- quantile(WL$Todd_WL, c(0.9,0.95,0.99))
    ###Presence/Absence of flood events (X > 90,95,99 percentiles)
    QT90 <- sapply(WLTodd, function(x)sum(x > QT[1]))
    QT95 <- sapply(WLTodd, function(x)sum(x > QT[2]))
    QT99 <- sapply(WLTodd, function(x)sum(x > QT[3]))
    ###Sigma
    QT_sigma <- sapply(WLTodd, sd)
    ###Mean water temperture for each period
    WTempT <- sapply(WTTodd, mean, na.rm = T)
        
    datT$Q90 <- as.numeric(QT90[datT$Period])
    datT$Q95 <- as.numeric(QT95[datT$Period])
    datT$Q99 <- as.numeric(QT99[datT$Period])
    datT$Q_sigma <- as.numeric(QT_sigma[datT$Period])
    datT$Temp <- as.numeric(WTempT[datT$Period])
    
  ##Indian
    ###Compile by-species data
    dat4 <- read.csv("data/Vdata_Indian_STJ2019-01-13.csv"); dat4$species <- "STJ"
    dat5 <- read.csv("data/Vdata_Indian_BHC2019-01-13.csv"); dat5$species <- "BHC"
    dat6 <- read.csv("data/Vdata_Indian_CRC2019-01-13.csv"); dat6$species <- "CRC"
    datI <- rbind(dat4, dat5, dat6)
    datI$Stream <- "Indian"
    
    ###Extract date range for each capture-recapture session
    date_range_Indian <- cbind( tapply(datI$St_Date, datI$Period, min), tapply(datI$End_Date, datI$Period, max, na.rm=T) )
      ####Water level
      WLIndian <- sapply(1:nrow(date_range_Indian), function(x){
                  ##### in-funcion: extract water level data during each capture-recapture interval
                  WL$Indian_WL[which(WL$Jdate == date_range_Indian[x,1]):which(WL$Jdate == date_range_Indian[x,2])] # in-function
                  })
      ####Water temperature
      WTIndian <- sapply(1:nrow(date_range_Indian), function(x){
                ##### in-funcion: extract water temp data during each capture-recapture interval
                stID <- min(which(WT$Jdate == date_range_Indian[x,1]) )
                endID <- max(which(WT$Jdate == date_range_Indian[x,2]) )
                WT$Indian_Temp[stID:endID]
                })
    ###Frequency of flood events (X > 90,95,99 percentiles)
    QI <- quantile(WL$Indian_WL, c(0.9,0.95,0.99))
    QI90 <- sapply(WLIndian, function(x)sum(x > QI[1]))
    QI95 <- sapply(WLIndian, function(x)sum(x > QI[2]))
    QI99 <- sapply(WLIndian, function(x)sum(x > QI[3]))
    ###Sigma
    QI_sigma <- sapply(WLIndian, sd)
    ###Mean water temperature
    WTempI <- sapply(WTIndian, mean, na.rm = T)
    
    datI$Q90 <- as.numeric(QI90[datI$Period])
    datI$Q95 <- as.numeric(QI95[datI$Period])
    datI$Q99 <- as.numeric(QI99[datI$Period])
    datI$Q_sigma <- as.numeric(QI_sigma[datI$Period])
    datI$Temp <- as.numeric(WTempI[datI$Period])
    
  ##Integrate Todd and Indian data
  dat_itg <- rbind(datT, datI)
  dat_itg <- dat_itg[,-1]# removing redundunt columns
  #write.csv(dat_itg, paste0("data/data_itg",Sys.Date(),".csv"))