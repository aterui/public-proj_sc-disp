
# library -----------------------------------------------------------------

  rm(list = ls(all.names = TRUE))
  pacman::p_load(tidyverse, runjags, loo)

# read data ---------------------------------------------------------------
  
  dat_raw <- read_csv("data_fmt/vector_data.csv")
  flow <- read.csv("data_fmt/flow_summary.csv")
  temp <- read.csv("data_fmt/temp_summary.csv")
  n_distinct(dat_raw$tag_id)
  
  var_set <- expand.grid(species = unique(dat_raw$species),
                         flow = c("q50", "q99"))
  
# MCMC setup --------------------------------------------------------------
  
  n.ad <- 100
  n.iter <- 8E+3
  n.thin <- max(3, ceiling(n.iter/500))
  burn <- ceiling(max(10, n.iter/2))
  Sample <- ceiling(n.iter/n.thin)
  
  
# run jags ----------------------------------------------------------------

for(i in 1:nrow(var_set)) {
    
  # data prep ---------------------------------------------------------------
    
    species <- var_set$species[i]
    FQ <- var_set$flow[i]
    
    ## select species
    dat <- dat_raw[dat_raw$species == species, ]
    
    ## data transformation (section number to meters)
    dat <- dat %>% 
      mutate(Y = 1 - is.na(section_2),
             X = section_2 * 20 - 10,
             Mu = section_1 * 20 - 10,
             stream_dummy = ifelse(stream == "Indian", 0, 1))
    
    ## combine environmental data
    dat <- dat %>% 
      left_join(flow, by = c("stream", "occasion")) %>% 
      left_join(temp, by = c("stream", "occasion")) %>% 
      mutate(scl_length = c(scale(length_1)),
             scl_temp = c(scale(mu_temp)),
             scl_q50 = c(scale(q50)),
             interval = julian_2 - julian_1,
             upper_limit = ifelse(stream == "Indian", 740, 520))
  
    ## row IDs with observations
    XID <- which(!is.na(dat$X))
    
    ## Flow metrics
    if(FQ == 'q99') {
      Flow <- dat$q99_event
      para <- c("b", "sigma", "mu.phi", "sigma.phi", "mu", "sigma", "loglik",
                "delta_wd", "delta_wod",
                "delta_l20_wd", "delta_l50_wd", "delta_l80_wd")
    } else {
      Flow <- dat$scl_q50
      para <- c("b", "sigma", "mu.phi", "sigma.phi", "mu", "sigma", "loglik")
    } 
    
  # data for JAGS -----------------------------------------------------------
    
    data_jags <- list(Y = dat$Y,
                      X = dat$X,
                      Mu = dat$Mu,
                      Nsample = nrow(dat),
                      Nt = n_distinct(dat$occasion),
                      UL = dat$upper_limit,
                      scl.Size = dat$scl_length,
                      Stream = dat$stream_dummy,
                      Flow = Flow,
                      scl.Temp = dat$scl_temp,
                      log.Int = log(dat$interval),
                      Occ = dat$occasion,
                      XID = XID,
                      
                      L20 = quantile(dat$scl_length, 0.2),
                      L50 = quantile(dat$scl_length, 0.5),
                      L80 = quantile(dat$scl_length, 0.8),
                      
                      X_length = seq(min(dat$scl_length, na.rm = T),
                                     max(dat$scl_length, na.rm = T),
                                     length = 100)
                      )
    
    inits <- replicate(3, list(b = c(3.5, rep(0.3, 5)), 
                               .RNG.name = "base::Wichmann-Hill", .RNG.seed = NA),
                       simplify = FALSE)
    
    for(i in 1:3) {
      inits[[i]]$.RNG.seed <- i
    }
    
    m <- read.jagsfile("bayes_model/model_laplace.R")
    post <- run.jags(m$model,
                     monitor = para,
                     data = data_jags,
                     n.chains = 3,
                     inits = inits,
                     method = "parallel",
                     burnin = burn,
                     sample = Sample,
                     adapt = n.ad,
                     thin = n.thin,
                     n.sims = 3,
                     modules = "glm")
  
    result <- MCMCvis::MCMCsummary(post$mcmc)
  
  # waic --------------------------------------------------------------------
    
    loglik <- sapply(XID,
                     function(i) unlist(post$mcmc[, paste0("loglik[", i, "]")]))
    WAIC <- waic(loglik)
  
  # save output -------------------------------------------------------------
    
    write.csv(result[!str_detect(rownames(result), "loglik"),], paste0("bayes_estimate/summary_", n.iter, species, FQ,".csv") )
    write.csv(WAIC$estimates, paste0("bayes_waic/waic_", n.iter, species, FQ,".csv") )
    
}
