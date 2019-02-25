# --- Data preparation ---
  library(lme4)
  dat <- read.csv("data/data_itg2019-01-16.csv")
  dat <- dat[dat$species=="BHC",] # species: "STJ", "BHC", "CRC"
  D <- dat[is.na(dat$St_Size)==0,]
  
  source("function_growth.R")
  D$growth <- fg(L0 = D$St_Size, L1 = D$End_Size, duration = D$Interval)
  D$growth[D$growth<0] <- 0
  #boxplot(growth ~ I(Q99>0), D, pch=21, cex=1.5, col=NA, bg=grey(0,0.1) )
  summary(lmer(growth ~ Temp + abs(Y) + I(Q99>0) + Stream + (1|IND_ID), D))
  