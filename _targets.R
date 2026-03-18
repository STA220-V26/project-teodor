library(targets)
library(tarchetypes)

# All these packages are expected to already be installed in the computer running this
tar_option_set(
  packages = c(
    "tidyverse",
    "data.table",
    "pointblank",
    "janitor",
    "fs",
    "curl",
    "betareg"
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
      unzip(zipdata, exdir = "data-fixed", overwrite = TRUE)
      list.files("data-fixed/data-fixed", pattern = "\\.csv$", full.names = TRUE)
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
  ),
  tar_target(
    observations_wide, 
    pivot_selected_measures(observations_raw)
  ),
  tar_target(
    observations, fill_bmi(observations_wide)
  ),
  tar_target(
    encounters_insurance_added,
    add_insurance_coverage(encounters_raw)
  )
)
