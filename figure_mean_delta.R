
# library -----------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse)


# read data ---------------------------------------------------------------
  
  ## estimates
  file_name <- list.files('bayes_estimate', full.names = TRUE, pattern = "q99")
  list_data <- lapply(file_name, read_csv)
  
  dat_pred <- list_data %>% 
    bind_rows() %>% 
    rename(lower = "2.5%",
           median = "50%",
           upper = "97.5%") %>% 
    mutate(species = rep(c("BHC", "CRC", "STJ"), each = nrow(list_data[[1]])),
           param_id = str_remove_all(.$X1, pattern = "\\[.{1,}\\]")) %>% 
    filter(param_id %in% c("delta_wd", "delta_wod")) %>% 
    mutate(Flow = ifelse(str_detect(.$X1, "wd"),
                         "with disturbance",
                         "with no disturbance"),
           x_id = str_extract_all(.$X1, pattern = "\\[.{1,}\\]")) %>% 
    mutate(x_id = as.numeric(str_remove_all(.$x_id, pattern = "\\[|\\]")))
  
  ## fish data
  dat_fish <- read_csv('data_fmt/vector_data.csv') %>% 
    group_by(species) %>% 
    summarize(x_id = 1:100,
              length = seq(min(length_1, na.rm = T),
                           max(length_1, na.rm = T),
                           length = 100))
    
  
  ## merge
  dat_pred <- dat_pred %>% 
    left_join(dat_fish, by = c("x_id", "species"))
  
# plot --------------------------------------------------------------------

  ggplot(dat_pred) +
    geom_ribbon(aes(ymin = lower,
                    ymax = upper,
                    x = length,
                    fill = Flow),
                    alpha = 0.2) +
    geom_line(aes(x = length, y = median, color = Flow)) +
    facet_wrap(facets = ~ species, nrow = 1,
               scales = "free_x") + 
    ylab("Mean dispersal distance (m)") +
    xlab("Total body length (mm)")
  