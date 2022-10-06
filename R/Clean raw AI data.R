## acoustic index processing

# file for cleaning the AI dataset

## Data:
setwd("~/Desktop/Research/In progress/2020 Typhoon stability/Data")
load("4yr_Soundscape.RData")
setwd("~/Desktop/Research/In progress/2018 Soundscape stability/Data/Site index & GIS")
Ref<-read.csv("Site number reference.csv",header = T)
load("/Users/samross/Desktop/Research/In progress/2020 Sound-landscape/Data/1yr_soundscape.RData")
rm(AprilChorus.Bal,GISTable,LongChorus.Bal)

library(lubridate)
library(data.table)
library(forecast)

## Functions:
'%!in%' <- function(x,y)!('%in%'(x,y)) # function for opposite of %in%

fastmeter<-function(x){
  library(stringr)
  x<-gsub(x = x,pattern = ".wav",replacement = "")
  timez<-str_split(x,pattern = "_",simplify = T)[,2:3]
  timez<-apply(timez,MARGIN = 1,FUN = paste0,collapse = "-")
  head(timez)
  out<-strptime(timez,format = "%Y%m%d-%H%M%S",tz = "Asia/Tokyo")
  return(out)
} # function for pulling out dates and times and bypassing the much slower songmeter() function

## code

Acoustic_indices<-Soundscape_List
# get only acoustic indices of interest (includes combining L and R channels)
for (i in 1:length(Soundscape_List)) {
  
  Acoustic_indices[[i]]<-as.data.frame(Acoustic_indices[[i]][,1])
  colnames(Acoustic_indices[[i]])<-"Filename" 
  
  ## populate acoustic index list with index values for each site
  Acoustic_indices[[i]]$NDSI<-apply(Soundscape_List[[i]][,c(2,3)],MARGIN = 1,FUN = mean) # normalised difference soundscape index (mean of L and R channels)
  Acoustic_indices[[i]]$NDSI_Bio<-apply(Soundscape_List[[i]][,c(4,6)],MARGIN = 1,FUN = mean) # Biophony (mean of L and R channels)
  Acoustic_indices[[i]]$NDSI_Anth<-apply(Soundscape_List[[i]][,c(5,7)],MARGIN = 1,FUN = mean) # Anthropophony (mean of L and R channels)
  Acoustic_indices[[i]]$ADiv<-apply(Soundscape_List[[i]][,c(10,11)],MARGIN = 1,FUN = mean) # Acoustic Diversity index (mean of L and R channels)
  Acoustic_indices[[i]]$H<-Soundscape_List[[i]]$H # Acoustic entropy index
  Acoustic_indices[[i]]$M<-Soundscape_List[[i]]$M # Median of the amplitude envelope
  
}

Acoustic_bands<-Soundscape_List
# get only acoustic indices of interest (includes combining L and R channels)
for (i in 1:length(Soundscape_List)) {
  
  Acoustic_bands[[i]]<-as.data.frame(Acoustic_bands[[i]][,1])
  colnames(Acoustic_bands[[i]])<-"Filename" 
  
  ## populate acoustic index list with index values for each site
  Acoustic_bands[[i]]$band_1<-apply(Soundscape_List[[i]][,c(12,32)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_2<-apply(Soundscape_List[[i]][,c(13,33)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_3<-apply(Soundscape_List[[i]][,c(14,34)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_4<-apply(Soundscape_List[[i]][,c(15,35)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_5<-apply(Soundscape_List[[i]][,c(16,36)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_6<-apply(Soundscape_List[[i]][,c(17,37)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_7<-apply(Soundscape_List[[i]][,c(18,38)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_8<-apply(Soundscape_List[[i]][,c(19,39)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_9<-apply(Soundscape_List[[i]][,c(20,40)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_10<-apply(Soundscape_List[[i]][,c(21,41)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_11<-apply(Soundscape_List[[i]][,c(22,42)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_12<-apply(Soundscape_List[[i]][,c(23,43)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_13<-apply(Soundscape_List[[i]][,c(24,44)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_14<-apply(Soundscape_List[[i]][,c(25,45)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_15<-apply(Soundscape_List[[i]][,c(26,46)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_16<-apply(Soundscape_List[[i]][,c(27,47)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_17<-apply(Soundscape_List[[i]][,c(28,48)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_18<-apply(Soundscape_List[[i]][,c(29,49)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_19<-apply(Soundscape_List[[i]][,c(30,50)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  Acoustic_bands[[i]]$band_20<-apply(Soundscape_List[[i]][,c(31,51)],MARGIN = 1,FUN = mean) # (mean of L and R channels)
  
}
rm(Soundscape_List)

# fastemeter function to get times etc. 
for (i in 1:length(Acoustic_indices)) {
  Acoustic_indices[[i]]$Date_Time<-fastmeter(Acoustic_indices[[i]]$Filename)
}
for (i in 1:length(Acoustic_indices)) {
  Acoustic_bands[[i]]$Date_Time<-fastmeter(Acoustic_bands[[i]]$Filename)
}

# standardise acoustic indices
Standard_indices<-Acoustic_indices # create separate list of dataframes
# standardise soundscape index values by their maximum
for (i in 1:length(Standard_indices)) {
  Standard_indices[[i]]$NDSI_Bio<-Standard_indices[[i]]$NDSI_Bio/max(Standard_indices[[i]]$NDSI_Bio,na.rm = T)
  Standard_indices[[i]]$NDSI_Anth<-Standard_indices[[i]]$NDSI_Anth/max(Standard_indices[[i]]$NDSI_Anth,na.rm = T)
  Standard_indices[[i]]$ADiv<-Standard_indices[[i]]$ADiv/max(Standard_indices[[i]]$ADiv,na.rm = T)
  Standard_indices[[i]]$H<-Standard_indices[[i]]$H/max(Standard_indices[[i]]$H,na.rm = T)
  Standard_indices[[i]]$M<-Standard_indices[[i]]$M/max(Standard_indices[[i]]$M,na.rm = T)
  Standard_indices[[i]]$NDSI<-(Standard_indices[[i]]$NDSI+1)/2 # standardise NDSI as (NDSI+1)/2
}

# separate out the typhoon period
Typhoon_AIs<-Standard_indices

for (i in 1:length(Standard_indices)) {
  
  # subset by only the typhoon period (Aug 30 2018 to Nov 05 inclusive)
  Typhoon_AIs[[i]]<-Standard_indices[[i]][Standard_indices[[i]]$Date_Time >= as.POSIXct("2018-08-30 00:00:00",
                                                                                        tz = "Asia/Tokyo") & 
                                            Standard_indices[[i]]$Date_Time < as.POSIXct("2018-11-05 00:00:00",
                                                                                         tz = "Asia/Tokyo"),]
  
  # reorder dataframes into time order
  Typhoon_AIs[[i]]<-Typhoon_AIs[[i]][order(Typhoon_AIs[[i]]$Date_Time),]
  
}

# Add typhoon periods for SES analysis
for (i in 1:length(Typhoon_AIs)) {
  Typhoon_AIs[[i]]$Period[Typhoon_AIs[[i]]$Date_Time < as.POSIXct("2018-09-29 00:00:00",tz = "Asia/Tokyo")]<-"Pre-typhoon"
  Typhoon_AIs[[i]]$Period[Typhoon_AIs[[i]]$Date_Time >= as.POSIXct("2018-09-29 00:00:00",tz = "Asia/Tokyo")]<-"Trami"
  Typhoon_AIs[[i]]$Period[Typhoon_AIs[[i]]$Date_Time >= as.POSIXct("2018-10-01 00:00:00",tz = "Asia/Tokyo")]<-"Post-Trami"
  Typhoon_AIs[[i]]$Period[Typhoon_AIs[[i]]$Date_Time >= as.POSIXct("2018-10-04 00:00:00",tz = "Asia/Tokyo")]<-"Kong-Rey"
  Typhoon_AIs[[i]]$Period[Typhoon_AIs[[i]]$Date_Time >= as.POSIXct("2018-10-06 00:00:00",tz = "Asia/Tokyo")]<-"Post-typhoon"
}


# Add dates without times for daily discretization
for (i in 1:length(Typhoon_AIs)) {
  Typhoon_AIs[[i]]$Date<-as_date(Typhoon_AIs[[i]]$Date_Time)
}

## add site names
for (i in 1:length(Typhoon_AIs)) {
  Typhoon_AIs[[i]]$Site_ID<-strsplit(Typhoon_AIs[[i]]$Filename,split = "_")[[1]][1] # add site name
}

### Moving average detrend:
Typhoon_AIs_3d<-Typhoon_AIs
Typhoon_AIs_5d<-Typhoon_AIs
Typhoon_AIs_7d<-Typhoon_AIs

# calculate the moving average for each acoustic index
for (i in 1:length(Typhoon_AIs)) { # for each site
  for (j in 1:6) { # and each acoustic index
    
    Typhoon_AIs_3d[[i]][,1+j]<-ma(x = Typhoon_AIs[[i]][,1+j],order = 48*3, centre = T) # take 3 day moving average & store
    Typhoon_AIs_5d[[i]][,1+j]<-ma(x = Typhoon_AIs[[i]][,1+j],order = 48*5, centre = T) # take 5 day moving average & store
    Typhoon_AIs_7d[[i]][,1+j]<-ma(x = Typhoon_AIs[[i]][,1+j],order = 48*7, centre = T) # take 7 day moving average & store
    
  }
}

# need to change the format of the Date_Time column for later using rbindlist()
for (i in 1:length(Typhoon_AIs)) {
  Typhoon_AIs_3d[[i]]$Date_Time<-as.POSIXct(Typhoon_AIs_3d[[i]]$Date_Time)
  Typhoon_AIs_5d[[i]]$Date_Time<-as.POSIXct(Typhoon_AIs_5d[[i]]$Date_Time)
  Typhoon_AIs_7d[[i]]$Date_Time<-as.POSIXct(Typhoon_AIs_7d[[i]]$Date_Time)
}

# rbindlist() pulls the separate elements of our list (in this case sites) into a single column
ma_3d_TyphoonAIs<-rbindlist(Typhoon_AIs_3d) %>% as.data.frame(); rm(Typhoon_AIs_3d) 
ma_5d_TyphoonAIs<-rbindlist(Typhoon_AIs_5d) %>% as.data.frame(); rm(Typhoon_AIs_5d)
ma_7d_TyphoonAIs<-rbindlist(Typhoon_AIs_7d) %>% as.data.frame(); rm(Typhoon_AIs_7d)

## unlist the sites
for (i in 1:length(Typhoon_AIs)) {
Typhoon_AIs[[i]]$Date_Time<-Typhoon_AIs[[i]]$Date_Time %>% as.POSIXct()
}

Typhoon_AIs_unlist<-rbindlist(Typhoon_AIs)

Standardised_AIs<-Typhoon_AIs_unlist
AIs_ma_3d<-ma_3d_TyphoonAIs
AIs_ma_5d<-ma_5d_TyphoonAIs
AIs_ma_7d<-ma_7d_TyphoonAIs

setwd("~/Desktop/Research/In progress/2020 Typhoon stability/Code/Code for paper/Data")
save(list = c('Standardised_AIs','AIs_ma_3d','AIs_ma_5d','AIs_ma_7d'),file = 'Acoustic_indices.rda')




