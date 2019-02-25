
getfirst <- function(x){
             if(any(is.na(x))){
              y <- min(which(is.na(x)==F))
              }else{
                y <-  1
              }
              return(y)}