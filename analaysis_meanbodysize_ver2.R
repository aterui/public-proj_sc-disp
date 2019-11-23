# Library ----
  rm(list = ls(all.names = TRUE))
  library(stringr)

# Data ----
  dat <- read.csv("data/VectorData_MERGE2019-11-19.csv")

## Mean and SD
  Species <- c("BHC", "CRC", "STJ")
  mu <- sapply(Species, function(x) mean(dat[dat$Species == x & dat$Y==1, "Size1"]) )
  SD <- sapply(Species, function(x) sd(dat[dat$Species == x & dat$Y==1, "Size1"]) )