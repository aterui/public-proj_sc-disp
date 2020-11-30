
# library -----------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse, kableExtra)


# data --------------------------------------------------------------------

  dat <- read_csv("data_fmt/vector_data.csv")
  
  tab <- dat %>% 
    group_by(stream, species) %>% 
    summarise(n_unique_cap = n_distinct(tag_id),
              n_unique_recap = n_distinct(tag_id[!is.na(section_2)]),
              n_replicate_cap = n(),
              n_replicate_recap = sum(!is.na(section_2))) %>% 
    ungroup() %>% 
    kbl(format = "latex",
        booktabs = T,
        escape = F,
        col.names = linebreak(c('Stream',
                               'Species',
                               'Capture\n(unique)',
                               'Recapture\n(unique)',
                               'Capture\n(total replicate)',
                               'Recapture\n(total replicate)'),
                              align = "c"))
  
  print(tab)