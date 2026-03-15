library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("tidyverse", "data.table", "pointblank", "janitor"),
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
    name = csv_files,
    command = {
      unzip(zipdata, exdir = "data-fixed/")
      list.files("data-fixed/", pattern = "\\.csv$", full.names = TRUE)
    },
    format = "file"
  ),
  tar_target(
    
  )
)
