library(tidyverse)

heat <- read_csv('stats/avg_temp.csv')

ggplot(heat) +
  geom_segment(aes(x = 30, xend = avg,
                   y = fct_reorder(city, avg), yend = fct_reorder(city, avg)),
               color = 'grey', linewidth = 0.3) +
  geom_point(aes(avg, fct_reorder(city, avg), color = avg), size = 3,
             show.legend = F, color = '#f04c1f') +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title = element_blank(),
        axis.text.y = element_text(size = 8),
        plot.subtitle = element_text(size = 9.5)) +
  # scale_x_continuous(breaks = seq(35, 45, 5)) +
  labs(subtitle = 'Mean temperature during the\nhottest months 2013-2022 (°C)')

ggsave('plots/avg_temp.png',
       width = 900, height = 1000, units = 'px'  # change plot height accordingly
