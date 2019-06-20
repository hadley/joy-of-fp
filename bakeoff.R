library(bakeoff)
library(tidyverse)
library(fs)

dir_delete("gbbc")
dir_create("gbbc")

rmarkdown::render(
  "bakeoff-report.Rmd",
  output_file = "gbbc/season-3.pdf",
  params = list(season = 3)
)

seasons <- sort(unique(seasons$series))
paths <- paste0("gbbc/season-", seasons, ".pdf")

# Need to turn params into a list
x <- seasons[[1]]
list(season = x)

paths
params <- map(seasons, ~ list(season = .x))
str(params)

walk2(
  paths, params,
  ~ rmarkdown::render("bakeoff-report.Rmd", output_file = .x, params = .y)
)
