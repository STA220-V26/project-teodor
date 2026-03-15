library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "tidyverse", 
    "data.table", 
    "pointblank", 
    "janitor"
  ),
  format = "qs"
)

source("R/functions.R")

list(
  tar_target(
    name = zipdata,
    command = {
      if (!fs::file_exists("data.zip")) {
        curl::curl_download(
          "https://github.com/STA220/cs/raw/refs/heads/main/data.zip",
          "data.zip",
          quiet = FALSE
        )
      }
      "data.zip"
    },
    format = "file"
  ),
  tar_target(
    name = files,
    command = {
      unzip(zipdata, exdir = "data-fixed/")
      list.files("data-fixed/", pattern = "\\.csv$", full.names = TRUE)
    },
    format = "file"
  ),
  tar_target(
    name=patients_raw,
    command = read_csv(files[basename(files) == "patients.csv"])
  ),
  tar_target(
    name = observations_raw,
    command = read_csv(files[basename(files) == "observations.csv"])
  ),
  tar_target(
    name = encounters_raw,
    command = read_csv(files[basename(files) == "encounters.csv"])
  )
)
