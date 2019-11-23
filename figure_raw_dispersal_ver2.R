# Script for figure S1-3
# Library ----
  rm(list = ls(all.names = TRUE))
  library(stringr)

# Data ----
  # Fish data
    dat <- read.csv("data/VectorData_MERGE2019-11-19.csv")
    dat$St_Month <- as.numeric(format(as.Date(dat$Date1), format = "%m") )
    dat$St_Year <- format(as.Date(dat$Date1), format = "%Y")
    dat$End_Month <- as.numeric(format(as.Date(dat$Date2), format = "%m") )
    dat$End_Year <- format(as.Date(dat$Date2), format = "%Y")
    
    ## Movement distance
    dat$X_m <- (dat$X2-dat$X1)*20 
    SP <- sort(unique(dat$Species) )
  
  # Env data
    QF99 <- read.csv("data/Env_QF99_2019-11-19.csv")
    Q99 <- cbind(QF99$QF99_Indian, QF99$QF99_Todd)
    Str <- ifelse(dat$Stream=="Indian", 1, 2)
    dat$QF99 <- Q99[cbind(dat$Occasion1, Str)]
    dat$Q99 <- ifelse(dat$QF99 > 0, 1, 0)
  
# Plot ----
  pdf("figure_raw_dispersal.pdf", width = 13, height = 12)
  for(i in 1:length(SP) ){
      par(mfrow = c(4, 4), oma = c(3,3,2,1) )
      dd <- dat[dat$Species==SP[i],]
      sapply(1:length(unique(dd$Occasion1) ), function(x){
             ##plot
               plot(table(dd$X_m[dd$Occasion1 == x]),
                    axes = F, ann = F, col = ifelse(unique(dd$Q99[dd$Occasion1 == x]) >= 1, "red", "black"),
                    xlim = c(-max(abs(dd$X_m), na.rm = T),
                             max(abs(dd$X_m), na.rm = T) ) )
               legend("topright", bty = "n", cex = 1.5,
                      legend = substitute("N = "*v1, list(v1 = sum(dd$Y[dd$Occasion1 == x]) ) ) )
             ##panel label
               St_Month <- sort(unique(dd[dd$Occasion1 == x, "St_Month"]) )
               St_Year <- unique(dd[dd$Occasion1 == x, "St_Year"])
               End_Month <- sort(na.omit(unique(dd[dd$Occasion1 == x, "End_Month"]) ) )
               End_Year <- na.omit(unique(dd[dd$Occasion1 == x, "End_Year"]) )
               lab <- paste0(str_sub(month.name[St_Month[1]], 1, 3), "-", St_Year,
                            " to ",
                            str_sub(month.name[End_Month[1]], 1, 3), "-", End_Year)
               mtext(lab, 3, line = 0.5, cex.axis = 1.2)
             ##axis
               sapply(1:2, function(z) axis(z, las = z, cex.axis = 1.4) )
             })
      mtext("Dispersal distance (m)", 1, outer = T, cex = 1.5)
      mtext("Frequency", 2, outer = T, cex = 1.5)
  }
  dev.off()
    