
# library -----------------------------------------------------------------

  pacman::p_load(tidyverse, kableExtra)

# read data ---------------------------------------------------------------

  filenames <- list.files(path = here::here("bayes_estimate"), full.names = TRUE, pattern = "q99")
  species <- rep(str_extract(unlist(filenames), c("BHC", "CRC", "STJ")), each = nrow(read_csv(filenames[1])))
  
  dat_tab <- lapply(filenames, read_csv) %>% 
    bind_rows() %>% 
    mutate(Species = species) %>% 
    select(Species,
           Effect = X1,
           Estimate = Median,
           'Lower 95% CI' = Lower95,
           'Upper 95% CI' = Upper95) %>% 
    filter(!(Effect %in% c('mu', 'sigma'))) %>% 
    mutate(Effect = case_when(Effect == 'b[1]' ~ 'Intercept',
                              Effect == 'b[2]' ~ 'High flow',
                              Effect == 'b[3]' ~ 'Body size',
                              Effect == 'b[4]' ~ 'High flow x body size',
                              Effect == 'b[5]' ~ 'Temperature',
                              Effect == 'b[6]' ~ 'Stream (vs. Indian)',
                              Effect == 'mu.phi' ~ 'Mean recapture prob. ($\\mu_{\\phi}$)',
                              Effect == 'sigma.phi' ~ 'SD of recapture prob. ($\\sigma_{\\phi}$)',
                              TRUE ~ as.character(Effect)))
  
  tab <- dat_tab %>% 
    group_by(Species) %>% 
    mutate(Species =c(unique(Species), rep(" ", n()-1))) %>% 
    kbl(booktabs = TRUE,
        digits = 2,
        format = 'pandoc') %>% 
    kable_styling(latex_options = "hold_position")
  
  print(tab)
  