library(tidyverse)

# Add title to plot -------------------------------------------------------

by_color <- diamonds %>% split(diamonds$color)
titles <- paste0("Color: ", names(by_color))

.x <- by_color[[1]]
.y <- titles[[1]]
ggplot(.x, aes(carat, price)) +
  geom_hex() +
  scale_x_log10() +
  scale_y_log10() +
  labs(title = .y)

# To make things a little clear let's make a function
my_plot <- function(data, title = NULL) {
  ggplot(data, aes(carat, price)) +
    geom_hex() +
    scale_x_log10() +
    scale_y_log10() +
    labs(title = title)
}

my_plot(.x, .y)
my_plot(by_color[[4]], titles[[4]])

plots <- map(by_color, my_plot)
plots[[5]]

plots <- map(by_color, my_plot, title = titles)
plots[[1]]
plots[[2]]
plots[[7]]

plots <- map2(by_color, titles, my_plot)
plots[[1]]
plots[[2]]
plots[[7]]


# Cheat a little
my_plot <- function(data, title = NULL) {
  ggplot(data, aes(carat, price)) +
    geom_hex() +
    scale_x_log10(limits = c(0.2, 5), breaks = c(0.1, 0.2, 0.5, 1, 2, 5)) +
    scale_y_log10(limits = c(300, 19000)) +
    scale_fill_gradient(limits = c(0, 350)) +
    labs(title = title)
}
plots <- map2(by_color, titles, my_plot)
plots[[1]]

# Save to disk ------------------------------------------------------------

paths <- paste0("plots/color-", names(by_color), ".pdf")

# Solve for one
ggsave(paths[[1]], plots[[1]], width = 6, height = 6)

map2(paths, plots, ggsave, width = 6, height = 6)

# Why do we care about the output?
walk2(paths, plots, ggsave, width = 6, height = 6)



# If we want to see all the plots, we need to print them
# Here we only care about the side-effect, not the result, so
# we use walk(), not map()
walk(plots, plot)

# But let's say we want to save them.
# First, we'll need to work out the file names

# Again we solve the problem for one case: but now we need _two_ inputs
# so we'll assign .x and .y
.x <- paths[[1]]
.y <- plots[[1]]
ggsave(.x, .y, width = 6, height = 6)

# This has two inputs, so we need a map2(), and since we'll calling ggsave()
# for its side-effect, not it's value, we need walk2()

walk2(paths, plots, ~ggsave(.x, .y, width = 6, height = 6))


walk2(paths, plots, ggsave, width = 6, height = 6) # SHORTCUT

# Would be nice to add a title to each image: that means our build_plot()
# function needs another argument, title. (I've also tweaked the scales so
# that every plot has consistent limits.)
build_plot <- function(df, title) {
  ggplot(df, aes(carat, price)) +
    geom_hex() +
    scale_x_log10(limits = c(0.2, 5), breaks = c(0.1, 0.2, 0.5, 1, 2, 5)) +
    scale_y_log10(limits = c(300, 19000)) +
    scale_fill_gradient(limits = c(0, 350)) +
    ggtitle(title)
}
build_plot(by_color[[1]], "This is my title")

# And we also need a vector of titles
titles <- paste0("Colour: ", names(by_color))

# Now we can make a list of plots again, and then save them to disk
plots <- map2(by_color, titles, build_plot)
walk2(paths, plots, ggsave, width = 6, height = 6)


# -------------------------------------------------------------------------

# Code like this should make you nervous:
by_color <- diamonds %>% split(diamonds$color)
titles <- paste0("Color: ", names(by_color))
# What happens if color isn't a character vector?
# What happens if you split by more than one variable?

by_color_cut <- diamonds %>% split(list(diamonds$color, diamonds$cut))
names(by_color_cut)


# I think it's better to keep it in a dataframe:
colour_plots <- diamonds %>%
  group_by(color) %>%
  nest() %>%
  mutate(
    title = paste0("Color: ", color),
    path =  paste0("plots/color-", color, ".pdf")
  )
colour_plots

# Can also use list-column to store plots
colour_plots %>%
  mutate(plot = map2(by_color, titles, my_plot))


