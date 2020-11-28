
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
    mutate(tag_id = str_remove_all(TAGID, pattern = "\\s")) %>% 
    mutate(Year = str_sub(Date, start = 1, end = 4),
           Month = str_sub(Date, start = 5, end = 6),
           Day = str_sub(Date, start = 7, end = 8),
           as_date = as.Date(paste(Year, Month, Day, sep="/")),
           ind_last = ifelse(tag_id %in% .$tag_id[Occasion == max(Occasion)], 1, 0),
           ind_single = ifelse(tag_id %in% names(which(table(tag_id)==1)), 1, 0),
           ind_remove = ind_single + ind_last,
           julian = julian(as_date)) %>% 
    filter(VALID == "Y" & Occasion > 2 & !(is.na(LEN_COR)) & !(is.na(tag_id))) %>% 
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
  
# sampling date range within and among occasions --------------------------

  ## capture session
  d1 <- dat %>% 
    mutate(occasion_1 = occasion) %>% 
    group_by(occasion_1, stream) %>% 
    summarize(st_date = min(as_date),
              end_date = max(as_date))
  
  ## recapture session
  d2 <- dat %>% 
    mutate(occasion_2 = occasion - 1) %>% 
    group_by(occasion_2, stream) %>% 
    summarize(st_date = min(as_date),
              end_date = max(as_date))

  dat_drange <- left_join(d1, d2, by = c("occasion_1" = "occasion_2", "stream")) %>% 
    filter(occasion_1 < 14) %>% 
    group_by(occasion_1, stream) %>% 
    summarise(date = seq(st_date.x, st_date.y, by = 1)) %>% 
    rename(occasion = occasion_1)
    
# water level -------------------------------------------------------------
  
  ## combined with occasion data
  dat_wl <- read_csv("data_org/water_level.csv") %>% 
    mutate(as_date = as.Date(Date, format = "%m/%d/%Y")) %>% 
    rename(Todd = Todd_WL,
           Indian = Indian_WL) %>% 
    pivot_longer(cols = c(Todd, Indian), names_to = "stream", values_to = "level") %>% 
    left_join(dat_drange, by = c("as_date" = "date", "stream"))
  
  ## standardize by subtracting minimum water level for each stream
  dat_wl <- dat_wl %>% 
    group_by(stream) %>% 
    summarize(level = level - min(level),
              as_date,
              date = Date,
              occasion)
  
  ## summary statistics
  dat_wl_summary <- dat_wl %>% 
    group_by(stream) %>% 
    mutate(q99 = quantile(level, probs = 0.99)) %>% 
    ungroup() %>% 
    group_by(occasion, stream) %>% 
    summarize(q50 = median(level),
              q99_event = ifelse(any(level > q99), 1, 0)) %>% 
    drop_na(occasion)
  
  write_csv(dat_wl_summary, "data_fmt/flow_summary.csv")

# water temperature -------------------------------------------------------

  ## combined with occasion data
  dat_temp <- read_csv("data_org/water_temperature.csv") %>% 
    mutate(as_date = as.Date(Date)) %>% 
    rename(Todd = Todd_Temp,
           Indian = Indian_Temp) %>% 
    pivot_longer(cols = c(Todd, Indian), names_to = "stream", values_to = "temperature") %>% 
    left_join(dat_drange, by = c("as_date" = "date", "stream")) %>% 
    drop_na(temperature)
  
  ## summary statistics
  dat_temp_summary <- dat_temp %>% 
    group_by(occasion, stream) %>% 
    summarize(mu_temp = mean(temperature)) %>% 
    drop_na(occasion)
  
  write_csv(dat_wl_summary, "data_fmt/temp_summary.csv")
  
  