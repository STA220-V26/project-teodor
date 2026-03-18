library(dplyr)
library(lubridate)

library(dplyr)
library(lubridate)

merge_files <- function(path) {
  
 
  #välj encounter, observations, patients
  encounter <- encounter %>%
    select(patient, encounter_id = id, start)
  
  observations <- observations %>%
    select(patient, encounter, description, value, unit, date)
  
  patients <- patients %>%
    select(id, birthdate, deathdate, income)
  
  #konvertera till rätt datum
  encounter$start <- as.Date(encounter$start)
  observations$date <- as.Date(observations$date)
  patients$birthdate <- as.Date(patients$birthdate)
  
  
  
  ##alternativ 1?
  # 1. encounter + patients
  merged <- encounter %>%
    left_join(patients, by = c("patient" = "id"))
  
  # 2. add observations
  merged <- merged %>%
    left_join(observations, by = "patient")
  
  return(merged)
  
  
  
  ## alternativ 2?
  # skapa ny ID för encounter?
  merged <- encounter %>%
    left_join(patients, by = c("patient" = "id"))
  
  # skapa ny ID via encounter ID
  merged <- merged %>%
    left_join(observations, by = c("encounter_id" = "encounter"))
  
  return(merged)
}