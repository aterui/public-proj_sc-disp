
# library -----------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse, runjags)

# read data ---------------------------------------------------------------
  
  dat_raw <- read_csv("data_fmt/vector_data.csv")
  flow <- read.csv("data_fmt/flow_summary.csv")
  temp <- read.csv("data_fmt/temp_summary.csv")
  
  n_distinct(dat_raw$tag_id)
  
# data prep ---------------------------------------------------------------
  
  # data with questionable length are removed ('growth' with less than -5 mm)
  dat <- dat_raw %>% 
    mutate(Y = 1 - is.na(section_2),
           X = section_2,
           Mu = section_1,
           stream_dummy = ifelse(stream == "Indian", 0, 1)) %>% 
    mutate(diff_length = length_2 - length_1) %>%
    mutate(diff_length = ifelse(is.na(diff_length), 0, diff_length)) %>% 
    filter(diff_length > -6)    
  
  dat <- dat %>% 
    left_join(flow, by = c("stream", "occasion")) %>% 
    left_join(temp, by = c("stream", "occasion")) %>% 
    mutate(scl_length = c(scale(length_1)),
           scl_temp = c(scale(mu_temp)),
           scl_q50 = c(scale(q50)),
           interval = julian_2 - julian_1,
           upper_limit = ifelse(stream == "Indian", 740, 520))
  
# MCMC setup --------------------------------------------------------------

  n.ad <- 100
  n.iter <- 1E+3
  n.thin <- max(3, ceiling(n.iter/500))
  burn <- ceiling(max(10, n.iter/2))
  Sample <- ceiling(n.iter/n.thin)
  
# data for JAGS -----------------------------------------------------------
  
  ## select species
  dat <- filter(dat, species == "CRC")
    
  data_jags <- list(Y = dat$Y, X = dat$X, Mu = dat$Mu,
                    Nsample = nrow(dat), Nt = n_distinct(dat$occasion),
                    UL = dat$upper_limit, scl.Size = dat$scl_length, Stream = dat$stream_dummy,
                    Flow = dat$q99_event, scl.Temp = dat$scl_temp,
                    log.Int = log(dat$interval),
                    Occ = dat$occasion, XID = which(!(is.na(dat$X))))
  
  para <- c("b", "sigma", "mu.phi", "sigma.phi", "mu", "sigma", "loglik")
  inits <- replicate(3, list(b = c(3.5, rep(0.3, 5)), 
                             .RNG.name="base::Wichmann-Hill", .RNG.seed = NA), simplify = FALSE)
  for(i in 1:3){ inits[[i]]$.RNG.seed <- i }
  
  m <- read.jagsfile("bayes_model/model_laplace.R")
  post <- run.jags(m$model, monitor = para, data = data_jags,
                   n.chains = 3, inits = inits, method = "parallel",
                   burnin = burn, sample = Sample, adapt = n.ad, thin = n.thin,
                   n.sims = 3, modules = "glm")
  
# Output ----
  source("function_jags2bugs.R")
  re <- jags2bugs(post$mcmc)
  print(re, 2)
  PP <- sapply(1:ncol(re$sims.matrix), function(x) mean(re$sims.matrix[,x]>0) )
  PN <- 1-PP

# WAIC ----
  library(loo)
  loglik <- sapply(XID, function(i) unlist( post$mcmc[, paste0("loglik[", i, "]") ] ) )
  WAIC <- waic(loglik)
  
# Save output  
  #write.csv(cbind(re$summary[,c(1,5,3,7,8,9)], PP, PN), paste0("result/summary_", n.iter, species, Sys.Date(), FQ,".csv") )
  #write.csv(re$sims.matrix, paste0("result/MCMCsample_", n.iter, species, Sys.Date(), FQ,".csv") )
  #write.csv(WAIC$estimates, paste0("result/WAIC_", n.iter, species, Sys.Date(), FQ,".csv") )
  