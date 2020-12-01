
# library -----------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse, kableExtra)

# data --------------------------------------------------------------------

  dat <- read_csv("data_fmt/vector_data.csv")
  
  dat_tab <- dat %>% 
    group_by(stream, species) %>% 
    summarise(n_unique_cap = n_distinct(tag_id),
              n_unique_recap = n_distinct(tag_id[!is.na(section_2)]),
              n_replicate_cap = n(),
              n_replicate_recap = sum(!is.na(section_2))) %>% 
    ungroup() %>% 
    group_by(stream) %>% 
    mutate(stream = c(unique(stream), rep("", n()-1)))
  
  tab <- dat_tab %>% 
    kbl(format = "latex",
        booktabs = TRUE,
        escape = FALSE,
        col.names = linebreak(c('Stream',
                               'Species',
                               'Capture\n(unique)',
                               'Recapture\n(unique)',
                               'Capture\n(total replicate)',
                               'Recapture\n(total replicate)'),
                              align = "c")) %>% 
    kable_styling(latex_options = "hold_position")
  
  print(tab)
  