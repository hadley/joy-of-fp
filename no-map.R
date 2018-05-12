# Cases where you shouldn't use map
library(tidyverse)


# Motivation --------------------------------------------------------------

df <- tibble(
  score = sample(100, 10, replace = TRUE)
)
df

# Take 1 ------------------------------------------------------------------

grade_1 <- function(x) {
  if (x >= 90) {
    "A"
  } else if (x >= 80) {
    "B"
  } else if (x >= 70) {
    "C"
  } else if (x >= 60) {
    "D"
  } else {
    "F"
  }
}

grade_1(92)
grade_1(76)
grade_1(60)

# NOPE
df %>% mutate(grade = grade_1(score))

# YUP
df %>% mutate(grade = map_chr(score, grade_1))


# Take 2 ------------------------------------------------------------------

grade_2 <- function(x) {
  case_when(
    x >= 90 ~ "A",
    x >= 80 ~ "B",
    x >= 70 ~ "C",
    x >= 60 ~ "D",
    TRUE    ~ "F"
  )
}

df %>% mutate(grade = grade_2(score))

# Take 3 ------------------------------------------------------------------

grade_3 <- function(x) {
  cut(x,
    breaks = c(-Inf, 60, 70, 80, 90, Inf),
    labels = c("F", "D", "C", "B", "A"),
    right = FALSE,
    ordered_result = TRUE
  )
}

df %>% mutate(grade = grade_3(score))

# Advantage of specialised function:
# * very clear what the purpose is
# * often faster

x <- round(runif(1e4, 0, 100))
b <- bench::mark(
  grade_1 = map_chr(x, grade_1),
  grade_2 = grade_2(x),
  grade_3 = grade_3(x),
  check = FALSE
)
b
autoplot(b)

# Other code smells -------------------------------------------------------
# * if -> ifelse
# * if + many else blocks, or switch -> case_when
# * unlist, [[1]] -> map
