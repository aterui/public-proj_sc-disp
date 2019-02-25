#1 datasort_Vectorize.R
description: vectorize data
source file: "Todd_final.csv" or "Indian_final.csv"
output file: "Vdata_streamID_speciesIDDATE.csv"

#2  datasort_environment.R
description: edit water level data
source file: "WaterLevel.csv"
output file: "WaterLevel_edit.csv"

#3 datasort_Env_Dispersal_combo.R
description: combine environment and dispersal data
source file: "Vdata_streamID_speciesIDDate.csv", "WaterLevel_edit.csv", "WaterTemp_data.csv"
output file: "data_itgDATE.csv"

#4 inits_model_laplace.R
description: R script for running a JAGS model
source file: "data_itgDATE.csv"
output file: NA

#5 model_laplace.R
description: JAGS script for a laplace model
source file: NA
output file: NA
note: calling from "inits_model_laplace.R"


