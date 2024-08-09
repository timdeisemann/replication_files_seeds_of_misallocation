################################################################################
# Replication code for BDGLK (JDE 2024)
# Description:  Produces Figure 1

# Figure 1: Distribution of seed beliefs for improved maize varieties at the 
# plot-level based on farmer self-reports in survey and DNA fingerprinting 
# results for different genetic purity thresholds for distinguishing improved 
# from traditional seeds. Color indicates the farmer belief (orange = improved, 
# blue = traditional), and pattern denotes the DNA type (dots = improved, none 
# = traditional).

# For any questions, please get in touch with Tim Deisemann, deisemat@ebrd.com
# Updated April 21, 2024
################################################################################

# Clear existing workspace (optional, uncomment if needed)
# rm(list=ls())

# Set the working directory to the parent folder
# Adjust the path below to the location of the 'replication_files_devec-d-23-01245' folder on your machine
# setwd("/pathTo/replication_files_devec-d-23-01245")

# Load required libraries (uncomment the libraries you need)

library(tidyverse)
library(data.table)
library(readr)
library(ggplot2)
library(ggpattern)
library(tidyr)
library(dplyr)
library(readr)
library(stringr)
library(grid)
library(gridExtra) 

figure1_data <- read_csv("data/figure1_data.csv", 
                         show_col_types = FALSE)

figure1_data_gathered <- figure1_data %>% 
  pivot_longer(cols = tp_70:fn_975,
               names_to = c("outcome", "threshold"),
               names_sep = '_') %>% 
  filter(value != "0") %>% 
  arrange(match(outcome, c("tp", "fp", "tn", "fn"))) %>% 
  mutate(Variable = factor(outcome),
         Type = case_when(Variable == "tp" ~ "True positive (TP)",
                          Variable == "fp" ~ "False positive (FP)",
                          Variable == "tn" ~ "True negative (TN)",
                          Variable == "fn" ~ "False negative (FN)"),
         "DNA" = case_when(Variable == "tp" ~ "improved",
                           Variable == "fp" ~ "traditional",
                           Variable == "tn" ~ "traditional",
                           Variable == "fn" ~ "improved",
                           TRUE ~ NA_character_),
         "Survey response" = case_when(Variable == "tp" ~ "improved",
                                       Variable == "fp" ~ "improved",
                                       Variable == "tn" ~ "traditional",
                                       Variable == "fn" ~ "traditional",
                                       TRUE ~ NA_character_))

figure1_data_gathered$Variable <- factor(figure1_data_gathered$Variable, levels = c("tp", "fp", "tn", "fn"))
figure1_data_gathered$Type <- factor(figure1_data_gathered$Type, levels = c("True positive (TP)", "False positive (FP)", "True negative (TN)", "False negative (FN)"))
figure1_data_gathered$DNA <- factor(figure1_data_gathered$DNA, levels = c("improved", "traditional"))
figure1_data_gathered$`Survey response` <- factor(figure1_data_gathered$`Survey response`, levels = c("improved", "traditional"))

figure1_data_gathered <- figure1_data_gathered %>% 
  mutate(threshold = case_when(threshold == "925" ~ "92.5",
                               threshold == "975" ~ "97.5",
                               TRUE ~ threshold)) 
# Define a pattern palette for the bars
patterns <- c("circle", "stripe", "circle", "point")

# Define a color palette for the bars
colors <- c("#d17141", "#d17141", "#364e70", "#364e70")

theme_set(
  theme_minimal()
)

grid.newpage()

my_plot <- ggplot(figure1_data_gathered, aes(x = factor(threshold), fill = Type, pattern = Type)) + 
  geom_bar_pattern(pattern_color = NA,
                   pattern_fill = "white",
                   pattern_angle = 45,
                   pattern_density = 0.35,
                   pattern_spacing = 0.01,
                   pattern_key_scale_factor = 1) +
  scale_pattern_manual(values = c('True positive (TP)' = "circle", 'False positive (FP)' = "none", 'True negative (TN)' = "none", 'False negative (FN)' = "circle")) +
  # Specify the colors for the bars
  scale_fill_manual(values = colors) +
  # Add axis labels and a title
  xlab("Purity threshold in %") +
  ylab("Number of plots") +
  theme(legend.position = "none") + # theme(legend.position = "right") +
  theme(text = element_text(size = 30)) +
  theme(legend.spacing.y = unit(1.0, 'cm'))  +
  ## important additional element
  guides(fill = guide_legend(byrow = TRUE)) +
  theme(axis.title = element_text(margin = ggplot2::margin(t = -20, r = 0, b = 0, l = 0)))

grid.draw(my_plot)

#save
ggsave(file="outputs/figure_1.jpg", my_plot, width = 20, height = 20, unit = "cm", dpi = 300)

################################################################################

## legend only

colors <- c("#d17141", "#364e70")

figure1_data_gathered <- figure1_data_gathered %>% 
  rename("Farmer self-report" = `Survey response`)

my_hist <- ggplot(figure1_data_gathered, aes(x = factor(threshold), fill = `Farmer self-report`, pattern = DNA)) + 
  geom_bar_pattern(pattern_color = NA,
                   pattern_fill = "white",
                   pattern_angle = 45,
                   pattern_density = 0.35,
                   pattern_spacing = 0.05,
                   pattern_key_scale_factor = 1) +
  scale_pattern_manual(values = c("circle", "none", "none", "circle")) +
  # Specify the colors for the bars
  scale_fill_manual(values = colors) +
  # Add axis labels and a title
  xlab("Purity threshold in %") +
  ylab("Number of plots") +
  theme(legend.position = "right") +
  theme(text = element_text(size = 30)) +
  guides(pattern = guide_legend(
    title = "DNA type",
    #direction = "horizontal",
    title.position = "top",
    label.position = "right",
    label.hjust = 0.5,
    label.vjust = 1
    #label.theme = element_text(angle = 90)
    , override.aes = list(fill = "#808080")), ##snow2
    fill = guide_legend(override.aes = list(pattern = "none"))) +
#ggtitle("Stacked Bar Plot with Colors and Patterns") 
  theme(legend.text = element_text(size=30)) +
  theme(legend.key.height= unit(2, 'cm'),
        legend.key.width= unit(4, 'cm'))

# Using the cowplot package
legend <- cowplot::get_legend(my_hist)

grid.newpage()

grid.draw(legend)

#save
ggsave(file="outputs/figure_1_legend.jpg", legend, width = 20, height = 20, unit = "cm", dpi = 300) #saves g
