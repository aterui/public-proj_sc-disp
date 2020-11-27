
# library -----------------------------------------------------------------
  rm(list = ls(all.names = TRUE))
  library(tidyverse)

# read data ---------------------------------------------------------------
  d1 <- read_csv("data_org/Indian_final.csv") %>% 
    select(-COMMENTS) %>% 
    mutate(Stream = "Indian")
  
  d2 <- read_csv("data_org/Todd_final.csv") %>% 
    select(-COMMENTS) %>% 
    mutate(Stream = "Todd")
  
  dat <- bind_rows(d1, d2) %>% 
    mutate(Year = str_sub(Date, start = 1, end = 4),
           Month = str_sub(Date, start = 5, end = 6),
           Day = str_sub(Date, start = 7, end = 8),
           as_date = as.Date(paste(Year, Month, Day, sep="/")))
  
# data sort ---------------------------------------------------------------
  
  ## remove individuals capture only at the last occasion 
  ## remove individuals with no tag_id
  dat <- dat %>% 
    filter(Occasion > 2 & !(is.na(LEN_COR)) & !(is.na(TAGID))) %>% 
    mutate(ind_last = ifelse(TAGID %in% .$TAGID[Occasion == max(Occasion)], 1, 0),
           ind_single = ifelse(TAGID %in% names(which(table(TAGID)==1)), 1, 0),
           ind_remove = ind_single + ind_last,
           julian = julian(as_date)) %>% 
    filter(ind_remove < 2 & SPE_COR %in% c("STJ", "BHC", "CRC")) %>% 
    select(tag_id = TAGID,
           species = SPE_COR,
           as_date,
           section = SEC,
           length = LEN_COR,
           weight = WEIGH_COR,
           occasion = Occasion,
           stream = Stream,
           julian) %>% 
    mutate(occasion = occasion - 2)
  
  dat1st <- dat %>% 
    filter(occasion < max(occasion)) %>% 
    mutate(dummy_name = "1") %>% 
    pivot_wider(id_cols = c(tag_id, occasion, species, stream),
                names_from = dummy_name,
                values_from = c(weight, length, section, julian),
                values_fn = mean)
  
  dat2nd <- dat %>% 
    filter(occasion > 1) %>% 
    mutate(dummy_name = "2") %>% 
    pivot_wider(id_cols = c(tag_id, occasion, species, stream),
                names_from = dummy_name,
                values_from = c(weight, length, section, julian),
                values_fn = mean) %>% 
    mutate(occasion_2 = occasion) %>% 
    mutate(occasion = occasion_2 - 1)
  
  dat_final <- dat1st %>% 
    left_join(dat2nd, by = c("tag_id", "species", "occasion", "stream"))
  
  write.csv(dat_final, "data_fmt/vector_data.csv")
  
  