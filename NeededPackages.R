# This script is run if you do not have allt the required libraries on your computer
  install.packages(
    c(
    "tidyverse",
    "data.table",
    "pointblank",
    "janitor",
    "fs",
    "curl",
    "pak",
    "betareg"
  )
)

install.packages("pak")
pak::pkg_install("traversc/qs")