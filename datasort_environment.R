
rm(list = ls(all.names = TRUE))

D <- read.csv("data/WaterLevel.csv")
D$Date <- as.Date(D$Date)
D$Month <- format(D$Date, format = "%m")
D$Year <- format(D$Date, format = "%y")
D$Jdate <- julian.Date(D$Date)
D$Wet <- ifelse(as.numeric(D$Month)<5,1,0)
#write.csv(D, "data/WaterLevel_edit.csv")

plot(Todd_WL~Date, D, pch=21, col=NA, bg = c(rgb(1,0,0,0.2),rgb(0,1,0,0.2))[factor(D$Wet)])
plot(Todd_WL~Date, D, pch=21, col=NA, bg = c(rgb(1,0,0,0.2),rgb(0,1,0,0.2),grey(0,0.2))[factor(D$Year)])
plot(Indian_WL~Date, D, pch=21, col=NA, bg = c(rgb(1,0,0,0.2),rgb(0,1,0,0.2),grey(0,0.2))[factor(D$Year)])

