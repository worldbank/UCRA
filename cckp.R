library(tidyverse)
library(lubridate)

options(scipen = 999)

csv_folder <- 'output/CCKP/'
tas <- list()
txx <- list()
pr <- list()
r95ptot <- list()
cdd <- list()
hd35 <- list()
tr26 <- list()
wsdi <- list()
r20mm <- list()
r50mm <- list()
spei12 <- list()
aep <- list()
ssps <- c('119', '245', '370')
vars <- c('anom', 'clim')
exclude_city <- c()
pal <- c('#FFC20A', '#0C7BDC')

df_process <- function(df) {
  df %>%
    filter(!city %in% exclude_city) %>%
    rename(val = `2040-2059`) %>%
    mutate(ssp_lab = paste0('SSP', substr(ssp, 1, 1), '-', substr(ssp, 2, 2), '.', substr(ssp, 3, 3)))
}

for (var in vars) {
  for (ssp in ssps) {
    tas[[var]][[ssp]] <- read_csv(paste0(csv_folder, var, '_tas_ssp', ssp, '.csv')) %>% df_process()
    txx[[var]][[ssp]] <- read_csv(paste0(csv_folder, var, '_txx_ssp', ssp, '.csv')) %>% df_process()
    pr[[var]][[ssp]] <- read_csv(paste0(csv_folder, var, '_pr_ssp', ssp, '.csv')) %>% df_process()
    r95ptot[[var]][[ssp]] <- read_csv(paste0(csv_folder, var, '_r95ptot_ssp', ssp, '.csv')) %>% df_process()
    cdd[[var]][[ssp]] <- read_csv(paste0(csv_folder, var, '_cdd_ssp', ssp, '.csv')) %>% df_process()
    hd35[[var]][[ssp]] <- read_csv(paste0(csv_folder, var, '_hd35_ssp', ssp, '.csv')) %>% df_process()
    tr26[[var]][[ssp]] <- read_csv(paste0(csv_folder, var, '_tr26_ssp', ssp, '.csv')) %>% df_process()
    wsdi[[var]][[ssp]] <- read_csv(paste0(csv_folder, var, '_wsdi_ssp', ssp, '.csv')) %>% df_process()
    r20mm[[var]][[ssp]] <- read_csv(paste0(csv_folder, var, '_r20mm_ssp', ssp, '.csv')) %>% df_process()
    r50mm[[var]][[ssp]] <- read_csv(paste0(csv_folder, var, '_r50mm_ssp', ssp, '.csv')) %>% df_process()
  }
}

for (ssp in ssps) {
  spei12[['clim']][[ssp]] <- read_csv(paste0(csv_folder, 'clim_spei12_ssp', ssp, '.csv')) %>% df_process()
}

for (ssp in ssps) {
  for (rp in c('20', '50')) {
    aep[[ssp]][[rp]] <- read_csv(paste0(csv_folder, 'aep_', rp, 'yr_ssp', ssp, '.csv')) %>%
      filter(!city %in% exclude_city) %>%
      rename(val = `2035-2064`) %>%
      mutate(ssp_lab = paste0('SSP', substr(ssp, 1, 1), '-', substr(ssp, 2, 2), '.', substr(ssp, 3, 3))) %>%
      mutate(rp = paste(rp, 'years'))
  }
}

## plot function ------------
base_plot_height <- 1000

# classic bar chart
cckp_plot <- function(df_list, plot_title, png_title, color) {
  city_levels <- df_list[[1]] %>%
    arrange(val) %>%
    pull(city) %>%
    unique()
  bind_rows(df_list) %>%
    mutate(city = factor(city, levels = city_levels)) %>%
    ggplot(aes(val, city)) +
    geom_vline(xintercept = 0, linewidth = 0.3, color = 'darkgrey') +
    geom_col(fill = color, width = 0.4) +
    facet_wrap('ssp_lab') +
    theme_minimal() +
    theme(panel.grid.minor = element_blank(),
          panel.grid.major.y = element_blank(),
          panel.spacing = unit(1, 'lines'),
          axis.title = element_blank(),
          axis.text.x = element_text(size = 7),
          legend.position = 'bottom',
          legend.title = element_blank(),
          plot.title = element_text(size = 10),
          plot.subtitle = element_text(size = 8, color = 'grey'),
          legend.key.size = unit(3, 'mm'),
          legend.text = element_text(size = 8)) +
    labs(title = plot_title,
         subtitle = 'Reference Period: 1995-2014')
  
  ggsave(paste0('plots/', png_title, '.png'),
         width = 2000, height = base_plot_height, units = 'px')
}

# bar chart + scatter plot
cckp_plot1 <- function(df_list1, df_list2, plot_title, png_title, color1, color2) {
  city_levels <- df_list1[[1]] %>%
    arrange(val) %>%
    pull(city) %>%
    unique()
  df1 <- bind_rows(df_list1) %>%
    mutate(city = factor(city, levels = city_levels))
  df2 <- bind_rows(df_list2)
  df1 %>%
    ggplot(aes(val, city)) +
    geom_vline(xintercept = 0, linewidth = 0.3, color = 'darkgrey') +
    geom_col(fill = color1, width = 0.4) +
    geom_point(data = df2, aes(val, city), color = color2, size = 3, shape = 18) +
    facet_wrap('ssp_lab') +
    theme_minimal() +
    theme(panel.grid.minor = element_blank(),
          panel.grid.major.y = element_blank(),
          panel.spacing = unit(1, 'lines'),
          axis.title = element_blank(),
          axis.text.x = element_text(size = 7),
          legend.position = 'bottom',
          legend.title = element_blank(),
          plot.title = element_text(size = 10),
          plot.subtitle = element_text(size = 8, color = 'grey'),
          legend.key.size = unit(3, 'mm'),
          legend.text = element_text(size = 8)) +
    labs(title = plot_title,
         subtitle = 'Reference Period: 1995-2014')
  
  ggsave(paste0('plots/', png_title, '.png'),
         width = 2000, height = base_plot_height, units = 'px')
}

# bar chart with two variables and legend at the bottom
cckp_plot2 <- function(df_list1, df_list2, plot_title, png_title, label1, label2, color1, color2) {
  city_levels <- df_list1[[1]] %>%
    arrange(val) %>%
    pull(city) %>%
    unique()
  df1 <- bind_rows(df_list1) %>%
    mutate(city = factor(city, levels = city_levels)) %>%
    mutate(label = label1)
  df2 <- bind_rows(df_list2) %>%
    mutate(label = label2)
  df <- rbind(df1, df2)
  df %>%
    ggplot(aes(val, city)) +
    geom_vline(xintercept = 0, linewidth = 0.3, color = 'darkgrey') +
    geom_col(aes(fill = label), width = 0.4, position = 'dodge') +
    facet_wrap('ssp_lab') +
    scale_fill_manual(values = c(color1, color2)) +
    theme_minimal() +
    theme(panel.grid.minor = element_blank(),
          panel.grid.major.y = element_blank(),
          panel.spacing = unit(1, 'lines'),
          axis.title = element_blank(),
          axis.text.x = element_text(size = 7),
          legend.position = 'bottom',
          legend.title = element_blank(),
          plot.title = element_text(size = 10),
          plot.subtitle = element_text(size = 8, color = 'grey'),
          legend.key.size = unit(3, 'mm'),
          legend.text = element_text(size = 8)) +
    labs(title = plot_title,
         subtitle = 'Reference Period: 1995-2014')
  
  ggsave(paste0('plots/', png_title, '.png'),
         width = 2000, height = base_plot_height + 100, units = 'px')
}

cckp_plot1(tas$clim, txx$clim, 'Projected Mean Temperature and Maximum of Daily Max-Temperature for 2040-2059 (°C)', 'tas_txx_clim', '#f5743d', 'red')
cckp_plot1(tas$anom, txx$anom, 'Projected Mean Temperature and Maximum of Daily Max-Temperature Anomaly (Change)\nfor 2040-2059 (°C)', 'tas_txx_anom', '#f5743d', 'red')
cckp_plot2(hd35$clim, tr26$clim, 'Projected Number of Hot Days and Tropical Nights for 2040-2059', 'hd35_tr26_clim', 
           '# of Hot Days (Tmax > 35°C)', '# of Tropical Nights (Tmin > 26°C)', '#faa884', '#FF6B6B')
cckp_plot2(hd35$anom, tr26$anom, 'Projected Number of Hot Days and Tropical Nights Anomaly (Change) for 2040-2059', 'hd35_tr26_anom', 
           '# of Hot Days (Tmax > 35°C)', '# of Tropical Nights (Tmin > 26°C)', '#faa884', '#FF6B6B')
cckp_plot(wsdi$clim, 'Projected Warm Spell Duration Index for 2040-2059 (day)', 'wsdi_clim', '#e3275f')
cckp_plot(wsdi$anom, 'Projected Warm Spell Duration Index Anomaly (Change) for 2040-2059 (day)', 'wsdi_anom', '#e3275f')

cckp_plot(pr$clim, 'Projected Annual Precipitation for 2040-2059 (mm)', 'pr_clim', pal[2])
cckp_plot(pr$anom, 'Projected Annual Precipitation Anomaly (Change) for 2040-2059 (mm)', 'pr_anom', pal[2])
cckp_plot2(r20mm$clim, r50mm$clim, 'Projected Days with Precipitation >20mm and >50mm for 2040-2059', 'r20mm_r50mm_clim', 
           '# of Days with Precipitation >20mm', '# of Days with Precipitation >50mm', '#8c96c6', '#88419d')
cckp_plot2(r20mm$anom, r50mm$anom, 'Projected Days with Precipitation >20mm and >50mm Anomaly (Change) for 2040-2059', 'r20mm_r50mm_anom', 
           '# of Days with Precipitation >20mm', '# of Days with Precipitation >50mm', '#8c96c6', '#88419d')
cckp_plot(r95ptot$clim, 'Projected Annual Precipitation Amount during Wettest Days for 2040-2059 (mm)', 'r95ptot_clim', '#0647c9')
cckp_plot(r95ptot$anom, 'Projected Annual Precipitation Amount during Wettest Days Anomaly (Change) for\n2040-2059 (mm)', 'r95ptot_anom', '#0647c9')
cckp_plot(cdd$clim, 'Projected Max Number of Consecutive Dry Days', 'cdd_clim', '#949353')
cckp_plot(cdd$anom, 'Projected Max Number of Consecutive Dry Days Anomaly (Change)', 'cdd_anom', '#949353')

# cckp_plot(tas$clim, 'Projected Mean Temperature for 2040-2059 (°C)', 'tas_clim', '#f5743d')
# cckp_plot(tas$anom, 'Projected Mean Temperature Anomaly (Change) for 2040-2059 (°C)', 'tas_anom', '#f5743d')

# cckp_plot(prpercnt$anom, 'Projected Annual Precipitation Percent Change for 2040-2059 (%)', 'prpercnt_anom', '#855ee0')
cckp_plot(spei12$clim, 'Projected Annual SPEI Drought Index for 2040-2059', 'spei12_clim', '#e09b5e')


city_levels <- aep[[1]][['50']] %>%
  arrange(val) %>%
  pull(city) %>%
  unique()
for (ssp in ssps) {
  aep[[ssp]] <- bind_rows(aep[[ssp]])
}
bind_rows(aep) %>%
  mutate(city = factor(city, levels = city_levels)) %>%
  ggplot(aes(val, city)) +
  geom_vline(xintercept = 1, linewidth = 0.3, color = 'darkgrey', alpha = 0) +
  geom_segment(data = . %>% pivot_wider(names_from = 'rp', values_from = 'val'),
               aes(x = `50 years`, xend = `20 years`, y = city, yend = city), 
               color = 'grey', alpha = 0.8) +
  geom_point(aes(color = rp), size = 3) +
  facet_wrap('ssp_lab') +
  scale_alpha_manual(values = c(0.4, 1), guide = 'none') +
  scale_color_brewer(palette = 'Set2') +
  scale_x_continuous(breaks = seq(1, 2.2, 0.4)) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.spacing = unit(1, 'lines'),
        axis.title = element_blank(),
        axis.text.x = element_text(size = 7),
        legend.position = 'bottom',
        legend.title = element_text(size = 8),
        plot.title = element_text(size = 10),
        plot.subtitle = element_text(size = 8, color = 'grey'),
        legend.key.size = unit(3, 'mm'),
        legend.text = element_text(size = 8)) +
  labs(title = 'Change in Annual Exceedance Probability of Largest 5-Day Cumulative Precipitation\nfor 2035-2064',
       subtitle = 'Reference Period: 1995-2014',
       color = 'Return Period')

ggsave(paste0('plots/', 'aep', '.png'),
       width = 2000, height = base_plot_height + 150, units = 'px')
