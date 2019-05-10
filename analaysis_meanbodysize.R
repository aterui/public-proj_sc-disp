# Data preparation ----
dat_raw <- read.csv("data/data_itg2019-03-29.csv")
sp <- sort(unique(dat_raw$species))

mu <- sapply(sp, function(x) plot(density(dat_raw[dat_raw$species==sp[x]&dat_raw$Yrecap==1, "St_Size"])) )
SD <- sapply(sp, function(x) sd(dat_raw[dat_raw$species==sp[x]&dat_raw$Yrecap==1, "St_Size"]) )