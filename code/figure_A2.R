################################################################################
# Replication code for BDGLK (JDE 2024)
# Description:  Produces Figure A2

# Figure A2: Cumulative distribution of applied nitrogen equivalents for 
# pairwise comparisons of maize seed belief types at a 95\% purity threshold. 
# In panels (a) and (b), farmer beliefs differ but their seeds are the same 
# (i.e., traditional and improved, respectively). In panels (c) and (d), farmer 
# beliefs are the same (i.e., traditional and improved, respectively) but the 
# genetic identity of their seeds differ.

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
library(gridExtra)
library(tidyverse)

seeds <- read_dta("data/merged_data.dta") %>% 
  filter(is.na(puritypurityPercent) != TRUE)

# 'TP', 'FN'

c_fp_tn <- seeds %>% 
  select(nitrogen_kg_pha, seedtype, dna_95_95) %>% 
  mutate(seedtype = case_when(seedtype != 1 & dna_95_95 == 0 ~ "False positive (FP)",
                              seedtype == 1 & dna_95_95 == 0 ~ "True negative (TN)")) %>% 
  mutate(Type = as.factor(seedtype)) %>% 
  filter(is.na(Type) != TRUE)

c_fn_tp <- seeds %>% 
  select(nitrogen_kg_pha, seedtype, dna_95_95) %>% 
  mutate(seedtype = case_when(seedtype == 1 & dna_95_95 == 1 ~ "False negative (FN)",
                              seedtype != 1 & dna_95_95 == 1 ~ "True positive (TP)")) %>% 
  mutate(Type = as.factor(seedtype)) %>% 
  filter(is.na(Type) != TRUE)

c_fn_tn <- seeds %>% 
  select(nitrogen_kg_pha, seedtype, dna_95_95) %>% 
  mutate(seedtype = case_when(seedtype == 1 & dna_95_95 == 1 ~ "False negative (FN)",
                              seedtype == 1 & dna_95_95 == 0 ~ "True negative (TN)")) %>% 
  mutate(Type = as.factor(seedtype)) %>% 
  filter(is.na(Type) != TRUE)

c_fp_tp <- seeds %>% 
  select(nitrogen_kg_pha, seedtype, dna_95_95) %>% 
  mutate(seedtype = case_when(seedtype != 1 & dna_95_95 == 0 ~ "False positive (FP)",
                              seedtype != 1 & dna_95_95 == 1 ~ "True positive (TP)")) %>% 
  mutate(Type = as.factor(seedtype)) %>% 
  filter(is.na(Type) != TRUE)

my_pat <- c("solid", "dotted")

# Export in 1600x1200

my_pal <- c( "#d17141", "#364e70")

plot_c_fp_tn <- ggplot(data = c_fp_tn) + 
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
    legend.background = element_rect(fill = "white", size = 0.01, linetype = "solid", colour = "white"),
    text = element_text(size = 30)
  ) +
  scale_color_manual(values = my_pal) +
  ggtitle('(a) DNA type: traditional') +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(linetype = "Type") +  # Set the legend title for color
  scale_linetype_manual(
    values = c("solid", "solid"),
    guide = guide_legend(override.aes = list(linetype = c("solid", "solid"), size = 8))
  ) +
  scale_x_continuous(limits = c(0, 800))

plot_c_fp_tn

my_pal <- c( "#364e70", "#d17141")


plot_c_fn_tp <- ggplot(data = c_fn_tp) + 
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
    legend.background = element_rect(fill = "white", size = 0.01, linetype = "solid", colour = "white"),
    text = element_text(size = 30)
  ) +
  scale_color_manual(values = my_pal) +
  ggtitle('(b) DNA type: improved') +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(linetype = "Type") +  # Set the legend title for color
  scale_linetype_manual(
    values = c("dotted", "dotted"),
    guide = guide_legend(override.aes = list(linetype = c("dotted", "dotted"), size = 8))
  ) +
  scale_x_continuous(limits = c(0, 800))

plot_c_fn_tp

my_pal <- c( "#364e70", "#364e70")

plot_c_fn_tn <- ggplot(data = c_fn_tn) + 
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
    legend.background = element_rect(fill = "white", size = 0.01, linetype = "solid", colour = "white"),
    text = element_text(size = 30)
  ) +
  scale_color_manual(values = my_pal) +
  ggtitle('(c) Farmer self-report: traditional') +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(linetype = "Type") +  # Set the legend title for color
  scale_linetype_manual(
    values = c("dotted", "solid"),
    guide = guide_legend(override.aes = list(linetype = c("dotted", "solid"), size = 8))
  ) +
  scale_x_continuous(limits = c(0, 800))

plot_c_fn_tn

my_pal <- c( "#d17141", "#d17141")

plot_c_fp_tp <- ggplot(data = c_fp_tp) + 
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
    legend.background = element_rect(fill = "white", size = 0.01, linetype = "solid", colour = "white"),
    text = element_text(size = 30)
  ) +
  scale_color_manual(values = my_pal) +
  ggtitle('(d) Farmer self-report: improved') +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(linetype = "Type") +  # Set the legend title for color
  scale_linetype_manual(
    values = c("solid", "dotted"),
    guide = guide_legend(override.aes = list(linetype = c("solid", "dotted"), size = 8))
  ) +
  scale_x_continuous(limits = c(0, 800))

plot_c_fp_tp

#merge all three plots within one grid (and visualize this)
grid.arrange(plot_c_fp_tn, plot_c_fn_tp, plot_c_fn_tn, plot_c_fp_tp, ncol = 2, nrow = 2) 

#save
g <- arrangeGrob(plot_c_fp_tn, plot_c_fn_tp, plot_c_fn_tn, plot_c_fp_tp, nrow=2) #generates g
ggsave(file="outputs/figure_A2.jpg", g, width = 40, height = 40, unit = "cm", dpi = 300) #saves g
