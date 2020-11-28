
# library -----------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  library(tidyverse)

# read data ---------------------------------------------------------------

  d1 <- read_csv("data_org/indian_final.csv") %>% 
    select(-COMMENTS) %>% 
    mutate(Stream = "Indian")
  
  d2 <- read_csv("data_org/todd_final.csv") %>% 
    select(-COMMENTS) %>% 
    mutate(Stream = "Todd")
  
  dat <- bind_rows(d1, d2) %>% 
    filter(VALID == "Y") %>% 
    mutate(Year = str_sub(Date, start = 1, end = 4),
           Month = str_sub(Date, start = 5, end = 6),
           Day = str_sub(Date, start = 7, end = 8),
           as_date = as.Date(paste(Year, Month, Day, sep="/")),
           tag_id = str_remove_all(TAGID, pattern = "\\s"))
  
# data sort ---------------------------------------------------------------
  
  ## the first 2 occasions were discarded
  ## remove individuals capture only at the last occasion 
  ## remove individuals with no tag_id and body length
  dat <- dat %>% 
    mutate(ind_last = ifelse(tag_id %in% .$tag_id[Occasion == max(Occasion)], 1, 0),
           ind_single = ifelse(tag_id %in% names(which(table(tag_id)==1)), 1, 0),
           ind_remove = ind_single + ind_last,
           julian = julian(as_date)) %>% 
    filter(Occasion > 2 & !(is.na(LEN_COR)) & !(is.na(tag_id))) %>% 
    filter(ind_remove < 2 & SPE_COR %in% c("STJ", "BHC", "CRC")) %>% 
    select(tag_id,
           species = SPE_COR,
           as_date,
           julian,
           section = SEC,
           length = LEN_COR,
           weight = WEIGH_COR,
           occasion = Occasion,
           stream = Stream) %>% 
    mutate(occasion = occasion - 2)
  

# combine 1st and 2nd captures --------------------------------------------
  
  ## single observation within a single occasion
  tag_single <- dat %>% 
    mutate(dummy_name = "n") %>% 
    pivot_wider(id_cols = c(tag_id, occasion, species, stream),
                names_from = dummy_name,
                values_from = c(length, weight, section, julian),
                values_fn = n_distinct) %>% 
    filter(length_n == 1 & weight_n == 1 & section_n == 1 & julian_n == 1) %>% 
    mutate(id_single = paste0(tag_id, occasion, sep = "_"))
  
  ## duplicate within a single occasion; select latest observation
  tag_dup <- dat %>% 
    mutate(dummy_name = "n") %>% 
    pivot_wider(id_cols = c(tag_id, occasion, species, stream),
                names_from = dummy_name,
                values_from = c(length, weight, section, julian),
                values_fn = n_distinct) %>% 
    filter(length_n > 1 | weight_n > 1 | section_n > 1 | julian_n > 1) 
    
  ## combine single and duplicate
  dat_n2 <- dat %>% 
    filter(tag_id %in% tag_dup$tag_id) %>% 
    arrange(species, tag_id, stream) %>% 
    group_by(tag_id, species, stream) %>% 
    slice(which.max(as_date)) %>% 
    ungroup()
  
  dat_clean <- dat %>% 
    mutate(id_single = paste0(tag_id, occasion, sep = "_")) %>% 
    filter(id_single %in% tag_single$id_single) %>%
    bind_rows(dat_n2)
  
  dat1st <- dat_clean %>% 
    filter(occasion < max(occasion)) %>% 
    mutate(dummy_name = "1") %>% 
    pivot_wider(id_cols = c(tag_id, occasion, species, stream),
                names_from = dummy_name,
                values_from = c(weight, length, section, julian),
                values_fn = unique)
  
  dat2nd <- dat_clean %>% 
    filter(occasion > 1) %>% 
    mutate(dummy_name = "2") %>% 
    pivot_wider(id_cols = c(tag_id, occasion, species, stream),
                names_from = dummy_name,
                values_from = c(weight, length, section, julian),
                values_fn = unique) %>% 
    mutate(occasion_2 = occasion) %>% 
    mutate(occasion = occasion_2 - 1)

# output ------------------------------------------------------------------

  dat_final <- dat1st %>% 
    left_join(dat2nd, by = c("tag_id", "species", "occasion", "stream"))
  
  write.csv(dat_final, "data_fmt/vector_data.csv")
  
  