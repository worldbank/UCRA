library(tidyverse)
library(lubridate)

spei_plot <- function(spei_period, plot_height, plot_width = 1600) {
  df <- read_csv(paste0('stats/spei/spei', spei_period, '.csv')) %>%
    mutate(date = date(date))
  
  city_levels <- df %>%
    group_by(city) %>%
    summarize(avg = mean(spei)) %>%
    arrange(avg) %>%
    pull(city)
  
  df %>%
    mutate(city = factor(city, levels = city_levels)) %>%
    ggplot(aes(date, spei)) +
    geom_area(color = '#a6cee3', fill = '#a6cee3', alpha = 0.4, size = 0.2) +
    facet_wrap('city') +
    theme_minimal() +
    theme(panel.grid.minor = element_blank(),
          axis.title = element_blank(),
          legend.position = 'none',
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(subtitle = paste0('SPEI ', as.numeric(spei_period), '-month accumulation period'))
  
  ggsave(paste0('plots/spei', spei_period, '.png'), 
         width = plot_width, height = plot_height, units = 'px')
}

plot_height <- 2000

spei_plot('01', plot_height)
spei_plot('12', plot_height)
spei_plot('48', plot_height)
