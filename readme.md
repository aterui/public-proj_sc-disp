# R script: Plastic dispersal responses to external and internal factors in stream fishes

### datasort_basicstats.R
Description: descriptive statistics for marked and recaptured individuals  
Source file: "data_itg2019-03-29.csv"  
Output file: NA  

### datasort_Vectorize.R
Description: vectorize data  
Source file: "Todd_final.csv" or "Indian_final.csv"  
Output file: "Vdata_streamID_speciesIDDATE.csv"  

### datasort_environment.R
Description: edit water level data  
Source file: "WaterLevel.csv"  
Output file: "WaterLevel_edit.csv"  

### datasort_Env_Dispersal_combo.R
Description: combine environment and dispersal data  
Source file: "Vdata_streamID_speciesIDDATE.csv", "WaterLevel_edit.csv", "WaterTemp_data.csv"  
Output file: "data_itgDATE.csv"  

### inits_model_laplace.R
Description: R script for running a JAGS model  
Source file: "data_itgDATE.csv"  
Output file: NA  

### model_laplace.R
Description: JAGS script for a laplace model  
Source file: NA  
Output file: NA  
Note: calling from "inits_model_laplace.R"  

### figure_raw_dispersal.R
Description: script for figures S1-S3  
Source file: "data_itg2019-03-29.csv"  
Output file: "figure_raw_dispersal.pdf"  

### figure_dispersal.R
Description: script for figure 2  
Source file: "summary_speciesID_2019-04-05Q99.csv.csv"  
Output file: "figure_dispersal.pdf"  

### figure_raw_dispersal.R
Description: script for figures S1-S3  
Source file: "data_itg2019-03-29.csv"  
Output file: "figure_raw_dispersal.pdf"  

### analaysis_meanbodysize.R
Description: script for mean body size  
Source file: "data_itg2019-03-29.csv"  
Output file: NA  

### analaysis_mean_dispersal_distance.R
Description: script for mean dispersal distance relative to the length of study section  
Source file: "summary_speciesID_2019-04-05Q99.csv.csv"  
Output file: NA  
