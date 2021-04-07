
# setup -------------------------------------------------------------------
  
  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse)
  dat <- read_csv('data_fmt/vector_data.csv')

# back & forth movement ---------------------------------------------------
  
  set.seed(123)
  
  ## select individuals with repeated catch
  tag_id_rep <- dat %>% 
    group_by(species, tag_id) %>% 
    summarize(n_release = n()) %>% 
    filter(n_release > 5) %>% 
    sample_n(10) %>% 
    pull(tag_id)
  
  dat %>% 
    filter(tag_id %in% tag_id_rep) %>% 
    ggplot() +
    geom_point(aes(x = occasion, y = section_1, color = tag_id),
               alpha = 0.5) +
    geom_line(aes(x = occasion, y = section_1, color = tag_id),
              alpha = 0.5) +
    facet_wrap(facets = ~ species,) + 
    ylab("Section ID") +
    xlab("Period") +
    theme_bw() +
    theme(legend.position = "none")
