# Basic statistics
  # Library ----
  rm(list = ls(all.names = TRUE))
  library(stringr)
  
  # Function ----
  fmr <- function(dat){
    Mark_u <- tapply(dat$IND_ID, dat$Species, function(x) length(unique(x) ) )
    Recap_u <- tapply(dat$IND_ID[dat$Y==1], dat$Species[dat$Y==1],
                      function(x) length(unique(x) ) )
    Mark_repl <- tapply(dat$IND_ID, dat$Species, function(x) length(x) )
    Recap_repl <- tapply(dat$IND_ID[dat$Y==1], dat$Species[dat$Y==1],
                         function(x) length(x) )
    return(list(Mark_u = Mark_u, Recap_u = Recap_u,
                Mark_repl = Mark_repl, Recap_repl = Recap_repl) )
  }
  
  # Data ----
  # Fish data
  dat <- read.csv("data/VectorData_MERGE2019-11-19.csv")
  
  dat1 <- fmr(dat[dat$Stream=="Indian",])
  dat2 <- fmr(dat[dat$Stream=="Todd",])
