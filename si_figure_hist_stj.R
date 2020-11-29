
# library -----------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse, kableExtra)

# data --------------------------------------------------------------------
  
  flow <- read.csv("data_fmt/flow_summary.csv")
  temp <- read.csv("data_fmt/temp_summary.csv")
  
  dat <- read_csv("data_fmt/vector_data.csv") %>% 
    left_join(flow, by = c("stream", "occasion")) %>% 
    left_join(temp, by = c("stream", "occasion"))
  
  dat <- dat %>% 
    group_by(occasion) %>% 
    summarise(st_date = min(julian_1),
              end_date = min(julian_2, na.rm = T)) %>% 
    mutate(st_date = as.Date(st_date, origin = as.Date("1970-01-01")),
           end_date = as.Date(end_date, origin = as.Date("1970-01-01"))) %>% 
    mutate(date_label = paste(format(st_date, "%b-%Y"), format(end_date, "%b-%Y"), sep = " to ")) %>% 
    mutate(date_label = factor(date_label, levels = date_label)) %>% 
    right_join(dat, by = "occasion")
  
  g <- dat %>% 
    mutate(move = (section_2 - section_1) * 20) %>% 
    filter(species == "STJ") %>% 
    drop_na(move) %>% 
    ggplot(aes(x = move, fill = factor(q99_event))) + 
    scale_fill_manual(values = c("grey", "salmon"),
                      name = NULL, label = c("Periods with no high flow", "Periods with high flow")) +
    geom_histogram(binwidth = 20) + 
    facet_wrap(ncol = 4,
               facets = ~date_label) +
    xlab("Distance moved (m)") +
    ylab("Count") +
    theme_bw()
    
  print(g)
  