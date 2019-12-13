# Select Species  
  SP <- "STJ"

# Data
  dat <- read.csv("data/VectorData_MERGE2019-11-19.csv")
  dd <- dat[dat$Species==SP,]
  scl.size <- scale(dd$Size1, scale = 2*sd(dd$Size1))
  Qsize <- quantile(scl.size, c(0.2,0.5,0.8), na.rm = T)
  est <- read.csv(paste0("result/summary_8000", SP, "2019-11-20Q99.csv") )
  
  b1id <- which(est$X=="b[1]") # Intercept
  b2id <- which(est$X=="b[2]") # Flow
  b3id <- which(est$X=="b[3]") # Size
  b4id <- which(est$X=="b[4]") # Flow*Size
  
  delta0 <- sapply(Qsize, function(x) exp(est[b1id,"X50."] + est[b3id,"X50."]*x) )
  delta1 <- sapply(Qsize, function(x) exp(est[b1id,"X50."] + est[b2id,"X50."] + (est[b3id,"X50."] + est[b4id,"X50."])*x) )
  
  var0 <- 2*delta0^2
  var1 <- 2*delta1^2
  