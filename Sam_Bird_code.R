library(mcp)
library(rjags)
library(patchwork)
library(tidyverse)
library(cowplot)
library(EnvCpt)
library(dplyr)
library(lubridate)

### Load data
load("~/Desktop/all_AI_breakpoint_data.rda")
unique(tidy.spatial_AI$response_group)

df =tidy.spatial_AI %>% filter(Index == "NDSI" & response_group == "Total_var")

df2 = df %>%
  slice(which(row_number() %% 12 == 1)) %>% # subset to every 6 hours (good tradeoff between MCMC speed and data resolution)
  #mutate(Date_Time = yday(Date_Time)) %>%
  group_by(Date_Time) %>%
  summarize(Stability = mean(Stability))


df2$Date_Time<-df2$Date_Time %>%  julian(origin = as.POSIXct("2018-01-01")) %>% as.numeric() # convert to numeric date format for model
df2$Date_Time<-df2$Date_Time - min(df2$Date_Time) # scale date to start at zero for model

# get predicted breakpoint locations
psis = c(271, 278)

# create time series
tsData <- ts(
  c(df2$Stability),
  frequency = 28
)
#detrend weekly cycles
detrended <- stl(tsData, s.window = 28)
plot(detrended)
# new data frame with detrended data
trend = data.frame(Stability = as.numeric(detrended$time.series[,"trend"]), Date_Time = df2$Date_Time + 242.5000)

# Intercept-only model (no cp)
model0 = list(Stability ~ 1)
fit_mcp0 = mcp(model0, data = trend, par_x = "Date_Time", 
               chains=8, cores = 8, adapt = 10000)

# Model with two breakpoints
model1 = list(Stability ~ 1, 1~ 1, 1~1)  # two intercept-only segments
fit_mcp1 = mcp(model1, data = trend, par_x = "Date_Time", 
               chains=8, cores = 8, adapt = 10000, 
               inits = list(cp_1 = 275, cp_2 = 290))  
plot(fit_mcp1) + geom_vline(xintercept = psis)
plot_pars(fit_mcp1, pars = c("cp_1", "cp_2"))


# model with 3 breakpoints
model2 = list(Stability ~ 1, 1~ 1, 1~1, 1~1)  # three intercept-only segments
prior = list(
  cp_1 = "dunif(260,277)", # uniform priors truncated at specified points
  cp_2 = "dunif(270,285)",  
  cp_3 = "dunif(285,300)" 
)
fit_mcp2 = mcp(model2, data = trend, par_x = "Date_Time", 
               chains=8, cores = 8, adapt = 10000, 
               prior = prior)
plot(fit_mcp2) + geom_vline(xintercept = psis)
plot_pars(fit_mcp2, pars = c("cp_1", "cp_2", "cp_3"))

# model comparison
fit_mcp0$loo = loo(fit_mcp0)
fit_mcp1$loo = loo(fit_mcp1)
fit_mcp2$loo = loo(fit_mcp2)
loo::loo_compare(fit_mcp0$loo, fit_mcp1$loo, fit_mcp2$loo)


# do same for just forest var
df2 = tidy.spatial_AI %>% filter(Index == "NDSI" & response_group == "Forest_Var") %>%
  slice(which(row_number() %% 12 == 1)) %>% # subset to every 6 hours (good tradeoff between MCMC speed and data resolution)
  group_by(Date_Time) %>% summarize(Stability = mean(Stability))
df2$Date_Time<-df2$Date_Time %>%  julian(origin = as.POSIXct("2018-01-01")) %>% as.numeric() # convert to numeric date format for model
df2$Date_Time<-df2$Date_Time - min(df2$Date_Time) # scale date to start at zero for model
tsData <- ts(c(df2$Stability),frequency = 28)
#detrend weekly cycles
detrended <- stl(tsData, s.window = 28)
plot(detrended)
# new data frame with detrended data
trend = data.frame(Stability = as.numeric(detrended$time.series[,"trend"]), Date_Time = df2$Date_Time + 242.5000)

model2 = list(Stability ~ 1, 1~ 1, 1~1, 1~1)  # three intercept-only segments
prior = list(
  cp_1 = "dunif(260,277)", # uniform priors truncated at specified points
  cp_2 = "dunif(270,285)",  
  cp_3 = "dunif(285,300)" 
)
fit_mcp2 = mcp(model2, data = trend, par_x = "Date_Time", 
               chains=8, cores = 8, adapt = 10000, 
               prior = prior)
plot(fit_mcp2) + geom_vline(xintercept = psis)
plot_pars(fit_mcp2, pars = c("cp_1", "cp_2", "cp_3"))



# do same for just developed var
df2 = tidy.spatial_AI %>% filter(Index == "NDSI" & response_group == "Developed_Var") %>%
  slice(which(row_number() %% 12 == 1)) %>% # subset to every 6 hours (good tradeoff between MCMC speed and data resolution)
  group_by(Date_Time) %>% summarize(Stability = mean(Stability))
df2$Date_Time<-df2$Date_Time %>%  julian(origin = as.POSIXct("2018-01-01")) %>% as.numeric() # convert to numeric date format for model
df2$Date_Time<-df2$Date_Time - min(df2$Date_Time) # scale date to start at zero for model
tsData <- ts(c(df2$Stability),frequency = 28)
#detrend weekly cycles
detrended <- stl(tsData, s.window = 28)
plot(detrended)
# new data frame with detrended data
trend = data.frame(Stability = as.numeric(detrended$time.series[,"trend"]), Date_Time = df2$Date_Time + 242.5000)

model2 = list(Stability ~ 1, 1~ 1, 1~1, 1~1)  # three intercept-only segments
prior = list(
  cp_1 = "dunif(265,275)", # uniform priors truncated at specified points
  cp_2 = "dunif(275,285)",  
  cp_3 = "dunif(285,300)" 
)
fit_mcp2 = mcp(model2, data = trend, par_x = "Date_Time", 
               chains=8, cores = 8, adapt = 10000, 
               prior = prior)
plot(fit_mcp2) + geom_vline(xintercept = psis)
plot_pars(fit_mcp2, pars = c("cp_1", "cp_2", "cp_3"))

# do same for NDSI_BIO
df2 = tidy.spatial_AI %>% filter(Index == "NDSI_Bio" & response_group == "Total_var") %>%
  slice(which(row_number() %% 12 == 1)) %>% # subset to every 6 hours (good tradeoff between MCMC speed and data resolution)
  group_by(Date_Time) %>% summarize(Stability = mean(Stability))
df2$Date_Time<-df2$Date_Time %>%  julian(origin = as.POSIXct("2018-01-01")) %>% as.numeric() # convert to numeric date format for model
df2$Date_Time<-df2$Date_Time - min(df2$Date_Time) # scale date to start at zero for model
tsData <- ts(c(df2$Stability),frequency = 28)
#detrend weekly cycles
detrended <- stl(tsData, s.window = 28)
plot(detrended)
# new data frame with detrended data
trend = data.frame(Stability = as.numeric(detrended$time.series[,"trend"]), Date_Time = df2$Date_Time + 242.5000)

model2 = list(Stability ~ 1, 1~ 1, 1~1, 1~1)  # three intercept-only segments
prior = list(
  cp_1 = "dunif(265,275)", # uniform priors truncated at specified points
  cp_2 = "dunif(275,285)",  
  cp_3 = "dunif(285,300)" 
)
fit_mcp2 = mcp(model2, data = trend, par_x = "Date_Time", 
               chains=8, cores = 8, adapt = 10000, 
               prior = prior)
plot(fit_mcp2) + geom_vline(xintercept = psis)
plot_pars(fit_mcp2, pars = c("cp_1", "cp_2", "cp_3"))



#################################################
load("~/Desktop/all_bird_breakpoint_data.rda")
unique(tidy.spatial_bird$response_group)

df =tidy.spatial_bird %>% filter(Species == "Corvus_macrorhynchos" & response_group == "Total_Var")

df2 = df %>%
  mutate(Date_Time = yday(Date)) %>%
  group_by(Date_Time) %>%
  summarize(Stability = mean(Stability))

df2$Date_Time<-df2$Date_Time %>% as.Date() %>%  julian(origin = as.POSIXct("2018-01-01")) %>% as.numeric() # convert to numeric date format for model
df2$Date_Time<-df2$Date_Time - min(df2$Date_Time) # scale date to start at zero for model

psis = c(30, 37)

# Intercept-only model (no cp)
model0 = list(Stability ~ 1)
fit_mcp0 = mcp(model0, data = df2, par_x = "Date_Time", 
               chains=8, cores = 8, adapt = 10000)
plot(fit_mcp0)

model1 = list(Stability ~ 1, 1~ 1, 1~1)  # two intercept-only segments
fit_mcp1 = mcp(model1, data = df2, par_x = "Date_Time", 
               chains=8, cores = 8, adapt = 10000, 
               inits = list(cp_1 = 30, cp_2 = 37))  
plot(fit_mcp1) + geom_vline(xintercept = psis)
plot_pars(fit_mcp1, pars = c("cp_1", "cp_2"))

prior = list(
  cp_1 = "dnorm(30,5)", 
  cp_2 = "dnorm(35,5)",  
  cp_3 = "dnorm(42,5)" 
)

model2 = list(Stability ~ 1, 1~ 1, 1~1, 1~1)  # three intercept-only segments
fit_mcp2 = mcp(model2, data = df2, par_x = "Date_Time", 
               chains=8, cores = 8, adapt = 10000, 
               prior = prior)
plot(fit_mcp2) + geom_vline(xintercept = psis)
plot_pars(fit_mcp2, pars = c("cp_1", "cp_2", "cp_3"))

fit_mcp0$loo = loo(fit_mcp0)
fit_mcp1$loo = loo(fit_mcp1)
fit_mcp2$loo = loo(fit_mcp2)

loo::loo_compare(fit_mcp0$loo, fit_mcp1$loo, fit_mcp2$loo)

