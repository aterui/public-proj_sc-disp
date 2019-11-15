rm(list = ls(all.names = TRUE))

# Data preparation ----
  species <- "CRC"
  
  ## Capture-recapture data
  file1 <- paste0("data/MatrixData/", species, "_Mcap2019-11-13.csv")
  file2 <- paste0("data/MatrixData/", species, "_Msec2019-11-13.csv")
  file3 <- paste0("data/MatrixData/", species, "_Msize2019-11-13.csv")
  file4 <- paste0("data/MatrixData/", species, "_Mdate2019-11-13.csv")
  CH <- read.csv(file1) # Capture History
  LH <- read.csv(file2) # Location History
  SH <- read.csv(file3) # Size History
  JH <- read.csv(file4) # Julian date History
  
  X_raw <- as.matrix(LH[,which(colnames(LH)=="X1"):ncol(LH)]) # Section ID
  X <- X_raw*20 - 10 # Section ID to distance data
  Y <- as.matrix(CH[,which(colnames(CH)=="X1"):ncol(CH)])
  J <- as.matrix(JH[,which(colnames(JH)=="X1"):ncol(JH)])
  S <- as.matrix(SH[,which(colnames(SH)=="X1"):ncol(SH)])
  