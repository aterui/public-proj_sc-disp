# Basic statistics
dat_raw <- read.csv("data/data_itg2019-10-24.csv")
datT <- dat_raw[dat_raw$Stream=="Todd",]
datI <- dat_raw[dat_raw$Stream=="Indian",]

fmr <- function(dat){
  Mark_u <- tapply(dat$IND_ID, dat$species, function(x) length(unique(x) ) )
  Recap_u <- tapply(dat$IND_ID[dat$Yrecap==1], dat$species[dat$Yrecap==1],
                    function(x) length(unique(x) ) )
  Mark_repl <- tapply(dat$IND_ID, dat$species, function(x) length(x) )
  Recap_repl <- tapply(dat$IND_ID[dat$Yrecap==1], dat$species[dat$Yrecap==1],
                       function(x) length(x) )
  return(list(Mark_u = Mark_u, Recap_u = Recap_u,
              Mark_repl = Mark_repl, Recap_repl = Recap_repl) )
}

dat1 <- fmr(datT)
dat2 <- fmr(datI)
