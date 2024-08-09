## figure3.R

library(haven)
library(gridExtra)
library(ggplot2)
library(tidyr)
library(dplyr)

df_yields <- read_dta("data/production_data.dta")

# D. Residuals are plotted ----
# 'TP', 'FN'

c_survey_improved <- df_yields %>% 
  filter(is.na(seedtype) == FALSE) %>% 
  select(yield_per_ha, seedtype, dna_95_95) %>% 
  filter(seedtype != 1) %>% 
  mutate(seedtype = case_when(dna_95_95 == 0 ~ "False positive",
                              dna_95_95 == 1 ~ "True positive")) %>% 
  mutate(Type = as.factor(seedtype)) %>% 
  filter(is.na(Type) == FALSE)

c_survey_traditional <- df_yields %>% 
  filter(is.nan(seedtype) == FALSE) %>% 
  select(yield_per_ha, seedtype, dna_95_95) %>% 
  filter(seedtype == 1) %>% 
  mutate(seedtype = case_when(dna_95_95 == 0 ~ "True negative",
                              dna_95_95 == 1 ~ "False negative")) %>% 
  mutate(Type = as.factor(seedtype)) %>% 
  filter(is.na(Type) == FALSE)

c_dna_improved <- df_yields %>% 
  filter(is.na(seedtype) == FALSE) %>% 
  select(yield_per_ha, dna_95_95, seedtype) %>% 
  filter(dna_95_95 == 1) %>% 
  mutate(dna_95_95 = case_when(seedtype == 1 ~ "False negative",
                               seedtype != 1 ~ "True positive")) %>% 
  mutate(Type = as.factor(dna_95_95)) %>% 
  filter(is.na(Type) == FALSE)

c_dna_traditional <- df_yields %>% 
  filter(is.na(seedtype) == FALSE) %>% 
  select(yield_per_ha, dna_95_95, seedtype) %>% 
  filter(dna_95_95 == 0) %>% 
  mutate(dna_95_95 = case_when(seedtype == 1 ~ "True negative",
                               seedtype != 1 ~ "False positive")) %>% 
  mutate(Type = as.factor(dna_95_95)) %>% 
  filter(is.na(Type) == FALSE)

# Export in 1600x1200

my_pal <- c( "#d17141", "#364e70")

plot_c_dna_traditional <- ggplot(data = c_dna_traditional) + 
  stat_ecdf(geom = "step", size = 2, mapping = aes(x = yield_per_ha, color = Type, linetype = Type)) + 
  ylab("Cumulative probability density") + 
  xlab("Maize yield (kg/ha)") + 
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
  )

my_pal <- c("#364e70", "#d17141")

plot_c_dna_improved <- ggplot(data = c_dna_improved) + 
  stat_ecdf(geom = "step", size = 2, mapping = aes(x = yield_per_ha, color = Type, linetype = Type)) + 
  ylab("Cumulative probability density") + 
  xlab("Maize yield (kg/ha)") + 
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
  )

my_pal <- c("#364e70", "#364e70")

plot_c_survey_traditional <- ggplot(data = c_survey_traditional) + 
  stat_ecdf(geom = "step", size = 2, mapping = aes(x = yield_per_ha, color = Type, linetype = Type)) + 
  ylab("Cumulative probability density") + 
  xlab("Maize yield (kg/ha)") + 
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
  )

my_pal <- c("#d17141", "#d17141")

plot_c_survey_improved <- ggplot(data = c_survey_improved) + 
  stat_ecdf(geom = "step", size = 2, mapping = aes(x = yield_per_ha, color = Type, linetype = Type)) + 
  ylab("Cumulative probability density") + 
  xlab("Maize yield (kg/ha)") + 
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
  )


#merge all three plots within one grid (and visualize this)
grid.arrange(plot_c_dna_traditional, plot_c_dna_improved, 
             plot_c_survey_traditional, plot_c_survey_improved, ncol = 2, nrow = 2) 

#save
g <- arrangeGrob(plot_c_dna_traditional, plot_c_dna_improved, 
                 plot_c_survey_traditional, plot_c_survey_improved, nrow=2) #generates g
ggsave(file="outputs/figure_A3.jpg", g, width = 40, height = 40, unit = "cm", dpi = 300) #saves g
