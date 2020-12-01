
# library -----------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse, egg)

# read data ---------------------------------------------------------------
  ## length data
  dat_length <- read_csv('data_fmt/vector_data.csv') %>% 
    group_by(species) %>% 
    summarise(length20 = quantile(scale(length_1), 0.2),
              length50 = quantile(scale(length_1), 0.5),
              length80 = quantile(scale(length_1), 0.8)
    )
  
  ## length data
  length_summary <- read_csv('data_fmt/vector_data.csv') %>% 
    group_by(species) %>% 
    summarise(mean = mean(length_1),
              sd = sd(length_1),
              q20 = quantile(length_1, 0.2),
              q50 = quantile(length_1, 0.5),
              q80 = quantile(length_1, 0.8),
              cv = sd/mean,
              n = n(),
              n_unique = n_distinct(tag_id),
              n_recap = sum(!is.na(section_2))
    )
  
  print(length_summary)
  
  ## estimated parameters
  file_name <- list.files('bayes_estimate', full.names = TRUE, pattern = "q99")
  list_data <- lapply(file_name, read_csv)
  
  coef <- list_data %>% 
    bind_rows() %>% 
    mutate(Species = rep(c("BHC", "CRC", "STJ"), each = nrow(list_data[[1]]))) %>% 
    filter(X1 %in% c('b[1]', 'b[2]', 'b[3]', 'b[4]', 'b[6]')) %>% 
    select(Effect = X1,
           Beta = Median,
           Species) %>%
    left_join(dat_length, by = c('Species' = 'species')) %>% 
    mutate(flow0 = 0,
           flow1 = 1)

  ## transform to rate parameters
  p_rate <- coef %>% 
    group_by(Species) %>% 
    summarise(len20_base = c(c(1, flow0[1], length20[1], length20[1]*flow0[1], 0.5) %*% Beta),
              len50_base = c(c(1, flow0[1], length50[1], length50[1]*flow0[1], 0.5) %*% Beta),
              len80_base = c(c(1, flow0[1], length80[1], length80[1]*flow0[1], 0.5) %*% Beta),
              len20_high = c(c(1, flow1[1], length20[1], length20[1]*flow1[1], 0.5) %*% Beta),
              len50_high = c(c(1, flow1[1], length50[1], length50[1]*flow1[1], 0.5) %*% Beta),
              len80_high = c(c(1, flow1[1], length80[1], length80[1]*flow1[1], 0.5) %*% Beta)
    ) %>% 
    group_by(Species) %>% 
    summarise(across(.cols = where(is.numeric), .fns = ~ 1/exp(.x))) %>% 
    pivot_longer(cols = starts_with('len'),
                 names_to = "scenario",
                 values_to = 'rate') %>% 
    mutate(mu_distance = 1/rate) %>% 
    filter(str_detect(scenario, "80"))
  
  print(p_rate)