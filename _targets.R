library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("tidyverse", "data.table", "pointblank", "janitor"),
  format = "qs"
)

source("R/functions.R")

list(
  tar_target(
    name = data_file,
    command = {
      if (!fs::file_exists("data.zip")) {
        curl::curl_download(
          "https://github.com/STA220/cs/raw/refs/heads/main/data.zip",
          "data.zip",
          quiet = FALSE
        )
      }
      "data.zip"  # Returnera sökvägen
    },
    format = "file"  # Targets spårar filen istället
  )


    tar_target(
  name = unzipped_files,
  command = {
    unzip(data_file, exdir = "data/")
    list.files("data/", full.names = TRUE)  # Returnera sökvägarna
  },
   format = "file"
  )
)