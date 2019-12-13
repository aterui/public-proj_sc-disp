rm(list = ls(all.names = T))
library(nimble)

# Select Species  
  SP <- "STJ"

# Data
  dat <- read.csv("data/VectorData_MERGE2019-11-19.csv")
  dd <- dat[dat$Species==SP,]
  est <- read.csv(paste0("result/summary_8000", SP, "2019-11-20Q99.csv") )
  
  b1id <- which(est$X=="b[1]") # Intercept
  b2id <- which(est$X=="b[2]") # Flow
  
  scale.para <- exp(est[b1id, "X50."] + est[b2id, "X50."])
  pdexp(10, scale = scale.para) - pdexp(-10, scale = scale.para)
