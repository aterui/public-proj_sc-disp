fg <- function(L0, L1, duration){
  ifelse(is.na(L1), NA, I((log(L1)-log(L0))/duration))
}