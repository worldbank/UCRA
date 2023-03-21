library(tidyverse)
library(RColorBrewer)

# coastal cities - manually update list
cities <- c('Matadi')

slr_types <- c('', '_RL10')
years <- c(2050, 2100)

for (year in years) {
  for (slr in slr_types) {
    slr_type <- paste0(slr, '_', year)
    
    flood_slr <- function(city) {
      city1 <- gsub(' ', '_', tolower(city))
      city2 <- gsub('-', '_', city1)
      df <- read_csv(paste0(city, '/data/', city2, '_slr', slr_type, '.csv')) %>%
        filter(VALUE == 1) %>%
        select(-1, -2, -3) %>%
        pivot_longer(cols = everything(), names_to = 'value', values_to = 'sq_m') %>%
        separate(col = 'value', into = c(NA, 'year'), sep = '_') %>%
        arrange(year) %>%
        mutate(cumulative_sq_km = cumsum(sq_m) / 1e6) %>%
        select(-sq_m)
      write_csv(df, paste0(city, '/stats/slr', slr_type, '.csv'))
    }
    
    lapply(cities, flood_slr)
    
    # SLR line graphs ----------------------------------------------------
    read_flood <- function(city) {
      city_name <- city
      df <- read_csv(paste0(city, '/stats/slr', slr_type, '.csv')) %>%
        mutate(city = city_name) %>%
        arrange(year)
      if (nrow(df) > 0) {
        sqkm_1985 <- df %>% filter(year == 1985) %>% pull(cumulative_sq_km)
        df %>% mutate(growth = cumulative_sq_km / sqkm_1985 * 100 - 100)
      } else {
        df
      }
    }
    
    # manually update according to the list of cities
    mat <- read_flood('Matadi')
    
    all_cities <- rbind(mat) %>%  # manually update according to the list of cities
      arrange(-cumulative_sq_km)
    all_cities_2015 <- all_cities %>% filter(year == 2015)
    city_levels <- all_cities_2015$city
    all_cities <- all_cities %>%
      mutate(city = factor(city, levels = city_levels))
    
    all_cities %>%
      ggplot() +
      geom_line(aes(year, cumulative_sq_km, group = city, color = city), size = 1) +
      scale_x_continuous(breaks = seq(1985, 2015, 10)) +
      scale_color_manual(values = colorRampPalette(c('#084081', '#7bccc4', '#e0f3db'))(length(unique(all_cities$city)))) +
      # scale_y_continuous(trans = 'log10') +
      theme_minimal() +
      theme(panel.grid.minor = element_blank(),
            axis.title = element_blank(),
            axis.text = element_text(size = 6),
            legend.text = element_text(size = 6),
            legend.margin = margin(0, 0, 0, 0, 'mm'),
            legend.key.size = unit(3, 'mm'),
            legend.title = element_blank(),
            plot.title = element_text(size = 9.5),
            plot.subtitle = element_text(size = 7),
            legend.position = 'right') +
      labs(title = case_when(slr == '' ~ 'Built-up area exposed to\nmedian projected sea level rise',
                             slr == '_RL10' ~ 'Built-up area exposed to 10% annual chance\nflood given median projected sea level rise'),
           subtitle = paste('RCP4.5,', year, '(sq km)'))
    
    ggsave(paste0('plots/all_cities_slr', slr_type, '.png'),
           width = 900, height = 900, units = 'px')
    
    city_levels <- all_cities %>% 
      filter(year == 2015) %>%
      arrange(-growth) %>%
      pull(city)
    
    all_cities %>% filter(growth != Inf) %>% 
      mutate(city = factor(city, levels = city_levels)) %>%
      ggplot() +
      geom_line(aes(year, growth, group = city), color = 'grey', 
                size = 1, show.legend = F) +
      facet_wrap(vars(city), nrow = 2) +
      scale_x_continuous(breaks = seq(1985, 2015, 10)) +
      theme_minimal() +
      theme(panel.grid.minor = element_blank(),
            plot.title = element_text(size = 11),
            plot.subtitle = element_text(size = 9),
            axis.text.x = element_text(angle = 30, hjust = 1),
            axis.text = element_text(size = 8),
            axis.title = element_blank()) +
      labs(title = case_when(slr == '' ~ 'Growth of settlement area exposed to median projected sea level rise',
                             slr == '_RL10' ~ 'Growth of settlement area exposed to 10% annual chance flood\ngiven median projected sea level rise'),
           subtitle = paste('RCP4.5,', year, '(sq km)'))
    
    ggsave(paste0('plots/all_cities_slr', slr_type, '_growth.png'),
           width = 1600, height = 1200, units = 'px')
  }
}

# SLR bar charts (do this in the end) --------------------------------------------
get_slr_stat <- function(city, slr_type, year) {
  read_csv(paste0(city, '/stats/slr', slr_type, '_', year, '.csv')) %>%
    filter(year == 2015) %>%
    pull(cumulative_sq_km)
}

base_plot_height <- 400

slr <- tibble(city = cities) %>%
  mutate(sq_km_2050 = get_slr_stat(city, '', 2050),
         sq_km_2100 = get_slr_stat(city, '', 2100)) %>%
  arrange(sq_km_2100)
city_levels <- slr$city
slr <- slr %>%
  mutate(diff = sq_km_2100 - sq_km_2050) %>%
  select(-sq_km_2100) %>%
  rename(`2050` = sq_km_2050, `2100` = diff) %>%
  pivot_longer(cols = 2:3, names_to = 'year', values_to = 'value') %>%
  mutate(year = factor(year, levels = c('2100', '2050')),
         city = factor(city, levels = city_levels))

ggplot(slr) +
  geom_col(aes(value, city, fill = year), width = 0.5, alpha = 0.8) +
  scale_fill_manual(values = c('#6baed6', '#08519c')) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        axis.title = element_blank(),
        legend.title = element_blank(),
        legend.key.size = unit(3, 'mm'),
        legend.margin = margin(0, 0, 0, 0, 'mm')) +
  labs(subtitle = 'Settlement area exposed to median\nprojected sea level rise (sq km)')

ggsave('plots/slr.png',
       width = 1200, height = base_plot_height, units = 'px')


slr_RL10 <- tibble(city = cities) %>%
  mutate(sq_km_2050 = get_slr_stat(city, '_RL10', 2050),
         sq_km_2100 = get_slr_stat(city, '_RL10', 2100)) %>%
  arrange(sq_km_2100)
city_levels <- slr_RL10$city
slr_RL10 <- slr_RL10 %>%
  mutate(diff = sq_km_2100 - sq_km_2050) %>%
  select(-sq_km_2100) %>%
  rename(`2050` = sq_km_2050, `2100` = diff) %>%
  pivot_longer(cols = 2:3, names_to = 'year', values_to = 'value') %>%
  mutate(year = factor(year, levels = c('2100', '2050')),
         city = factor(city, levels = city_levels))

ggplot(slr_RL10) +
  geom_col(aes(value, city, fill = year), width = 0.5, alpha = 0.8) +
  scale_fill_manual(values = c('#6baed6', '#08519c')) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        axis.title = element_blank(),
        legend.title = element_blank(),
        legend.key.size = unit(3, 'mm'),
        legend.margin = margin(0, 0, 0, 0, 'mm')) +
  labs(subtitle = 'Settlement area exposed to 10%\nannual chance flood given median\nprojected sea level rise (sq km)')

ggsave('plots/slr_RL10.png',
       width = 1200, height = base_plot_height + 50, units = 'px')
