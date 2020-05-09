# R script: Heterogeneous dispersal responses to external and internal factors in stream fishes

### analaysis_meanbodysize_ver2
Description: calculate mean body size  
Source file: "VectorData_MERGE2019-11-19.csv"  
Output file: NA  

### analysis_dispersal_distance_ver2
Description: mean dispersal distance  
Source file: "summary_8000", SP, "2019-11-20Q99.csv"  
Output file: NA  

### analysis_dispersal_length_ratio_ver2
Description: calculate dispersal and section length ratio  
Source file: "summary_8000", SP, "2019-11-20Q99.csv"  
Output file: NA  

### datasort_basicstats_ver2
Description: number of fish individuals recaptured, marked etc.  
Source file:  "VectorData_MERGE2019-11-19.csv"  
Output file: NA  

### datasort_environment_ver2
Description: sort environmental data (temperature and water level)  
Source file: "WaterTemp.csv"; "WaterLevel_edit.csv"; "Indian_final.csv"; "Todd_final.csv"  
Output file: "Env_QF99_", Sys.Date(), ".csv"; "Env_Q50_", Sys.Date(), ".csv"; "Env_Temp_mu_", Sys.Date(), ".csv"  

### datasort_mergeVectorData_ver2
Description: Merge vectorized fish data  
Source file: sapply(1:3, function(x)paste0("data/VectorData_", Species[x], "2019-11-19.csv"))  
Output file: "VectorData_MERGE", Sys.Date(), ".csv"  

### datasort_Vectorize_ver2
Description: Vectorize original data  
Source file: "Indian_final.csv"; "Todd_final.csv"  
Output file: "VectorData_", species, Sys.Date(), ".csv"  

### figure_dispersal_Indian_ver2
Description: Draw a figure for dispersal kernels  
Source file: "VectorData_MERGE2019-11-19.csv"; "result/summary_8000", SP, "2019-11-20Q99.csv"  
Output file: "figure_dispersal_Indian_ver2.pdf"  

### figure_dispersal_Todd_ver2
Description: Draw a figure for dispersal kernels  
Source file: "VectorData_MERGE2019-11-19.csv"; "result/summary_8000", SP, "2019-11-20Q99.csv"  
Output file: "figure_dispersal_Todd_ver2.pdf"  

### figure_raw_dispersal_ver2
Description: Draw a figure for dispersal histogram  
Source file: "VectorData_MERGE2019-11-19.csv"; "result/summary_8000", SP, "2019-11-20Q99.csv"  
Output file: "figure_raw_dispersal_ver2.pdf"  

### function_figure.R
Description: function for drawing a figure  
Source file: NA  
Output file: NA  
