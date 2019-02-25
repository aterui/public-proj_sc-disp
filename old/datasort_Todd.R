# --- Data load ---
d <- read.csv("data/Todd_final.csv"); d <- d[,1:which(colnames(d)=="COMMENTS")]

# --- Data sort ---
## Remove data without tag info
rm <- na.action( na.omit(d$TAGID) )
D <- d[-rm,]

## Select species
species <- "BHC" # "BHC" or "STJ" or "CRC"
D <- D[D$SPE_COR == species,]

## Reshape data
indID <- sort( unique(D$TAGID) ) # individual tagID
occID <- sort( unique(D$Occasion) ) # occasionID
size <- mat <- matrix(nrow = length(indID), ncol = length(occID))

for(i in 1:length(indID) ){
  tmp <- D[D$TAGID == indID[i],]
  for(j in 1:nrow(tmp)){
    mat[i,tmp$Occasion[j]] <- tmp$SEC[j]
    size[i,tmp$Occasion[j]] <- tmp$LEN_COR[j]
  }
}
size_vector <- apply(size, 1, mean, na.rm=T)

# --- Vectorize data ---
## Transform location data to displacement distance or recapture history
source("function_getY.R"); source("function_getYrecap.R"); source("function_getlimit.R")
start_occ <- 3

Y <- getY(mat, start = start_occ); colnames(Y) <- NULL
Yrecap <- getYrecap(mat, start = start_occ); colnames(Yrecap) <- NULL
Ylimit <- getlimit(mat, start = start_occ, ulimit = 26, truncation = T)

## Remove unmarked individuals in occations "start_occ" to 15
cap <- apply(Yrecap, 1, function(x) ifelse(all(is.na(x)), 0, 1) )
Y <- Y[which(cap == 1),]
Yrecap <- Yrecap[which(cap == 1),]
DL <- Ylimit$DL[which(cap == 1),]
UL <- Ylimit$UL[which(cap == 1),]

## Output data
IND_ID <- rep( 1:nrow(Y), ncol(Y) )
Period <- as.vector(sapply(1:ncol(Y), rep, nrow(Y)) )
St_occ <- Period + (start_occ - 1)
End_occ <- Period + (start_occ)
tmp <- data.frame(Y = as.vector(Y), Yrecap = as.vector(Yrecap),
                  DL = as.vector(DL), UL = as.vector(UL), IND_ID, Period, St_occ, End_occ)
output <- tmp[is.na(tmp$Yrecap) == 0,]

#write.csv(output, paste0("data/Vdata_Todd_", species, Sys.Date(),".csv") )
