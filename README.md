README
================

## Data

  - `data_org/` - source data for formatting
  - `data_fmt/` - formatted data
      - `vector_data.csv` - formatted fish data
          - `tag_id`: PIT tag id
          - `occasion`: sampling occasion at capture
          - `species`: species code
          - `stream`: stream name
          - `weight_1`: g wet weight at capture
          - `length_1`: mm total body length at capture
          - `section_1`: stream section number at capture
          - `julian_1`: julian date at capture
          - `weight_2`: g wet weight at recapture
          - `length_2`: mm total body length at recapture
          - `section_2`: stream section number at recapture
          - `julian_2`: julian date at recapture
          - `occasion_2`: sampling occasion at recapture
          - `diff_length`: length difference between capture and
            recapture
      - `flow_summary.csv` - formatted water level data
          - `occasion`: sampling occasion
          - `stream`: stream name
          - `q50`: median water level
          - `q99_event`: occurrence of extreme high flows exceeding 99th
            percentile of daily water levels
      - `temp_summary.csv` - formatted temperature data
          - `occasion`: sampling occasion
          - `stream`: stream name
          - `mu_temp`: mean temperature

## Script

### Formatting

  - `data_fmt_env` - format environmental data
  - `data_fmt_fish` - format fish data

### Data analysis (`bayes_model/`)

  - `inits_model_laplace.R` - R script to run a Bayes model
  - `model_laplace.R` - JAGS code for a Laplace dispersal model

### Figures & Tables

  - `figure_est` - figure for estimated parameters of bayesian dispersal
    model
  - `figure_kernel` - figure for estimated dispersal kernels
  - `si_figure_hist_bhc` - histogram for dispersal distance of bluehead
    chub
  - `si_figure_hist_crc` - histogram for dispersal distance of creek
    chub
  - `si_figure_hist_stj` - histogram for dispersal distance of striped
    jumprock
  - `si_table_est_q50` - table for estimated parameters of bayesian
    dispersal model (median flow)
  - `si_table_est_q99` - table for estimated parameters of bayesian
    dispersal model (high flow)
  - `si_table_mr_summary` - table for descriptive statistics of
    mark-recapture data
  - `si_table_waic` - table for WAIC comparisons

### rmd files

  - `figures` - rmarkdown file to compile figures
  - `support-info` - rmarkdown file to compile supporting information

## Session information

    ## R version 4.0.3 (2020-10-10)
    ## Platform: x86_64-w64-mingw32/x64 (64-bit)
    ## Running under: Windows 10 x64 (build 19042)
    ## 
    ## Matrix products: default
    ## 
    ## locale:
    ## [1] LC_COLLATE=English_United States.1252 
    ## [2] LC_CTYPE=English_United States.1252   
    ## [3] LC_MONETARY=English_United States.1252
    ## [4] LC_NUMERIC=C                          
    ## [5] LC_TIME=English_United States.1252    
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] forcats_0.5.0   stringr_1.4.0   dplyr_1.0.2     purrr_0.3.4    
    ## [5] readr_1.4.0     tidyr_1.1.2     tibble_3.0.4    ggplot2_3.3.2  
    ## [9] tidyverse_1.3.0
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_1.0.5       cellranger_1.1.0 pillar_1.4.6     compiler_4.0.3  
    ##  [5] dbplyr_1.4.4     tools_4.0.3      digest_0.6.27    lubridate_1.7.9 
    ##  [9] jsonlite_1.7.1   evaluate_0.14    lifecycle_0.2.0  gtable_0.3.0    
    ## [13] pkgconfig_2.0.3  rlang_0.4.8      reprex_0.3.0     cli_2.1.0       
    ## [17] rstudioapi_0.11  DBI_1.1.0        yaml_2.2.1       haven_2.3.1     
    ## [21] xfun_0.19        withr_2.3.0      xml2_1.3.2       httr_1.4.2      
    ## [25] knitr_1.30       fs_1.5.0         hms_0.5.3        generics_0.1.0  
    ## [29] vctrs_0.3.4      grid_4.0.3       tidyselect_1.1.0 glue_1.4.2      
    ## [33] R6_2.5.0         fansi_0.4.1      readxl_1.3.1     rmarkdown_2.5   
    ## [37] modelr_0.1.8     blob_1.2.1       magrittr_1.5     backports_1.1.10
    ## [41] scales_1.1.1     ellipsis_0.3.1   htmltools_0.5.0  rvest_0.3.6     
    ## [45] assertthat_0.2.1 colorspace_1.4-1 stringi_1.5.3    munsell_0.5.0   
    ## [49] broom_0.7.2      crayon_1.3.4
