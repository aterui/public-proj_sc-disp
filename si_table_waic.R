
# library -----------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse, kableExtra)

# read data ---------------------------------------------------------------

  filenames <- list.files(path = here::here("bayes_waic"), full.names = TRUE)
  species <- rep(unlist(lapply(filenames, function(x) c(na.omit(str_extract(x, pattern = c('BHC', 'CRC', 'STJ')))))),
                 each = 3)
  Q <- rep(unlist(lapply(filenames, function(x) c(na.omit(str_extract(x, pattern = c('q50', 'q99')))))),
           each = 3)
  
  dat_tab <- lapply(filenames, read_csv) %>% 
    bind_rows() %>% 
    mutate(Species = species,
           Flow = Q,
           Estimate = round(Estimate, 1)) %>% 
    filter(X1 == "waic") %>% 
    mutate(Flow = case_when(Flow == 'q99' ~ "High flow model",
                            Flow == 'q50' ~ "Median flow model",
                            TRUE ~ as.character(Flow)),
           Species = case_when(Species == "BHC" ~ "Bluehead chub",
                               Species == "CRC" ~ "Creek chub",
                               Species == "STJ" ~ "Striped jumprock")) %>% 
    select(Species,
           Flow,
           Estimate) %>% 
    pivot_wider(id_cols = Species,
                names_from = Flow,
                values_from = Estimate) 
    
  tab <- dat_tab %>% 
    kbl(format = "latex", booktabs = TRUE) %>% 
    add_header_above(c("", "WAIC" = 2)) %>% 
    kable_styling(latex_options = "hold_position")
  
  print(tab)
  