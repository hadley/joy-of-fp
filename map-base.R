library(tidyverse)

# Base R: strsplit() -----------------------------------------------------------
# Goal: find first element of each componund string
x1 <- c("a|b", "a|b|c", "d|e", "b|c|d")

x2 <- strsplit(x1, "|", fixed = TRUE)
str(x2)

# How can we solve the problem for one element?
.x <- x2[[1]]
.x
.x[[1]]

# Now can use map_chr() to generalise
map_chr(x2, ~ .x[[1]])
map(x2, ~ .x[[1]])

map_chr(x2, 1) # SHORTCUT

# What if you wanted to select the last?
.x[[length(.x)]]
map_chr(x2, ~.x[[length(.x)]])

# Base R: split() --------------------------------------------------------------
# Goal: fit linear model log(price) ~ log(carat) to each subgroup
by_color <- diamonds %>% split(diamonds$color)
View(by_color)

ggplot(diamonds, aes(carat, price)) +
  geom_hex() +
  geom_smooth(method = "lm", se= F, colour = "red") +
  scale_x_log10() +
  scale_y_log10() +
  facet_wrap(~ color)

# Solve for one
.x <- by_color[[1]]
mod <- lm(log(price) ~ log(carat), data = .x)
mod

# Solve for n
mods <- map(by_color, ~ lm(log(price) ~ log(carat), data = .x))
length(mods)
mods

mods <- map(by_color, lm, formula = log(price) ~ log(carat)) # SHORTCUT

# Goal: extract coefficients
# Solve for one
.x <- mods[[1]]
coef(.x)
broom::tidy(.x)

# Solve for n

coefs <- map(mods, ~ broom::tidy(.x))

coefs <- map_dfr(mods, ~ broom::tidy(.x))
coefs <- map_dfr(mods, broom::tidy) # SHORTCUT
coefs

# Where are the labels?
# They're in the names :(
names(by_color)
names(mods)

coefs <- map_dfr(mods, ~ broom::tidy(.x), .id = "color")
coefs

# BUT
str(diamonds$color)
str(coefs$color)

by_color_cut <- split(diamonds, list(diamonds$color, diamonds$cut))
typeof(by_color_cut)
length(by_color_cut)
names(by_color_cut)

# And this pattern doesn't generalise for multiple break points

# What we actually want is a vector of labels for each variable
# We'll end up with p + 1 vectors of labels (var1, var2, + data)
# So why not put that in a data frame?

# tidyr equivalent: nest --------------------------------------------------
# tidier alternative is to use nest + mutate + unnest

by_color <- diamonds %>%
  group_by(color, cut) %>%
  nest()
by_color

by_color <- by_color %>%
  mutate(
    model = map(data, ~ lm(log(price) ~ log(carat), data = .x)),
    coef = map(model, ~ broom::tidy(.x))
  )
by_color

df <- by_color %>% unnest(coef)

df %>%
  filter(term == "log(carat)") %>%
  ggplot(aes(cut, estimate, colour = color)) +
  geom_point() +
  geom_line(aes(group = color), colour = "grey50")

