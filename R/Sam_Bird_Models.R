library(tidyverse)
library(brms)
library(tidybayes)
library(cowplot)
library(ape)

#load("~/Downloads/Stability_Acoustic_Indices.rda")
#load("~/Downloads/Stability_Species_Detections.rda")
#load("~/Downloads/all_landuse.rda")
load(here("Data/Stability_Acoustic_Indices.rda"))
load(here("Data/Stability_Species_Detections.rda"))
load(here("Data/all_landuse.rda"))
Landuse_1000<-Landuse_1000[,c(1:3,11,12)] # cut out raw landuse values to keep relevant PC axes and lat long for spatial models
Site_order<-Landuse_1000$site_id[order(Landuse_1000$PC1)]

# NDSI - negative change after typhoon
dat_pre<-tidy.stability_AI %>%
  filter(Index %in% "NDSI" & Stability_dimension %in% 'Baseline') 
dat_post<-tidy.stability_AI %>%
  filter(Index %in% "NDSI" & Stability_dimension %in% 'Mean_post')
dat_pre<-dat_pre[complete.cases(dat_pre),]
dat_post<-dat_post[complete.cases(dat_post),]
dat_pre$Typhoon = rep("Pre", nrow(dat_pre))
dat_post$Typhoon = rep("Post", nrow(dat_post))
df <- rbind(dat_pre, dat_post)
names(df)[1] <- names(Landuse_1000)[1]
df <- left_join(df, Landuse_1000, by = "site_id")

# change levels for model
df$kmeans<-df$kmeans %>% parse_character() %>% parse_factor(levels = c('Forest','Developed'))
df$Typhoon<-df$Typhoon %>% parse_character() %>% parse_factor(levels = c('Pre','Post'))
#df$site_id<-df$site_id %>% parse_character() %>% parse_factor(levels = c(df$site_id[order(df$PC1)]))

mod_nonspatial_beta <- 
  brm(data = df, family = Beta(),
      Stability ~ 1 + kmeans * Typhoon + (1|site_id),
      iter = 5e4, warmup = 5000, chains = 4, cores = 4, thin = 2,
      seed = 666)
mod_nonspatial_beta <- add_criterion(mod_nonspatial_beta, "loo")

#check MCMC traces
brms::mcmc_plot(mod_nonspatial_beta, type = "trace") + theme_cowplot()
#check for agreement of chains
brms::mcmc_plot(mod_nonspatial_beta, type = "dens_overlay") + theme_cowplot()
# plot posterior estimates of fixed effects
brms::mcmc_plot(mod_nonspatial_beta, type = "intervals",prob = 0.68, prob_outer = 0.95, variable = "^b_", regex = TRUE) + theme_cowplot()

# Plot posterior typhoon effect across sites
mut_mod<-mod_nonspatial_beta %>%
  spread_draws(b_TyphoonPost, r_site_id[site_id,]) %>%
  mutate(site_mean = b_TyphoonPost + r_site_id)

# determine whether credible intervals span zero, and store as binary (to show in plot): 

mut_mod$site_mean[mut_mod$site_id %in% mut_mod$site_id[1]]




mut_mod %>%
  ggplot(aes(y = site_id %>% as.character %>% parse_factor(levels = Site_order), 
             x = site_mean, 
             fill = stat(x) > 0)) + 
  stat_halfeye(show.legend = F) +
  geom_vline(xintercept = 0, 
             linetype = "dashed") +
  scale_fill_manual(values = c("skyblue","gray80")) +
  labs(x = "Site_mean",
       y = "Site") + 
  cowplot::theme_minimal_grid(font_size = 14,
                              colour = "grey92")

# Parameter fits and stats - Rhat values closer to 1 and n_eff values > 1000 are ideal.
mod_nonspatial_beta$fit

# pseudo r-squared of model
bayes_R2(mod_nonspatial_beta)
# simulate data from 500 random draws of posterior and compare it to observed data
# the black line should run throught he center of the blue lines
pp_check(mod_nonspatial_beta, ndraws = 500) + theme_cowplot()

# check for spatial autocorrelation in residuals.
bres <- residuals(mod_nonspatial_beta)[,"Estimate"]
# make distance matrix 
d_mat = as.matrix(dist(df[,c("Lat", "Long")], diag=T, upper=T))
d_mat_inv <- 1/d_mat
d_mat_inv[which(d_mat_inv == Inf)] <- 0
ape::Moran.I(bres, d_mat_inv)

################################################################
# NDSI_bio - No effect of typhoon
dat_pre<-tidy.stability_AI %>%
  filter(Index %in% "NDSI_Bio" & Stability_dimension %in% 'Baseline') 
dat_post<-tidy.stability_AI %>%
  filter(Index %in% "NDSI_Bio" & Stability_dimension %in% 'Mean_post')
dat_pre<-dat_pre[complete.cases(dat_pre),]
dat_post<-dat_post[complete.cases(dat_post),]
dat_pre$Typhoon = rep("Pre", nrow(dat_pre))
dat_post$Typhoon = rep("Post", nrow(dat_post))
df <- rbind(dat_pre, dat_post)
names(df)[1] <- names(Landuse_1000)[1]
df <- left_join(df, Landuse_1000, by = "site_id")

# Fit bayesian mixed effects model
mod_nonspatial_beta <- 
  brm(data = df, family = Beta(),
      Stability ~ 1 + kmeans + Typhoon + (1|site_id),
      iter = 5e4, warmup = 5000, chains = 4, cores = 4, thin = 2,
      seed = 666)
mod_nonspatial_beta <- add_criterion(mod_nonspatial_beta, "loo")

#check MCMC traces
brms::mcmc_plot(mod_nonspatial_beta, type = "trace") + theme_cowplot()
#check for agreement of chains
brms::mcmc_plot(mod_nonspatial_beta, type = "dens_overlay") + theme_cowplot()
# plot posterior probabilities
brms::mcmc_plot(mod_nonspatial_beta, type = "intervals",prob = 0.68, prob_outer = 0.95, variable = "^b_", regex = TRUE) + theme_cowplot()

# Plot typhoon effect across sites
mod_nonspatial_beta %>%
  spread_draws(b_TyphoonPre, r_site_id[site_id,]) %>%
  mutate(site_mean = b_TyphoonPre + r_site_id) %>%
  ggplot(aes(y = site_id, x = site_mean, fill = stat(x) > 0)) + stat_halfeye() +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = c("gray80", "skyblue")) + cowplot::theme_minimal_grid()

bayes_R2(mod_nonspatial_beta)

bres <- residuals(mod_nonspatial_beta)[,"Estimate"]
d_mat = as.matrix(dist(df[,c("Lat", "Long")], diag=T, upper=T))
d_mat_inv <- 1/d_mat
d_mat_inv[which(d_mat_inv == Inf)] <- 0
ape::Moran.I(bres, d_mat_inv) # no spatial autocorrelation

################################################################
# NDSI_Anth - positive increase after typhoon
dat_pre<-tidy.stability_AI %>%
  filter(Index %in% "NDSI_Anth" & Stability_dimension %in% 'Baseline') 
dat_post<-tidy.stability_AI %>%
  filter(Index %in% "NDSI_Anth" & Stability_dimension %in% 'Mean_post')
dat_pre<-dat_pre[complete.cases(dat_pre),]
dat_post<-dat_post[complete.cases(dat_post),]
dat_pre$Typhoon = rep("Pre", nrow(dat_pre))
dat_post$Typhoon = rep("Post", nrow(dat_post))
df <- rbind(dat_pre, dat_post)
names(df)[1] <- names(Landuse_1000)[1]
df <- left_join(df, Landuse_1000, by = "site_id")

# Fit bayesian mixed effects model
mod_nonspatial_beta <- 
  brm(data = df, family = Beta(),
      Stability ~ 1 + kmeans + Typhoon + (1|site_id),
      iter = 5e4, warmup = 5000, chains = 4, cores = 4, thin = 2,
      seed = 666)
mod_nonspatial_beta <- add_criterion(mod_nonspatial_beta, "loo")

#check MCMC traces
brms::mcmc_plot(mod_nonspatial_beta, type = "trace") + theme_cowplot()
#check for agreement of chains
brms::mcmc_plot(mod_nonspatial_beta, type = "dens_overlay") + theme_cowplot()
# plot posterior probabilities
brms::mcmc_plot(mod_nonspatial_beta, type = "intervals",prob = 0.68, prob_outer = 0.95, variable = "^b_", regex = TRUE) + theme_cowplot()

# Plot typhoon effect across sites
mod_nonspatial_beta %>%
  spread_draws(b_TyphoonPre, r_site_id[site_id,]) %>%
  mutate(site_mean = b_TyphoonPre + r_site_id) %>%
  ggplot(aes(y = site_id, x = site_mean, fill = stat(x) > 0)) + stat_halfeye() +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = c("gray80", "skyblue")) + cowplot::theme_minimal_grid()

bayes_R2(mod_nonspatial_beta)
pp_check(mod_nonspatial_beta, ndraws = 500) + theme_cowplot()

bres <- residuals(mod_nonspatial_beta)[,"Estimate"]
d_mat = as.matrix(dist(df[,c("Lat", "Long")], diag=T, upper=T))
d_mat_inv <- 1/d_mat
d_mat_inv[which(d_mat_inv == Inf)] <- 0
ape::Moran.I(bres, d_mat_inv)


##### BIRD SPECIES #####
# All combined ##
dat_pre<-tidy.stability_bird %>%
  filter(Cutoff %in% 0.5 & Stability_dimension %in% 'Baseline') 
dat_post<-tidy.stability_bird %>%
  filter(Cutoff %in% 0.5 & Stability_dimension %in% 'Mean_post') 
dat_pre<-dat_pre[complete.cases(dat_pre),]
dat_post<-dat_post[complete.cases(dat_post),]
dat_pre$Typhoon = rep("Pre", nrow(dat_pre))
dat_post$Typhoon = rep("Post", nrow(dat_post))
df <- rbind(dat_pre, dat_post)
names(df)[1] <- names(Landuse_1000)[1]
df <- left_join(df, Landuse_1000, by = "site_id")

# Fit bayesian mixed effects model
mod_nonspatial_lnorm <- 
  brm(data = df, family = lognormal(),
      Stability ~ 1 + kmeans + Typhoon * Species_ID + (1|site_id),
      iter = 5e4, warmup = 5000, chains = 4, cores = 4, thin = 2,
      seed = 666)
mod_nonspatial_lnorm <- add_criterion(mod_nonspatial_lnorm, "loo")

#check MCMC traces
brms::mcmc_plot(mod_nonspatial_lnorm, type = "trace") + theme_cowplot()
#check for agreement of chains
brms::mcmc_plot(mod_nonspatial_lnorm, type = "dens_overlay") + theme_cowplot()
# plot posterior probabilities
brms::mcmc_plot(mod_nonspatial_lnorm, type = "intervals",prob = 0.68, prob_outer = 0.95, variable = "^b_", regex = TRUE) + theme_cowplot()

corvusplot <- mod_nonspatial_lnorm %>%
  spread_draws(b_TyphoonPre, r_site_id[site_id,]) %>%
  mutate(site_mean = b_TyphoonPre + r_site_id) %>%
  ggplot(aes(y = site_id, x = site_mean, fill = stat(x) > 0)) + stat_halfeye() +
  geom_vline(xintercept = 0, linetype = "dashed") + ylab("") +
  scale_fill_manual(values = c("gray80", "skyblue")) + cowplot::theme_minimal_grid() + theme(legend.position = "none")

horornisplot <- mod_nonspatial_lnorm %>%
  spread_draws(b_TyphoonPre, r_site_id[site_id,]) %>%
  mutate(site_mean = b_TyphoonPre + 1.91 + r_site_id) %>%
  ggplot(aes(y = site_id, x = site_mean, fill = stat(x) > 0)) + stat_halfeye() +
  geom_vline(xintercept = 0, linetype = "dashed") + ylab("") +
  scale_fill_manual(values = c("gray80", "skyblue")) + cowplot::theme_minimal_grid() + theme(legend.position = "none")

otusplot <- mod_nonspatial_lnorm %>%
  spread_draws(b_TyphoonPre, r_site_id[site_id,]) %>%
  mutate(site_mean = b_TyphoonPre + 0.38 + r_site_id) %>%
  ggplot(aes(y = site_id, x = site_mean, fill = stat(x) > 0)) + stat_halfeye() +
  geom_vline(xintercept = 0, linetype = "dashed") + ylab("") +
  scale_fill_manual(values = c("gray80", "skyblue")) + cowplot::theme_minimal_grid() + theme(legend.position = "none")

plot_grid(corvusplot, otusplot, horornisplot, ncol = 3, align = "hv", labels = c("Corvus", "Otus", "Horornis"))

bayes_R2(mod_nonspatial_lnorm)

bres <- residuals(mod_nonspatial_lnorm)[,"Estimate"]
d_mat = as.matrix(dist(df[,c("Lat", "Long")], diag=T, upper=T))
d_mat_inv <- 1/d_mat
d_mat_inv[which(d_mat_inv == Inf)] <- 0
ape::Moran.I(bres, d_mat_inv)

# good fit to data
pp_check(mod_nonspatial_lnorm, ndraws = 500) + theme_cowplot() +  scale_x_continuous(limits = c(0,50))



