library(tidyverse)

ggplot(diamonds, aes(carat, price)) +
  geom_hex() +
  geom_smooth(method = "lm", se = F, colour = "grey90") +
  scale_x_log10(limits = c(0.2, 3), breaks = c(0.2, 0.5, 1, 2)) +
  scale_y_log10() +
  facet_wrap(~ color)
ggsave("diamonds.pdf", width = 8, height = 4.5)

# Fit model to each facet -------------------------------------------------

by_color <- diamonds %>% split(diamonds$color)
View(by_color)

# Solve for one
.x <- by_color[[1]]
.x
mod <- lm(log(price) ~ log(carat), data = .x)
mod

# log(price) = 8.582 + 1.76 * log(carat)
# price = exp(8.52) * exp(1.76) ^ carat

# Solve for n
mods <- map(by_color, ~ lm(log(price) ~ log(carat), data = .x))

mods <- map(by_color, function(df) {
  lm(log(price) ~ log(carat), data = df)
})
typeof(mods)
length(mods)
mods

View(mods)

# Extract coefficients ----------------------------------------------------

# Solve for one
.x <- mods[[1]]
coef(.x)
broom::tidy(.x)

# Solve for n
coefs <- map(mods, ~ broom::tidy(.x))
coefs

coefs <- map_dfr(mods, ~ broom::tidy(.x))
coefs


names(mods)
coefs <- map_dfr(mods, ~ broom::tidy(.x), .id = "color")
coefs
coefs <- map_dfr(mods, ~ broom::tidy(.x, .id = "color"))
coefs <- map_dfr(mods, broom::tidy, .id = "color")




coefs <- map(mods, broom::tidy)
coefs <- map_dfr(mods, broom::tidy)
coefs

# UHOH!

names(by_color)
names(mods)

coefs <- map_dfr(mods, ~ broom::tidy(.x), .id = "color")
coefs
