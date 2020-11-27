# Data merge
  rm(list = ls(all.names = TRUE))
  
  Species <- c("BHC", "CRC", "STJ")
  file <- sapply(1:3, function(x)paste0("data/VectorData_", Species[x], "2019-11-19.csv"))
  dat_raw <- rbind(read.csv(file[1]), read.csv(file[2]), read.csv(file[3]) )
  
  ## Remove odd replicates
  y <- dat_raw$Size2-dat_raw$Size1
  dat <- dat_raw[-which(y %in% c(-29,100)),]
  dat <- dat[,-which(colnames(dat)=="X")]
  
  ## Save data
  write.csv(dat, paste0("data/VectorData_MERGE", Sys.Date(), ".csv") )