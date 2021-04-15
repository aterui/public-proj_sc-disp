
# setup -------------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse, patchwork)


# data --------------------------------------------------------------------
  
  dat <- read_csv('data_fmt/vector_data.csv') %>% 
    mutate(Date = as.Date(julian_1, origin = as.Date("1970-01-01"))) %>% 
    group_by(occasion) %>% 
    summarize(date = min(Date))
  
  flow <- read_csv("data_org/water_level.csv") %>% 
    mutate(Date = as.Date(Date, format = "%m/%d/%Y")) %>% 
    pivot_longer(cols = c(Todd_WL, Indian_WL),
                 names_to = "stream",
                 values_to = "water_level") %>% 
    mutate(stream = case_when(stream == "Todd_WL" ~ "Todd",
                              stream == "Indian_WL" ~ "Indian"))
  
  temp <- read_csv("data_org/water_temperature.csv") %>% 
    separate(col = Date, into = c("Date", "Time"), sep = "\\s") %>% 
    mutate(Date = as.Date(Date, format = "%Y/%m/%d")) %>% 
    pivot_longer(cols = c(Todd_Temp, Indian_Temp),
                 names_to = "stream",
                 values_to = "temperature") %>% 
    filter(Date >= "2016-01-01") %>% 
    mutate(stream = case_when(stream == "Todd_Temp" ~ "Todd",
                              stream == "Indian_Temp" ~ "Indian"))
  

# flow quantile -----------------------------------------------------------
  
  q99 <- flow %>% 
    group_by(stream) %>% 
    summarize(q99 = quantile(water_level, 0.99))
  
  flow <- flow %>% 
    left_join(q99, by = "stream")
    
# plot --------------------------------------------------------------------
  
  plt_theme <- theme_bw() + theme(
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
  )
  
  theme_set(plt_theme)
  
  g_flow <- flow %>%   
    ggplot() +
    geom_line(aes(x = Date, y = water_level),
              alpha = 0.5) +
    geom_hline(aes(yintercept = q99),
               linetype = "dashed") +
    geom_vline(data = dat, aes(xintercept = date),
               alpha = 0.4,
               linetype = "dotted") +
    facet_wrap(facets = ~ stream) +
    ylab("Water level (m)") + 
    xlab(NULL)
    
  g_temp <- temp %>%   
    ggplot() +
    geom_line(aes(x = Date, y = temperature),
              alpha = 0.5) +
    geom_vline(data = dat, aes(xintercept = date),
               alpha = 0.4,
               linetype = "dotted") +
    facet_wrap(facets = ~ stream) +
    ylab("Temperature (degree C)")
  
  print(g_flow / g_temp)
  