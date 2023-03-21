library(tidyverse)

cities <- read_csv('centroids.csv') %>% pull(city)
floods <- c('fu', 'pu')
years <- c('2050', '2100')

# built-up flood exposure -----------------------

flood_wsf0 <- function(city) {
  city1 <- gsub('-', '_', gsub(' ', '_', tolower(city)))
  
  flood_wsf <- function(flood_type) {
    df <- read_csv(paste0(city, '/data/', city1, '_', flood_type, '.csv')) %>%
      filter(VALUE == 1) %>%
      select(-1, -2, -3) %>%
      pivot_longer(cols = everything(), names_to = 'value', values_to = 'sq_m') %>%
      separate(col = 'value', into = c(NA, 'year'), sep = '_') %>%
      arrange(year) %>%
      mutate(cumulative_sq_km = cumsum(sq_m) / 1e6) %>%
      select(-sq_m)
    write_csv(df, paste0(city, '/stats/wsf_', flood_type, '.csv'))
  }
  
  lapply(floods, flood_wsf)
}

lapply(cities, flood_wsf0)

# projected built-up flood exposure -------------------------

ssps <- 1:3

proj_bu_flood <- list()

for (city in cities) {
  city1 <- gsub(' ', '_', tolower(city))
  city2 <- gsub('-', '_', city1)
  for (flood in floods) {
    for (ssp in ssps) {
      for (year in years) {
        df3 <- read_csv(paste0(city, '/data/', city2, '_ssp', ssp, '_', flood, '_', year, '.csv'))

        if (1 %in% df3$Value) {
          proj_bu_flood[[paste(city, flood, ssp, year, sep = '_')]] <- df3 %>%
            filter(Value == 1) %>%
            mutate(val = SUM * AREA / COUNT) %>%
            pull(val)
        } else {
          proj_bu_flood[[paste(city, flood, ssp, year, sep = '_')]] <- 0
        }
      }
    }
  }
}

df <- stack(proj_bu_flood) %>%
  rename('exposed_area_sqm' = 'values') %>%
  separate(col = 'ind', into = c('city', 'flood', 'ssp', 'year'), sep = '_') %>%
  mutate(exposed_area_sqkm = exposed_area_sqm / 1e6) %>%
  select(-exposed_area_sqm)

write_csv(df, 'stats/projected_built_up_flood_exposure.csv')
