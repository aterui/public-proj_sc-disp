
f_env <- function(dat, WL, WT){
  #Extract date range for each capture-recapture session
    date_range <- cbind( tapply(dat$St_Date, dat$Period, min), tapply(dat$End_Date, dat$Period, max, na.rm=T) )
    ####Water level
    water_level <- sapply(1:nrow(date_range), function(x){
      ##### in-funcion: extract water level data during each capture-recapture interval
      WL$WaterLevel[which(WL$Jdate == date_range[x,1]):which(WL$Jdate == date_range[x,2])]
    })
    ####Water temperature
    water_temp <- sapply(1:nrow(date_range), function(x){
      ##### in-funcion: extract water temp data during each capture-recapture interval
      stID <- min(which(WT$Jdate == date_range[x,1]) )
      endID <- max(which(WT$Jdate == date_range[x,2]) )
      WT$Temp[stID:endID]
    })
    
  #Quantiles for water level (whole time series)
    Q <- quantile(WL$WaterLevel, c(0.9,0.95,0.99))
    ###Median water level
    flow50 <- sapply(water_level, median)
    ###Frequency of flood events (X > 90,95,99 percentiles)
    Q90 <- sapply(water_level, function(x)sum(x > Q[1]))
    Q95 <- sapply(water_level, function(x)sum(x > Q[2]))
    Q99 <- sapply(water_level, function(x)sum(x > Q[3]))
    ###Sigma
    Q_sigma <- sapply(water_level, sd)
    ###Mean water temperture for each period
    WTemp <- sapply(water_temp, mean, na.rm = T)
    
    dat$flow50 <- flow50[dat$Period]
    dat$Q90 <- as.numeric(Q90[dat$Period])
    dat$Q95 <- as.numeric(Q95[dat$Period])
    dat$Q99 <- as.numeric(Q99[dat$Period])
    dat$Q_sigma <- as.numeric(Q_sigma[dat$Period])
    dat$Temp <- as.numeric(WTemp[dat$Period])
  return(dat)
}
