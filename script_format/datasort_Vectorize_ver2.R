# Call library ----
  rm(list = ls(all.names = TRUE))
  library(stringr)

# Select species ----
  species <- "BHC" #MTS, CRC, BHC, STJ

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

# Data sort ----
  ## remove 1-2 occasions; these are trial period so inappropriate for analysis
  dat$Occasion <- dat$Occasion - 2
  dat <- dat[dat$Occasion > 0,]
  
  ## remove individuals with no body size data
  dat <- dat[-which(is.na(dat$LEN_COR)),]
  
  ## remove individuals capture only at the last occasion 
  ID_last <- unique(dat$TAGID[dat$Occasion==max(dat$Occasion)])
  ID_single <- names(which(table(dat$TAGID)==1) )
  ID_rm <- intersect(ID_last, ID_single)
  dat <- dat[-which(dat$TAGID %in% ID_rm),]
  
  ## Remove data without tag info
  dat <- dat[-which(is.na(dat$TAGID)),]
  
  ## Select species
  D <- dat[dat$SPE == species,]; unique(D$SPE)

  ## Matrix data
  ### Msize, Msec, Mdate
  indID <- sort( unique(D$TAGID) ) # individual tagID
  occID <- sort( unique(D$Occasion) ) # occasionID
  Mcap <- Msize <- Msec <- Mjd <- Mdate <- matrix(nrow = length(indID), ncol = length(occID))
  Str <- NULL
  
  for(i in 1:length(indID) ){
    tmp <- D[D$TAGID == indID[i],]
    for(j in 1:nrow(tmp)){
      Msec[i,tmp$Occasion[j]] <- tmp$SEC[j] #Section ID
      Msize[i,tmp$Occasion[j]] <- tmp$LEN_COR[j] #Body size
      Mjd[i,tmp$Occasion[j]] <- julian.Date(tmp$as.date[j]) #Julian date
      Mdate[i,tmp$Occasion[j]] <- as.character(tmp$as.date[j]) #Date
    }
    Str[i] <- unique(tmp$Stream)
    print(substitute(var1/var2, list(var1 = i, var2 = length(indID)) ) )
  }
  
# Recap data ---- 
  source("function_getY_binary.R")  
  MY <- getY_binary(Msec)
  ## Col1: individual ID, Col2: occassion ID
  ## X1 release, X2 recapture occassion
  X1ID <- X2ID <- which(is.na(MY)==0, arr.ind = T)
  X1ID[,2] <- X2ID[,2] - 1
  
# Vectorize output
  out <- data.frame(ID = 1:length(MY[is.na(MY)==0]))
  
  ### Species
  out$Species <- species
  ### Stream
  out$Stream <- Str[X1ID[,1]]
  ### Recap or not
  out$Y <- MY[is.na(MY)==0]
  ### Release and recapture location
  out$X1 <- Msec[X1ID]
  out$X2 <- Msec[X2ID]
  ### Body size
  out$Size1 <- Msize[X1ID]
  out$Size2 <- Msize[X2ID]
  ### Julian date
  out$JD1 <- Mjd[X1ID]
  out$JD2 <- Mjd[X2ID]
  ### Date
  out$Date1 <- Mdate[X1ID]
  out$Date2 <- Mdate[X2ID]
  ### Occasion ID
  out$Occasion1 <- X1ID[,2]
  out$Occasion2 <- X2ID[,2]
  ### Individual ID
  out$IND_ID <- X1ID[,1]
  ### Tag ID
  out$TAG_ID <- indID[X1ID[,1]]
  
  file <- paste0("data/VectorData_", species, Sys.Date(), ".csv")
  #write.csv(out, file)
  
  