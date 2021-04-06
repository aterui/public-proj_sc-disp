
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

  ## estimated parameters
  file_name <- list.files('bayes_estimate', full.names = TRUE, pattern = "q99")
  list_data <- lapply(file_name, read_csv)
  
  coef <- list_data %>% 
    bind_rows() %>% 
    mutate(Species = rep(c("BHC", "CRC", "STJ"), each = nrow(list_data[[1]]))) %>% 
    filter(X1 %in% c('b[1]', 'b[2]', 'b[3]', 'b[4]', 'b[6]')) %>% 
    select(Effect = X1,
           Beta = "50%",
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
    mutate(Size = case_when(str_detect(scenario, 'len20') ~ 'Small (20th percentile)',
                            str_detect(scenario, 'len50') ~ 'Medium (50th percentile)',
                            str_detect(scenario, 'len80') ~ 'Large (80th percentile)'),
           Flow = case_when(str_detect(scenario, 'base') ~ 'With no disturbance',
                            str_detect(scenario, 'high') ~ 'With disturbance')) %>% 
    mutate(Size = factor(Size, levels = unique(Size)))
  
  ## prediction
  x <- 0:300
  dat_pred <- p_rate %>% 
    group_by(Species, scenario) %>% 
    summarise(y = dexp(x, rate),
              x = x,
              rate = unique(rate),
              Flow = unique(Flow),
              Size = unique(Size))
     
# plot design -------------------------------------------------------------
  
  ## plot theme
  plt_theme <- theme_bw() + theme(
    plot.background = element_blank(),
    
    panel.background = element_rect(grey(0.99)),
    panel.border = element_rect(),
    
    panel.grid = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    
    strip.background = element_blank(),
    strip.text.x = element_text(size = 10),
    strip.text.y = element_text(size = 10),
    axis.title = element_text(size = 10)
  )
  

# plot data ---------------------------------------------------------------

  theme_set(plt_theme)
  x <- 0:500
  
  g <- ggplot(dat_pred) +
    geom_line(aes(y = y, x = x, color = Size)) +
    geom_segment(aes(x = 1/rate, xend = 1/rate,
                     y = 0, yend = dexp(1/rate, rate),
                     color = Size),
                 size = 0.3, lty = 3) +
    geom_point(aes(x = 1/rate, y = 0, color = Size), size = 0.5) +
    facet_grid(rows = vars(Species),
               cols = vars(Flow),
               labeller = label_both) +
    scale_color_hue(name = "Body size") +
    xlab('Distance from origin (m)') +
    ylab('Probability density')
  
  print(g)  