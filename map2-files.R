library(tidyverse)

# Goal: plot the relationship between price and carat and save to a file
by_color <- diamonds %>% split(diamonds$color)

.x <- by_color[[1]]
ggplot(.x, aes(carat, price)) +
  geom_hex() +
  scale_x_log10() +
  scale_y_log10()

plots <- map(by_color, ~ ggplot(.x, aes(carat, price)) +
  geom_hex() +
  scale_x_log10() +
  scale_y_log10()
)

# But it's probably worthwhile to create a function
build_plot <- function(df) {
  ggplot(df, aes(carat, price)) +
    geom_hex() +
    scale_x_log10() +
    scale_y_log10()
}
plots <- map(by_color, build_plot)
plots[[6]]

# If we want to see all the plots, we need to print them
# Here we only care about the side-effect, not the result, so
# we use walk(), not map()
walk(plots, print)

# But let's say we want to save them.
# First, we'll need to work out the file names
paths <- paste0("plots/color-", names(by_color), ".pdf")

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
