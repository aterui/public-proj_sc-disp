D_Todd_STJ <- read.csv("data/Vdata_Todd_STJ2018-08-17.csv"); species <- "STJ"
D_Todd_BHC <- read.csv("data/Vdata_Todd_BHC2018-08-17.csv"); species <- "STJ"
D_Indian_STJ <- read.csv("data/Vdata_Indian_STJ2018-08-17.csv"); species <- "STJ"
D_Indian_BHC <- read.csv("data/Vdata_Indian_BHC2018-08-17.csv"); species <- "STJ"

D_STJ <- rbind(D_Todd_STJ, D_Indian_STJ)
D_BHC <- rbind(D_Todd_BHC, D_Indian_BHC)

D_STJ$river <- c(rep("Todd", nrow(D_Todd_STJ)), rep("Indian", nrow(D_Indian_STJ)))
D_BHC$river <- c(rep("Todd", nrow(D_Todd_BHC)), rep("Indian", nrow(D_Indian_BHC)))
