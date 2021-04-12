
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
    mutate(Species = rep(c("Bluehead chub", "Creek chub", "Striped jumprock"),
                         each = nrow(list_data[[1]])),
           param_id = str_remove_all(.$X1, pattern = "\\[.{1,}\\]")) %>% 
    filter(param_id %in% c("delta_wd", "delta_wod")) %>% 
    mutate(Flow = ifelse(str_detect(.$X1, "wd"),
                         "with high flow",
                         "with no high flow"),
           x_id = str_extract_all(.$X1, pattern = "\\[.{1,}\\]")) %>% 
    mutate(x_id = as.numeric(str_remove_all(.$x_id, pattern = "\\[|\\]")))
  
  ## fish data
  dat_fish <- read_csv('data_fmt/vector_data.csv') %>% 
    mutate(Species = case_when(species == "BHC" ~ "Bluehead chub",
                               species == "CRC" ~ "Creek chub",
                               species == "STJ" ~ "Striped jumprock"))
  
  dat_quantile <- dat_fish %>% 
    group_by(Species) %>% 
    summarize(q = quantile(length_1, c(0.2, 0.5, 0.8)))
    
  dat_length <- dat_fish %>% 
    group_by(Species) %>% 
    summarize(x_id = 1:100,
              length = seq(min(length_1, na.rm = T),
                           max(length_1, na.rm = T),
                           length = 100))
    
  
  ## merge
  dat_pred <- dat_pred %>% 
    left_join(dat_length, by = c("x_id", "Species"))
  

# plot theme --------------------------------------------------------------

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
  
  
# plot --------------------------------------------------------------------
  
  theme_set(plt_theme)
  
  g <- ggplot(dat_pred) +
    geom_ribbon(aes(ymin = lower,
                    ymax = upper,
                    x = length,
                    fill = Flow),
                alpha = 0.2) +
    geom_line(aes(x = length, y = median, color = Flow)) +
    geom_point(data = dat_quantile,
               aes(x = q, y = 0), shape = 25) + 
    facet_wrap(facets = ~ Species, nrow = 1,
               scales = "free_x") + 
    ylab("Mean dispersal distance (m)") +
    xlab("Total body length (mm)")
  
  print(g)