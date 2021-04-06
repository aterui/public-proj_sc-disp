
# library -----------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse)


# read data ---------------------------------------------------------------

  file_name <- list.files('bayes_estimate', full.names = TRUE, pattern = "q99")
  list_data <- lapply(file_name, read_csv)
  
  dat_fig <- list_data %>% 
    bind_rows() %>% 
    mutate(Species = rep(c("Bluehead chub", "Creek chub", "Striped jumprock"), each = nrow(list_data[[1]]))) %>% 
    select(Species,
           Effect = X1,
           Estimate = "50%",
           Lower95 = "97.5%",
           Upper95 = "2.5%") %>% 
    filter(str_detect(Effect, "b")) %>% 
    mutate(Effect = case_when(Effect == 'b[1]' ~ 'Intercept',
                              Effect == 'b[2]' ~ 'High flow',
                              Effect == 'b[3]' ~ 'Body size',
                              Effect == 'b[4]' ~ 'High flow x body size',
                              Effect == 'b[5]' ~ 'Temperature',
                              Effect == 'b[6]' ~ 'Stream (vs. Indian)')
           ) %>% 
    mutate(Effect = factor(Effect, levels = rev(unique(Effect))))


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
  pd <- position_dodge(0.3)
  
  g <- dat_fig %>% 
   ggplot(aes(x = Estimate, y = Effect, color = Species)) +
   geom_errorbar(aes(xmin = Lower95, xmax = Upper95),
                 width = 0,
                 position = pd) +
   geom_point(position = pd) +
   geom_vline(xintercept = 0,
              lty = 2,
              col = "gray") +
   ylab(NULL)
  
  print(g)