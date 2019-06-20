# Data from:
# https://www.gov.uk/government/statistics/family-food-open-data
# https://data.gov.uk/dataset/5c1a7a5d-4dd5-4b1b-84f2-3ba8883a07ca/family-food-open-data
# https://webarchive.nationalarchives.gov.uk/20130103024837/http://www.defra.gov.uk/statistics/foodfarm/food/familyfood/nationalfoodsurvey/

library(tidyverse)
library(fs)
dir_delete("nfs")
dir_create("nfs")

# First, what do we have? ---------------------------------------------------

paths <- dir_ls("NFSopen_AllData/", glob = "*.zip")
paths <- setdiff(paths, "NFSopen_AllData/NFS_ReferenceCodesDescriptors.zip")
paths

# Need to see what's in these files
# First figure it out for one file:
x <- paths[[1]]
unzip(x, list = TRUE)
unzip(x, list = TRUE)$Name

# Then convert it to a recipe:
# unzip(x, list = TRUE)$Name
# ->
# ~ unzip(.x, list = TRUE)$Name

# and use map
map(paths, ~ unzip(.x, list = TRUE)$Name)

# But it's this loses the connection between the file name
# and its contents. So instead let's make a data frame.
# Again we first figure it out for one:
tibble(path = x, file = unzip(x, list = TRUE)$Name)
~ tibble(path = .x, file = unzip(.x, list = TRUE)$Name)

# Then we make a recipe and use map()
map(paths, ~ tibble(path = .x, files = unzip(.x, list = TRUE)$Name))

# map() always returns a list, but here a data frame would be
# more convenient, so we can use a map variant: map_dfr
files <- map_dfr(paths, ~ tibble(path = .x, files = unzip(.x, list = TRUE)$Name))
files

# Now we can check if each year has the same files:
length(paths)

files %>%
  extract(files, c("year", "name"), "(\\d{4}) (.*)\\.txt") %>%
  count(name)
# Not too bad!

# Next, unzip all the files --------------------------------------------------

x <- paths[[1]]
unzip(x, exdir = "nfs")

# Generalise with recipe + map function
~ unzip(.x, exdir = "nfs")

map(paths, ~ unzip(.x, exdir = "nfs"))

# Notice this unzip() returns the names of the files it has unzipped
# we don't actually care about that, so we can use a variant, walk()
# that discards the output
walk(paths, ~ unzip(.x, exdir = "nfs"))

# Now lets read in some data --------------------------------------------------

# FIELD	  DESCRIPTION
# -----   -----------------------------
# hhno	  household number
# logday	logday
# schml	  school meals provided
# pkdl	  number of packed lunches
# othl	  other lunches out
# mlwhl	  number of meals on wheels
# midml	  total number of midday meals out
# mlso	  total number of meals out

# TRUST BUT VERIFY

mealsout_paths <- dir_ls("nfs", regexp = "mealsout")
mealsout_paths

# What's the first line of each file?
x <- mealsout_paths[[1]]
read_lines(x, n_max = 1)

map(mealsout_paths, ~ read_lines(.x, n_max = 1))

# A character vector would be simpler
unname(map_chr(mealsout_paths, ~ read_lines(.x, n_max = 1)))

table(map_chr(mealsout_paths, ~ read_lines(.x, n_max = 1)))
# PHEW!



# Now lets read in the data
read_tsv(x)

col_spec <- cols(.default = col_integer())
read_tsv(x, col_types = col_spec)

# Now convert to a recipe and use map variant
# Here we want a data frame:
map_dfr(mealsout_paths, ~ read_tsv(.x, col_types = col_spec))

# WHAT'S MISSING?

# What happened to year? --------------------------------------------------

# In the interests of time, I'm going to cheat a bit and show you
# a solution that skips all these steps - this is the fastest approach
# if files do actually have the same spec. map_dfr() also has an id
# argument, so it's not much of stretch.

meals <- vroom::vroom(mealsout_paths, id = "path")
meals <- meals %>% extract(path, "year", "(\\d{4})", convert = TRUE)
meals

# Look at the data --------------------------------------------------------

meals %>%
  group_by(year, logday = factor(logday)) %>%
  summarise(avg_other = mean(mlso)) %>%
  ggplot(aes(year, avg_other, colour = logday)) +
  geom_point() +
  geom_line() +
  ylab("Average number of meals out")

meals %>%
  group_by(year, logday = factor(logday)) %>%
  summarise(schml = mean(schml)) %>%
  ggplot(aes(year, schml, colour = logday)) +
  geom_point() +
  geom_line() +
  ylab("Average number of school meals")
