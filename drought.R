library(tidyverse)
library(lubridate)

# Drought plot --------------------------------------------
cities <- read_csv('centroids.csv') %>% select(city)
cities$centroids <- 0:(nrow(cities)-1)
var_list <- c('twsan')
date_list <- c('01', '02', '03', 
               '04', '05', '06', 
               '07', '08', '09', 
               '10', '11', '12')

drought_plot <- function(var, year_beg, year_end, lab_x1, lab_y1, lab1, lab_x2 = 2, lab_y2 = 0, lab2 = '', plot_width, plot_height) {
  subt0 <- case_when(var == 'rdria' ~ 'Risk of drought impacts for agriculture',
                     var == 'spg01' ~ 'SPI 1-month accumulation period',
                     var == 'spg12' ~ 'SPI 12-month accumulation period',
                     var == 'twsan' ~ 'Total water storage anomaly')
  
  subt1 <- paste(year_beg, year_end, sep = '-')
  
  df <- cities
  
  for (yr in year_beg:year_end) {
    for (i in date_list) {
      df1 <- read_csv(paste0('output/drought/', var, '_', yr, i, '.csv')) 
      df <- df %>%  
        full_join(df1) %>%
        select(-OID_)
    }
  }
  
  
  line_color <- case_when(str_detect(var, 'spg') ~ '#018571',
                          var == 'twsan' ~ '#a6611a',
                          var == 'rdria' ~ '#b30000')
  
  df <- df %>%
    select(-centroids) %>%
    pivot_longer(cols = 4:ncol(.), names_to = 'month', values_to = 'value') %>%
    mutate(date = substr(month, 13, 20)) %>%
    mutate(date = ymd(date)) %>%
    select(-month) %>%
    filter(!is.na(value))
  
  df_levels <- df %>%
    group_by(city) %>%
    summarize(avg = mean(value)) %>%
    arrange(avg) %>%
    pull(city)
  
  smallest_date <- df %>% pull(date) %>% min() %>% as.numeric()
  
  df %>%
    mutate(city = factor(city, levels = df_levels)) %>%
    ggplot() +
    geom_hline(yintercept = 0, size = 0.5, color = 'grey') +
    geom_line(aes(date, value, group = city), 
              color = line_color) +
    geom_text(aes(as_date(smallest_date+lab_x1), lab_y1, label = lab1),
              color = 'darkgrey', lineheight = 0.9, size = 2) +
    geom_text(aes(as_date(smallest_date+lab_x2), lab_y2, label = lab2),
              color = 'darkgrey', lineheight = 0.9, size = 2) +
    facet_wrap('city') +
    # scale_x_continuous(breaks = c(2011, 2016, 2021)) +
    # scale_alpha_manual(values = c(0.4, 1)) +
    theme_minimal() +
    theme(panel.grid.minor = element_blank(),
          panel.spacing = unit(1, 'lines'),
          axis.title = element_blank(),
          axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = 'none',
          legend.title = element_blank()) +
    labs(subtitle = paste(subt0, subt1, sep = ' '))
  
  ggsave(paste0('plots/', var, '.png'),
         width = plot_width, height = plot_height, units = 'px')
}

# drought_plot('rdria', 1.7, 0, '', 1.7, 0, '')
# drought_plot('spg01', 1.7, -1.5, 'drier\nthan\nnormal', 1.7, 1.5, 'wetter\nthan\nnormal')
# drought_plot('spg12', 1.7, -1, 'drier\nthan\nnormal', 1.7, 1.5, 'wetter\nthan\nnormal')
drought_plot('twsan', 2011, 2020, 250, -2, 'drier\nthan\nnormal', 250, 2, 'wetter\nthan\nnormal', 1600, 2000)
