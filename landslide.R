library(tidyverse)

options(scipen = 999)

ls <- read_csv('stats/landslide_avg.csv')

ls %>%
  filter(avg != 0) %>%
  ggplot() +
  geom_segment(aes(x = 0.00000, xend = avg,
                   y = fct_reorder(city, avg), yend = fct_reorder(city, avg)),
               color = 'grey', linewidth = 0.3) +
  geom_point(aes(avg, fct_reorder(city, avg), color = avg), size = 2.5,
             show.legend = F, color = '#fbc9ff') +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title = element_blank(),
        axis.text.y = element_text(size = 8),
        plot.subtitle = element_text(size = 9.5)) +
  # scale_x_continuous(trans = 'log10') +
  labs(subtitle = 'City-wide average annual\nfrequency of rainfall-triggered\nlandslide 1980-2018')

ggsave('plots/landslide.png',
       width = 900, height = 550, units = 'px')  # change plot height accordingly
