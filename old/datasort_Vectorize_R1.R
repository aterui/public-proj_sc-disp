# Call library ----
  rm(list = ls(all.names = TRUE))
  library(stringr)

# Data ----
  ## Define data source
  d <- read.csv("data/Indian_final.csv"); d <- d[,1:which(colnames(d)=="COMMENTS")]; stream <- "Indian"
  #d <- read.csv("data/Todd_final.csv"); d <- d[,1:which(colnames(d)=="COMMENTS")]; stream <- "Todd"

  ## Re-define
  d$Year <- str_sub(d$Date, start = 1, end = 4)
  d$Month <- str_sub(d$Date, start = 5, end = 6)
  d$Day <- str_sub(d$Date, start = 7, end = 8)
  d$as.date <- as.Date(paste(d$Year,d$Month,d$Day, sep="/"))

# Data sort ----
  ## Remove data without tag info
  D <- d[-which(is.na(d$TAGID)),]
  
  ## Select species
  b <- unique(D$SPE)
  species <- "STJ" #MTS, CRC, BHC, STJ
  D <- D[D$SPE == species,]
  
  ## Reshape data
  indID <- sort( unique(D$TAGID) ) # individual tagID
  occID <- sort( unique(D$Occasion) ) # occasionID
  mat_size <- mat_sec <- mat_date <- mat_month <- mat_year <- matrix(nrow = length(indID), ncol = length(occID))
  
  for(i in 1:length(indID) ){
    tmp <- D[D$TAGID == indID[i],]
    for(j in 1:nrow(tmp)){
      mat_sec[i,tmp$Occasion[j]] <- tmp$SEC[j] #Section ID
      mat_size[i,tmp$Occasion[j]] <- tmp$LEN_COR[j] #Body size
      mat_date[i,tmp$Occasion[j]] <- julian.Date(tmp$as.date[j]) #Julian date
      mat_month[i,tmp$Occasion[j]] <- as.numeric(tmp$Month[j]) #Month
      mat_year[i,tmp$Occasion[j]] <- as.numeric(tmp$Year[j]) #Year
    }
    print(substitute(var1/var2, list(var1 = i, var2 = length(indID)) ) )
  }

# Vectorize data ----
  ## Convert location data to displacement distance or recapture history
  source("function_getY.R"); source("function_getYrecap.R"); source("function_getlimit.R")
  start_occ <- 3 # starting at occation 3
  ulimit <- max(d$SEC) # upper distance class limit (must use dataframe "d" to represent maximum)
  
  Y <- getY(mat_sec, start = start_occ); colnames(Y) <- NULL # Displacement section
  Interval <- getY(mat_date, start = start_occ); colnames(Interval) <- NULL # capture-recapture interval
  Yrecap <- getYrecap(mat_sec, start = start_occ); colnames(Yrecap) <- NULL # recaptured or not
  Ylimit <- getlimit(mat_sec, start = start_occ, ulimit = ulimit, truncation = F) # observable range of displacement
  
  St_Size <- mat_size[, start_occ:(ncol(mat_size)-1)] # St: at capture trial
  St_Date <- mat_date[, start_occ:(ncol(mat_date)-1)] 
  St_Month <- mat_month[, start_occ:(ncol(mat_month)-1)]
  St_Year <- mat_year[, start_occ:(ncol(mat_year)-1)]
  
  End_Size <- mat_size[, (start_occ+1):ncol(mat_size)] # End: at recapture trial
  End_Date <- mat_date[, (start_occ+1):ncol(mat_date)] 
  End_Month <- mat_month[, (start_occ+1):ncol(mat_month)]
  End_Year <- mat_year[, (start_occ+1):ncol(mat_year)]
  
  ## Remove unmarked individuals in occations "start_occ" to 15
  cap <- apply(Yrecap, 1, function(x) ifelse(all(is.na(x)), 0, 1) )
  
  indID <- indID[which(cap == 1)]
  Y <- Y[which(cap == 1),]
  Section <- mat_sec[which(cap == 1), start_occ:ncol(mat_sec)]
  Interval <- Interval[which(cap == 1),]
  Yrecap <- Yrecap[which(cap == 1),]

  St_Size <- St_Size[which(cap == 1), ]
  St_Date <- St_Date[which(cap == 1), ]
  St_Month <- St_Month[which(cap == 1), ]
  St_Year <- St_Year[which(cap == 1), ]
  
  End_Size <- End_Size[which(cap == 1), ]
  End_Date <- End_Date[which(cap == 1), ]
  End_Month <- End_Month[which(cap == 1), ]
  End_Year <- End_Year[which(cap == 1), ]
  
  ## Output data
  IND_ID <- rep( indID, ncol(Y) )
  ID <- rep( 1:nrow(Y), ncol(Y) )
  Period <- as.vector(sapply(1:ncol(Y), rep, nrow(Y)) )
  output_tmp <- data.frame( ID = ID, IND_ID = IND_ID, Y = as.vector(Y), Yrecap = as.vector(Yrecap),
                            Sec_cap = as.vector(Section[,1:13]), Sec_recap = as.vector(Section[,2:14]),
                            St_Size = as.vector(St_Size), End_Size = as.vector(End_Size),
                            Period, Interval = as.vector(Interval),
                            St_Date = as.vector(St_Date), St_Month = as.vector(St_Month), St_Year = as.vector(St_Year),
                            End_Date = as.vector(End_Date), End_Month = as.vector(End_Month), End_Year = as.vector(End_Year) )
  
  output <- output_tmp[is.na(output_tmp$Yrecap) == 0,] # remove individuals that were not captured in the previous trial
  
  ## Save data
  #write.csv(output, paste0("data/Vdata_",stream,"_", species, Sys.Date(),".csv") )
