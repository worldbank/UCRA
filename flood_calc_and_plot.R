library(tidyverse)
library(RColorBrewer)

cities <- read_csv('centroids.csv') %>% pull(city)
floods <- c('f', 'p')
years <- c(1985, 2015)

# flood stats calculation -------------------------------------
for (flood in floods) {
  not_flooded_85 <- 0
  not_flooded_15 <- 0
  
  for (city in cities) {
    city1 <- gsub(' ', '_', tolower(city))
    city2 <- gsub('-', '_', city1)
    df <- read_csv(paste0(city, '/data/', city2, '_', flood, 'u.csv')) %>%
      filter(VALUE == 0) %>%
      select(-1, -2, -3) %>%
      pivot_longer(cols = everything(), names_to = 'value', values_to = 'sq_m') %>%
      separate(col = 'value', into = c(NA, 'year'), sep = '_') %>%
      arrange(year) %>%
      mutate(cumulative_sq_km = cumsum(sq_m) / 1e6) %>%
      select(-sq_m) %>%
      filter(year %in% c(1985, 2015)) %>%
      pull(cumulative_sq_km)
    not_flooded_85 <- min(df) + not_flooded_85
    not_flooded_15 <- max(df) + not_flooded_15
  }
  
  flooded_85 <- 0
  flooded_15 <- 0
  
  for (city in cities) {
    city1 <- gsub(' ', '_', tolower(city))
    city2 <- gsub('-', '_', city1)
    df <- read_csv(paste0(city, '/data/', city2, '_', flood, 'u.csv')) %>%
      filter(VALUE == 1) %>%
      select(-1, -2, -3) %>%
      pivot_longer(cols = everything(), names_to = 'value', values_to = 'sq_m') %>%
      separate(col = 'value', into = c(NA, 'year'), sep = '_') %>%
      arrange(year) %>%
      mutate(cumulative_sq_km = cumsum(sq_m) / 1e6) %>%
      select(-sq_m) %>%
      filter(year %in% c(1985, 2015)) %>%
      pull(cumulative_sq_km)
    flooded_85 <- ifelse(is.infinite(min(df)), 0, min(df)) + flooded_85
    flooded_15 <- ifelse(is.infinite(max(df)), 0, max(df)) + flooded_15
  }
  
  flooded_15
  (flooded_15 + not_flooded_15) / (flooded_85 + not_flooded_85)
  flooded_15 / flooded_85
  
  txt <- paste('From 1985 to 2015,', 'total built-up area has grown by', 
               paste0(round((((flooded_15 + not_flooded_15) / (flooded_85 + not_flooded_85)) - 1) * 100, 1), '%,'),
               'while built-up area exposed to',
               paste0(flood, 'luvial'),
               'flood has grown by',
               paste0(round((flooded_15 / flooded_85 - 1) * 100, 1), '%,'),
               'totaling',
               round(flooded_15, 1),
               'sq km.')
  
  write_lines(txt, paste0('stats/built_up_', flood, 'luvial_flood_growth.txt'))
}

# flood plot ----------------------------------------------------
plot_height <- 1600

flood_plot_func <- function(flood) {
  read_flood <- function(city) {
    df <- read_csv(paste0(city, '/stats/wsf_', flood, 'u.csv')) %>%
      mutate(city = city) %>%
      arrange(year)
    
    if (nrow(df) > 0) {
      sqkm_1985 <- df %>% filter(year == 1985) %>% pull(cumulative_sq_km)
      df %>% mutate(growth = cumulative_sq_km / sqkm_1985 * 100 - 100)
    } else {
      df
    }
  }
  
  # manually update according to the list of cities
  buk <- read_flood('Bukavu')
  bun <- read_flood('Bunia')
  gba <- read_flood('Gbadolite')
  gem <- read_flood('Gemena')
  gom <- read_flood('Goma')
  kan <- read_flood('Kananga')
  kik <- read_flood('Kikwit')
  kin <- read_flood('Kinshasa')
  kis <- read_flood('Kisangani')
  lub <- read_flood('Lubumbashi')
  mat <- read_flood('Matadi')
  mbu <- read_flood('Mbuji-Mayi')
  mwe <- read_flood('Mwene-Ditu')
  tsh <- read_flood('Tshikapa')
  
  all_cities <- rbind(buk, bun, gba, gem, gom, kan, kik, kin, kis, lub, mat, mbu, mwe, tsh) %>%  # manually update according to the list of cities
    arrange(-cumulative_sq_km)
  all_cities_2015 <- all_cities %>% filter(year == 2015)
  city_levels <- all_cities_2015$city
  all_cities <- all_cities %>%
    mutate(city = factor(city, levels = city_levels))
  
  all_cities %>%
    ggplot() +
    geom_line(aes(year, cumulative_sq_km, group = city, color = city), size = 0.5) +
    # scale_size_manual(values = c(0.5, 1), guide = 'none') +
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
          legend.position = 'right') +
    labs(title = paste0('Built-up area exposed to ', flood, 'luvial flood hazard\n(sq km)'))
  
  ggsave(paste0('plots/all_cities_', flood, 'u.png'),
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
    facet_wrap(vars(city)) +
    scale_x_continuous(breaks = seq(1985, 2015, 10)) +
    theme_minimal() +
    theme(panel.grid.minor = element_blank(),
          panel.spacing = unit(1, 'lines'),
          # axis.text.x = element_text(angle = 30, hjust = 1),
          # text = element_text(family = 'Helvetica', size = 13.5),
          axis.text = element_text(size = 8),
          axis.title = element_blank()) +
    labs(subtitle = paste0('Growth of built-up area exposed to ', flood, 'luvial flood hazard (%)'))
  
  ggsave(paste0('plots/all_cities_', flood, 'u_growth.png'),
         width = 1600, height = 1600, units = 'px')
}

for (flood in floods) {
  flood_plot_func(flood)
}
