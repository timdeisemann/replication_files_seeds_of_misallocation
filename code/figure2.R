################################################################################
# Replication code for BDGLK (JDE 2024)
# Description:  Produces Figure 2

# Figure 2: Cumulative distribution of purchased fertilizer measured in nitrogen 
# equivalents by (a) DNA type at a 95\% purity threshold and (b) self-reported 
# seed belief.

# For any questions, please get in touch with Tim Deisemann, deisemat@ebrd.com
# Updated April 21, 2024

################################################################################

# Clear existing workspace (optional, uncomment if needed)
# rm(list=ls())

# Set the working directory to the parent folder
# Adjust the path below to the location of the 'replication_files_devec-d-23-01245' folder on your machine
# setwd("/pathTo/replication_files_devec-d-23-01245")

# Load required libraries (uncomment the libraries you need)

library(haven)
library(grid)
library(gridExtra)
library(tidyverse)

seeds <- read_dta(paste0(getwd(), "/data/merged_data.dta")) %>% 
  filter(is.na(puritypurityPercent) != TRUE)

# 'TP', 'FN'
my_pal <- c( "#d17141", "#364e70")

c_survey <- seeds %>% 
  select(nitrogen_kg_pha, seedtype) %>% 
  mutate(seedtype = case_when(seedtype == 1 ~ "Belief: traditional",
                              seedtype != 1 ~ "Belief: improved")) %>% 
  mutate(Type = as.factor(seedtype)) 
  
c_dna <- seeds %>% 
    select(nitrogen_kg_pha, dna_95_95) %>% 
    mutate(dna_95_95 = case_when(dna_95_95 == 0 ~ "DNA: traditional",
                                dna_95_95 == 1 ~ "DNA: improved")) %>% 
  mutate(Type = as.factor(dna_95_95)) 

my_pat <- c("solid", "dotted")

# Export in 1600x1200

my_pal <- c( "#d17141", "#364e70")

plot_c_dna <- ggplot(data = c_dna) + 
  stat_ecdf(geom = "step", size = 2, mapping = aes(x = nitrogen_kg_pha, color = Type, linetype = Type)) + 
  ylab("Cumulative probability density") + 
  xlab("Nitrogen (kg/ha)") + 
  theme_minimal() + 
  theme(plot.title = element_text(size = 30)) +
  theme(
    legend.position = c(0.95, 0.05),
    legend.justification = c("right", "bottom"),
    legend.box.just = "right",
    legend.margin = ggplot2::margin(6, 6, 6, 6),
    legend.background = element_rect(fill = "white", linewidth = 0.01, linetype = "solid", colour = "white"),
    text = element_text(size = 30)
  ) +
  scale_color_manual(values = my_pal) +
  ggtitle('(a) DNA fingerprinting results') +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(linetype = "Type") +  # Set the legend title for color
  scale_linetype_manual(
    values = c("dotted", "solid"),
    guide = guide_legend(override.aes = list(linetype = c("dotted", "solid"), size = 8))
  ) + theme(aspect.ratio=1)

plot_c_dna

my_pal <- c( "#d17141", "#364e70")

plot_c_survey <- ggplot(data = c_survey) + 
  stat_ecdf(geom = "step", size = 2, mapping = aes(x = nitrogen_kg_pha, color = Type, linetype = Type)) + 
  ylab("Cumulative probability density") + 
  xlab("Nitrogen (kg/ha)") + 
  theme_minimal() + 
  theme(plot.title = element_text(size = 30)) +
  theme(
    legend.position = c(0.95, 0.05),
    legend.justification = c("right", "bottom"),
    legend.box.just = "right",
    legend.margin = ggplot2::margin(6, 6, 6, 6),
    legend.background = element_rect(fill = "white", linewidth = 0.01, linetype = "solid", colour = "white"),
    text = element_text(size = 30)
  ) +
  scale_color_manual(values = my_pal) +
  ggtitle('(b) Farmer self-reports in survey') +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(linetype = "Type") +  # Set the legend title for color
  scale_linetype_manual(
    values = c("dotted", "solid"),
    guide = guide_legend(override.aes = list(linetype = c("dotted", "solid"), size = 8))
  ) + theme(aspect.ratio=1)

plot_c_survey

grid.arrange(plot_c_dna, plot_c_survey, ncol = 2, nrow = 1) 
# Export using width = 1500, height = 750 for good proportions

#save
g <- arrangeGrob(plot_c_dna, plot_c_survey, nrow=1) #generates g
ggsave(file="outputs/figure_2.jpg", g, width = 40, height = 20, unit = "cm", dpi = 300) #saves g

