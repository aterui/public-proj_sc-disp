getlimit <- function(X, start = 1, dlimit = 0, ulimit, truncation = F, hl = 0.5){
              DL <- UL <- NULL
              for(i in start:(ncol(X)-1) ){
                if(truncation == T){
                  dl <- ifelse(is.na(X[,i])|is.na(X[,i+1]), dlimit - X[,i], dlimit - X[,i] ) 
                  ul <- ifelse(is.na(X[,i])|is.na(X[,i+1]), ulimit - X[,i], ulimit - X[,i] ) 
                }else{
                  dl <- ifelse(is.na(X[,i])|is.na(X[,i+1]), dlimit - X[,i], (X[,i+1] - X[,i]) - hl ) # hl is a half of section length or unit 
                  ul <- ifelse(is.na(X[,i])|is.na(X[,i+1]), ulimit - X[,i], (X[,i+1] - X[,i]) + hl ) 
                }
                DL <- cbind(DL, dl)
                UL <- cbind(UL, ul)
              }
              return(list(DL = DL, UL = UL))
            }
