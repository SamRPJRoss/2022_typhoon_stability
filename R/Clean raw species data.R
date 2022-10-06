## code for cleaning bird data

## packages
library(data.table)

## Functions:
'%!in%' <- function(x,y)!('%in%'(x,y)) # function for opposite of %in%

## read in successful recognisers (non-missing data)
Corvus_files <- list.files(path = "~/Desktop/Research/In progress/2020 Typhoon stability/Data/Species detectors/Non-missing data/2022_Corvus",pattern = ".csv",full.names = T)
setwd("~/Desktop/Research/In progress/2020 Typhoon stability/Data/Species detectors/Non-missing data/2022_Corvus")
Corvus.list <- lapply(Corvus_files, read_csv)
Horornis_files <- list.files(path = "~/Desktop/Research/In progress/2020 Typhoon stability/Data/Species detectors/Non-missing data/2022_Horornis",pattern = ".csv",full.names = T)
setwd("~/Desktop/Research/In progress/2020 Typhoon stability/Data/Species detectors/Non-missing data/2022_Horornis")
Horornis.list <- lapply(Horornis_files, read_csv)
Otus_files <- list.files(path = "~/Desktop/Research/In progress/2020 Typhoon stability/Data/Species detectors/Non-missing data/2022_Otus",pattern = ".csv",full.names = T)
setwd("~/Desktop/Research/In progress/2020 Typhoon stability/Data/Species detectors/Non-missing data/2022_Otus")
Otus.list <- lapply(Otus_files, read_csv)

## unlist the dataframes

## corvus
for (i in 1:length(Corvus.list)) {
  Corvus.list[[i]]<-Corvus.list[[i]][,c(3:12,16:17,22,23)] # get only relevant columns
  colnames(Corvus.list[[i]])<-c('Filename','Channel','Offset','Duration','Fmin','Fmean','Fmax','Date','Time','Hour','Species_ID','Cluster_dist','Vocalisations','Manual_ID') # rename cols
  Corvus.list[[i]]$Site_ID<-strsplit(Corvus.list[[i]]$Filename,split = "_")[[1]][1] # add site name
    for (j in 1:length(Corvus.list[[i]]$Manual_ID)) { # for each record
    if(Corvus.list[[i]]$Manual_ID[j] %!in% NA){ # if there's an entry in Manual_ID
      Corvus.list[[i]]$Species[j]<-Corvus.list[[i]]$Manual_ID[j] # replace the species ID with the manual ID
    }
  }
}

Corvus_unlist<-rbindlist(Corvus.list)
rm(Corvus.list,Corvus_files)

## Horornis
for (i in 1:length(Horornis.list)) {
  Horornis.list[[i]]<-Horornis.list[[i]][,c(3:12,16:17,22,23)] # get only relevant columns
  colnames(Horornis.list[[i]])<-c('Filename','Channel','Offset','Duration','Fmin','Fmean','Fmax','Date','Time','Hour','Species_ID','Cluster_dist','Vocalisations','Manual_ID') # rename cols
  Horornis.list[[i]]$Site_ID<-strsplit(Horornis.list[[i]]$Filename,split = "_")[[1]][1] # add site name
  for (j in 1:length(Horornis.list[[i]]$Manual_ID)) { # for each record
    if(Horornis.list[[i]]$Manual_ID[j] %!in% NA){ # if there's an entry in Manual_ID
      Horornis.list[[i]]$Species[j]<-Horornis.list[[i]]$Manual_ID[j] # replace the species ID with the manual ID
    }
  }
}

Horornis_unlist<-rbindlist(Horornis.list)
rm(Horornis.list,Horornis_files)

## Otus
for (i in 1:length(Otus.list)) {
  Otus.list[[i]]<-Otus.list[[i]][,c(3:12,16:17,22,23)] # get only relevant columns
  colnames(Otus.list[[i]])<-c('Filename','Channel','Offset','Duration','Fmin','Fmean','Fmax','Date','Time','Hour','Species_ID','Cluster_dist','Vocalisations','Manual_ID') # rename cols
  Otus.list[[i]]$Site_ID<-strsplit(Otus.list[[i]]$Filename,split = "_")[[1]][1] # add site name
  for (j in 1:length(Otus.list[[i]]$Manual_ID)) { # for each record
    if(Otus.list[[i]]$Manual_ID[j] %!in% NA){ # if there's an entry in Manual_ID
      Otus.list[[i]]$Species[j]<-Otus.list[[i]]$Manual_ID[j] # replace the species ID with the manual ID
    }
  }
}

Otus_unlist<-rbindlist(Otus.list)
rm(Otus.list,Otus_files)



# check unique species names in each dataframe
unique(Corvus_unlist$Species_ID); unique(Horornis_unlist$Species_ID); unique(Otus_unlist$Species_ID) 

# remove non-target sounds from recognisers
Horornis_unlist<-Horornis_unlist[Horornis_unlist$Species_ID %!in% 'Noise',]
Otus_unlist<-Otus_unlist[Otus_unlist$Species_ID %!in% 'Noise',]

# correct species names
Corvus_unlist$Species_ID<-"Corvus_macrorhynchos"
Horornis_unlist$Species_ID<-"Horornis_diphone"
Otus_unlist$Species_ID<-"Otus_elegans"

# combine into single dataframe for analysis
Species_detections<-rbind(Corvus_unlist,Horornis_unlist,Otus_unlist)

# check all species are in the new dataframe
unique(Species_detections$Species_ID)

# remove defunct Manual ID column
Species_detections<-Species_detections[,-14]

# add typhoon periods
for (i in 1:length(Species_detections)) {
  Species_detections$Period[Species_detections$Date < as.POSIXct("2018-09-29 00:00:00",tz = "Asia/Tokyo")]<-"Pre-typhoon"
  Species_detections$Period[Species_detections$Date >= as.POSIXct("2018-09-29 00:00:00",tz = "Asia/Tokyo")]<-"Trami"
  Species_detections$Period[Species_detections$Date >= as.POSIXct("2018-10-01 00:00:00",tz = "Asia/Tokyo")]<-"Post-Trami"
  Species_detections$Period[Species_detections$Date >= as.POSIXct("2018-10-04 00:00:00",tz = "Asia/Tokyo")]<-"Kong-Rey"
  Species_detections$Period[Species_detections$Date >= as.POSIXct("2018-10-06 00:00:00",tz = "Asia/Tokyo")]<-"Post-typhoon"
}

## save the cleaned dataset for analysis
setwd("~/Desktop/Research/In progress/2020 Typhoon stability/Data/Species detectors/Non-missing data")
save(Species_detections,file = '2022_Species_detections.rda')

