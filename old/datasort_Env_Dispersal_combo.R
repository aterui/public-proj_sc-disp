source("function_f_env.R")

# Water level and temperature data ----
  ##Water level
    WL <- read.csv("data/WaterLevel_edit.csv")
  ##Water temperature
    WT <- read.csv("data/WaterTemp_data.csv"); WT <- WT[is.na(WT$Indian_Temp)==0,]
    WT$Date <- as.Date(WT$Date)
    WT$Jdate <- julian.Date(WT$Date)

# Data sort ----
  ##Todd
    ###Compile by-species data
    dat1 <- read.csv("data/Vdata_Todd_STJ2019-01-13.csv"); dat1$species <- "STJ"
    dat2 <- read.csv("data/Vdata_Todd_BHC2019-01-13.csv"); dat2$species <- "BHC"
    dat3 <- read.csv("data/Vdata_Todd_CRC2019-01-13.csv"); dat3$species <- "CRC"
    datT <- rbind(dat1, dat2, dat3)
    datT$Stream <- "Todd"
    
    wl_Todd <- data.frame(WaterLevel = WL$Todd_WL, Jdate = WL$Jdate)
    wt_Todd <- data.frame(Temp = WT$Todd_Temp, Jdate = WT$Jdate)
    
    datT <- f_env(dat = datT, WL = wl_Todd, WT = wt_Todd)

  ##Indian
    ###Compile by-species data
    dat4 <- read.csv("data/Vdata_Indian_STJ2019-01-13.csv"); dat4$species <- "STJ"
    dat5 <- read.csv("data/Vdata_Indian_BHC2019-01-13.csv"); dat5$species <- "BHC"
    dat6 <- read.csv("data/Vdata_Indian_CRC2019-01-13.csv"); dat6$species <- "CRC"
    datI <- rbind(dat4, dat5, dat6)
    datI$Stream <- "Indian"
    
    wl_Indian <- data.frame(WaterLevel = WL$Indian_WL, Jdate = WL$Jdate)
    wt_Indian <- data.frame(Temp = WT$Indian_Temp, Jdate = WT$Jdate)
    
    datI <- f_env(dat = datI, WL = wl_Indian, WT = wt_Indian)
    
# Integrate data ----
  dat_itg <- rbind(datT, datI)
  dat_itg <- dat_itg[,-1]# removing redundunt columns
  write.csv(dat_itg, paste0("data/data_itg",Sys.Date(),".csv") )