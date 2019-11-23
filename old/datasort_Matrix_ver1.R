# Call library ----
  rm(list = ls(all.names = TRUE))
  library(stringr)

# Select species ----
  species <- "STJ" #MTS, CRC, BHC, STJ

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
  
  ## remove inidividuals capture only at the last occasion 
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
  Mcap <- Msize <- Msec <- Mdate <- matrix(nrow = length(indID), ncol = length(occID))
  
  for(i in 1:length(indID) ){
    tmp <- D[D$TAGID == indID[i],]
    for(j in 1:nrow(tmp)){
      Msec[i,tmp$Occasion[j]] <- tmp$SEC[j] #Section ID
      Msize[i,tmp$Occasion[j]] <- tmp$LEN_COR[j] #Body size
      Mdate[i,tmp$Occasion[j]] <- julian.Date(tmp$as.date[j]) #Julian date
    }
    print(substitute(var1/var2, list(var1 = i, var2 = length(indID)) ) )
  }
  
  ### Mcap: capture history
  ObsF <- apply(Msec, 1, function(x) min(which(is.na(x)==0) ) )
  for(i in 1:nrow(Mcap)){
    Mcap[i,ObsF[i]:ncol(Mcap)] <- ifelse(is.na(Msec[i,ObsF[i]:ncol(Mcap)]), 0, 1)
  }
  
  ### Debug
  any(ObsF==max(D$Occasion))
  unique(Mcap[is.na(Msec)])
  unique(Mcap[is.na(Msize)])
  unique(Mcap[is.na(Mdate)])
  
# Vectorize ----
  RC <- which(is.na(Mcap)==0, arr.ind = T)
  Out <- data.frame(Species = species,
                    Y = Mcap[is.na(Mcap)==0],
                    Section = Msec[is.na(Mcap)==0],
                    Size = Msize[is.na(Mcap)==0],
                    Julian = Mdate[is.na(Mcap)==0],
                    IND_ID = RC[,1], Occasion = RC[,2],
                    TAGID = indID[RC[,1]])
  
  ## Append StreamID
  indID1 <- unique(D$TAGID[D$Stream == "Indian"])
  Out$Stream[Out$TAGID %in% indID1] <- "Indian"
  Out$Stream[is.na(Out$Stream)] <- "Todd"
  
# Save data ----  
  file <- paste0("data/", "Vector_", species, Sys.Date(), ".csv")
  write.csv(Out, file)
        
