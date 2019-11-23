# Script for figure S1-3
# Library ----
  library(stringr)

# Data ----
  dat <- read.csv("data/data_itg2019-03-29.csv")
  dat$Y_m <- dat$Y*20
  dat$Label <- paste0(dat$St_Month, "-", dat$St_Year, " to ", dat$End_Month, "-", dat$End_Year)
  SP <- sort(unique(dat$species) )

# Plot ----
  pdf("figure_raw_dispersal.pdf", width = 13, height = 12)
    for(i in 1:length(SP) ){
      par(mfrow = c(4, 4), oma = c(3,3,2,1) )
      dd <- dat[dat$species==SP[i],]
      sapply(1:length(unique(dd$Period) ),
             function(x){
             ##plot
               plot(table(dd$Y_m[dd$Period == x]),
                    axes = F, ann = F, col = ifelse(unique(dd$Q99[dd$Period == x]) >= 1, "red", "black"),
                    xlim = c(-max(abs(dd$Y_m), na.rm = T),
                             max(abs(dd$Y_m), na.rm = T) ) )
               legend("topright", bty = "n", cex = 1.5,
                      legend = substitute("N = "*v1, list(v1 = sum(dd$Yrecap[dd$Period == x]) ) ) )
             ##panel label
               St_Month <- sort(unique(dd[dd$Period == x, "St_Month"]) )
               St_Year <- unique(dd[dd$Period == x, "St_Year"])
               End_Month <- sort(na.omit(unique(dd[dd$Period == x, "End_Month"]) ) )
               End_Year <- na.omit(unique(dd[dd$Period == x, "End_Year"]) )
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
    