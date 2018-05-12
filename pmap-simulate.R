library(tidyverse)

# Goal: we want to simulate from runif() with different n, min, and max
# We've stored the parameters into a data frame
df <- tribble(
  ~ n, ~ min, ~ max,
   1L,     0,     1,
   2L,    10,   100,
   3L,   100,  1000
)
df

# How can we solve the problem if we had one row?
..1 <- df$n[[1]]
..2 <- df$min[[1]]
..3 <- df$max[[1]]
runif(`..1`, `..2`, `..3`)
# emo::ji("vomit")

# Then how do we apply to every row
pmap(df, ~ runif(..1, ..2, ..3))
pmap(df, runif) # SHORTCUT

# This is so concise it feels magical - the key is carefully
# constructing the input variable names to match the function
# argument names
