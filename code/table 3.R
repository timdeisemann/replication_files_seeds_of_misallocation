#############################################################################################################################################################################
# Prediction Task Code:
#############################################################################################################################################################################

# Note: before running this script, set_up_R_environment.R needs to be run

# Note: when running the code to replicate the results in the paper, the script needs to be executed as a whole
# and not run line by line. Only this ensures that the seed is set accurately in order to replicate results


# Key Output Dataframes:
# SuperLearner Performance: superlearner_performance
# Percentage outputs (shares of belief type): percentage_output
# Per hectar fertilizer use: fertilizer_output_per_ha
# National Level Maize Area: hectarage_output
# National Level Fertilizer Use (under observed beliefs): fertilizer_output
# FP and FN Fertilizer under corrected belief: fertilizer_output_corrected_belief



# Section 1: Utils --------------------------------------------------------


# Load all packages required 

library(tidyverse)
library(reshape2)
library(dplyr)
library(tidyr)
library(zoo)
library(stringr)
library(writexl)
library(SuperLearner)
library(randomForest)
library(CatEncoders)
library(haven)
library(xgboost)
library(sjmisc)
library(fastDummies)
library(LogicReg)
library(ipred)
library(randomForest)
library(foreign)
library(Metrics)
library(fastDummies)
library(glmnet)
library(caret)
library(yardstick)



# Section 2: Data inputs --------------------------------------------------

#User defined path (to be filled in by User)

global_path <- ""


# Set seed

set.seed(1)


# Read in seeds data

df_input <- read_dta(paste0(global_path,"data/merged_data.dta")) 



# Filter data to only include regions for which the crop-cut was performed:

# Cropcut is performed for the regions of: Amhara, Dire Dawa, Harar, Oromia, Southern Nations, Nationalities, and Peoples Region (SNNPR), and Tigray
# Dire Dawa observations are excluded since only one observation is included in the DNA subsample 


cropcut_regions <- c(1, 3, 4, 7, 13)

df_seeds_data_training_crop_cut_regions <- df_input %>%
  dplyr::select(saq01, everything()) %>%
  filter(saq01 %in% cropcut_regions) %>%
  dplyr::select(saq01, everything())


# Section 3: Prepare data for superlearner:  --------------------------------------------------

df_seeds_data_dna <- tibble::rowid_to_column(df_seeds_data_training_crop_cut_regions, "index") %>%
  rename(dna = dna_95_95) %>%
  dplyr::select(index, dna, everything())
  

# 1) Exclude variables highly correlated with DNA from prediction exercise----

# Exclude variables from seed data (that are  strongly correlated to the DNA variable/part of the DNA measurement)
df_seeds_data_dna_2 <- df_seeds_data_dna %>%
  dplyr::select(-c(
    "subbinreferences", "name", "crop", "variety_type", "crop_specific_variety_type", "year_release",
    "def1_status", "def2_status", "def3_status", "def4_status", "dtmz_status", "qpm_status", "cg_source",
    "exotic_source", "ID", "puritypurityPercent"
  )) %>%
  dplyr::select(index, dna, pw_w4, everything())


# 3)Define candidate variables to include in prediction exercise  ----

binary <- c("compost_use","any_prevention_binary")


numerical <- c("belief", "s7q12", "s7q14", "s7q19", "s7q20", "s7q21", "s7q22", "s7q23", "s7q32a_1", "s7q32b_1", "s7q32c_1", "s4q11a", "s4q21a", "s4q21b", "s3q08", "s3q28", "s3q30a", "s3q30d", "s3q30g", "s3q31a", "s3q31c", "saq12", "saq16", "s1q03a", "s1q06", "s4q03a", "s4q03b", "s4q04a", "s4q04b", "cs3q02", "cs3q03", "cs3q04b", "cs3q06", "cs3q09", "cs3q10", "cs3q11", "cs3q12b_1", "cs4q02", "cs4q06", "cs4q07a", "cs4q16", "cs4q17", "cs4q18", "cs4q21", "cs4q23", "cs4q24", "cs4q25", "cs4q26", "dist_road", "dist_market", "dist_border", "dist_popcenter", "dist_admhq", "twi", "af_bio_1", "af_bio_8", "af_bio_12", "af_bio_13", "af_bio_16", "slopepct", "srtm1k", "popdensity", "cropshare", "h2018_tot", "h2018_wetQstart", "h2018_wetQ", "h2019_tot", "h2019_wetQstart",
                   "h2019_wetQ", "anntot_avg", "wetQ_avgstart", "wetQ_avg", "h2018_ndvi_avg", "h2018_ndvi_max", "h2019_ndvi_avg", "h2019_ndvi_max", "ndvi_avg", "ndvi_max", "plot_twi", "plot_srtm", "plot_srtmslp", "manure_use", "nitrogen_kg_pha", "dist_household", "s3q08_ha", "phosphorus_kg_pha") 



categorical <- c("saq01", "saq15", "s7q01", "s7q02", "s7q04", "s7q06", "s7q09", "s7q11_1", "s7q15", "s7q16", "s7q17", "s7q29", "s4q02", "s4q04", "s4q08", "s4q13a", "s4q13b", "s4q14", "s4q22", "s3q03b", "s3q04", "s3q12", "s3q14", "s3q17",
                    "s3q24", "s3q25", "s3q26", "s3q27", "s3q34", "s3q37", "s3q38", "s3q40", "s2q03", "s2q05", "s2q16", "s5q12", "s5q16", "s1q01", "s1q02", "s1q08", "s1q09", "s1q12", "s1q13", "s1q17", "s1q16", "s1q20", "s1q21", "s1q22", "s2q01", "s2q04", "s2q19",
                     "s4q01", "s4q33b", "s4q45", "s4q48", "s4q51", "s4q53", "s11b_ind_01", "cs2aq01", "cs2aq02", "cs2aq03", "cs2aq05", "cs2aq06", "cs2aq07", "cs2aq09", "cs2aq11", "cs3q01", "cs3q04a", "cs3q07", "cs3q08", "cs3q11a", "cs3q12a_1", "cs4q01", "cs4q03", "cs4q04__0", "cs4q04__1", "cs4q04__2", "cs4q04__3", "cs4q04__4",
                     "cs4q04__5", "cs4q04__6", "cs4q04__7", "cs4q04__8", "cs4q04__9", "cs4q04__10", "cs4q04__11", "cs4q04__12", "cs4q04__13", "cs4q05__0", "cs4q05__1", "cs4q05__2", "cs4q05__3", "cs4q05__4", "cs4q05__5", "cs4q05__6", "cs4q05__7", "cs4q05__8", "cs4q05__9", "cs4q05__10", "cs4q05__11", "cs4q05__12", "cs4q05__13", "cs4q11", "cs4q14", "cs4q19", "cs4q20", "cs4q22", "cs4q27",
                     "cs4q34", "cs4q38", "cs4q39", "cs4q41", "cs4q43", "cs4q47", "cs4q50", "cs4q52", "cs4q54", "cs4q56", "cs4q58", "cs5q01_1", "cs5q02", "cs5q06", "cs5q09", "cs6q01", "ssa_aez09", "sq1", "sq2", "sq3", "sq4", "sq5", "sq6", "sq7", "gender","s3q10")


categoricals_used_in_appendix <- c("s3q16","s5q02")


PDS_lasso_variables <- c("individual_id", "cs4q29", "cs4q30", "cs4q31", "cs4q32", "cs4q33", "parcel_id", "field_id", "crop_id")


df_seeds_data_dna_3 <- df_seeds_data_dna_2 %>%
  dplyr::select(c(dna, binary, numerical, categorical,categoricals_used_in_appendix))


df_seeds_data_merge_3 <- df_seeds_data_dna_2 %>%
  dplyr::select(c(dna, pw_w4, binary, numerical, categorical,categoricals_used_in_appendix))

df_lasso_variables <- df_seeds_data_dna_2 %>%
  dplyr::select(PDS_lasso_variables)

# 3) Exclude binaries that are just zeros ----

seeds_binaries <- df_seeds_data_dna_3 %>%
  dplyr::select(binary)


all_zeros_columns <- colSums(seeds_binaries == 0) == nrow(seeds_binaries)


columns_with_only_zeros <- names(seeds_binaries)[all_zeros_columns]

df_seeds_data_dna_4 <- df_seeds_data_dna_3 %>%
  dplyr::select(-c(columns_with_only_zeros))


df_seeds_data_merge_4 <- df_seeds_data_merge_3 %>%
  dplyr::select(-c(columns_with_only_zeros))


# 4)Exclude columns with NAs ----

# Identify variables/columns from the dataframe that have NAs

variables_with_na <- as.data.frame(
  cbind(
    lapply(
      lapply(df_seeds_data_dna_4, is.na), sum
    )
  )
)

variables_with_na_merge <- as.data.frame(
  cbind(
    lapply(
      lapply(df_seeds_data_merge_4, is.na), sum
    )
  )
)


# Isolate column names for which there are NA values ----
drop_columns <- rownames(subset(variables_with_na, variables_with_na$V1 != 0))

drop_columns_merge <- rownames(subset(variables_with_na_merge, variables_with_na_merge$V1 != 0))


# Drop all columns for which there are NA values ----
df_seeds_data_dna_clean <- df_seeds_data_dna_4 %>%
  dplyr::select(dna, c(!drop_columns))

df_seeds_data_clean_merge <- df_seeds_data_merge_4 %>%
  dplyr::select(dna, pw_w4, c(!drop_columns_merge))


# 5)Transform categorical variables into dummies in order to use in the SuperLearner ----

categorical_encode <- c(categorical, categoricals_used_in_appendix)


df_seeds_clean_with_categoricals <- dummy_cols(df_seeds_data_dna_clean,
  select_columns = categorical_encode,
  remove_first_dummy = TRUE 
) 



df_split_categoricals_merge <- dummy_cols(df_seeds_data_clean_merge,
  select_columns = categorical_encode,
  remove_first_dummy = TRUE
) 



saveRDS(df_seeds_clean_with_categoricals, paste0(global_path, "data/seeds_data_prediction_preprocessed.rds"))



# Section 4: Set up and train Superlearner algorithm   --------------------------------------------------


# A: Set-up of the SuperLearner Algorithm ----


# Isolate training and validation data:
df_DNA_sampling <- df_seeds_clean_with_categoricals %>%
  filter(!is.na(dna)) %>%
  dplyr::select(-c(categoricals_used_in_appendix, categorical))



# Extract our outcome variable from the dataframe.
outcome <- df_DNA_sampling$dna

# Create a dataframe to contain our explanatory variables.
data <- subset(df_DNA_sampling, select = c(-dna))

#Split sample into training and validation stratified by the outcome variable
train_obs <- createDataPartition(df_DNA_sampling$dna, p = 0.7, list = FALSE)[,1]

x_train <- data[train_obs, ]

# Create a holdout set for evaluating model performance.

x_holdout <- data[-train_obs, ]


# Define DNA as the outcome variable to predict
outcome_bin <- df_DNA_sampling$dna

y_train <- outcome_bin[train_obs]

y_holdout <- outcome_bin[-train_obs]


# B: Set- up algorithms included in SuperLearner  ----


# Define random forest screener algorithm

custom_rf_screener <- function(Y, X, family, nVar = 200, ntree = 1000, mtry = ifelse(family$family == "gaussian", floor(sqrt(ncol(X))), max(floor(ncol(X) / 3), 1)), nodesize = ifelse(family$family == "gaussian", 5, 1), maxnodes = NULL, ...) {
  if (family$family == "gaussian") {
    rank.rf.fit <- randomForest::randomForest(Y ~ ., data = X, ntree = ntree, mtry = mtry, nodesize = nodesize, keep.forest = FALSE, maxnodes = maxnodes)
  }
  if (family$family == "binomial") {
    rank.rf.fit <- randomForest::randomForest(as.factor(Y) ~ ., data = X, ntree = ntree, mtry = mtry, nodesize = nodesize, keep.forest = FALSE, maxnodes = maxnodes)
  }

  whichVariable <- (rank(-rank.rf.fit$importance) <= nVar)
  return(whichVariable)
}



# Hyperparameter tuning for the XGBOOST algorithm ----

tune <- list(
  ntrees = c(50, 100, 150),
  max_depth = c(3, 6),
  shrinkage = c(0.01, 0.1)
)


learners <- create.Learner("SL.xgboost", tune = tune, detailed_names = TRUE, name_prefix = "xgb")

# Training the SuperLearner  ----



# Run SuperLearner with specified control and custom learners
s1 <- SuperLearner(
  Y = y_train, X = x_train, family = binomial(),
  cvControl = list(V = 6, stratifyCV = TRUE),
  method = "method.AUC",
  SL.library = list(
    c("SL.randomForest", "custom_rf_screener"),
    c("SL.ipredbagg", "custom_rf_screener"),
    c(learners$names[2], "custom_rf_screener"),
    c(learners$names[3], "custom_rf_screener"),
    c(learners$names[4], "custom_rf_screener"),
    c(learners$names[5], "custom_rf_screener"),
    c(learners$names[6], "custom_rf_screener"),
    c(learners$names[7], "custom_rf_screener"),
    c(learners$names[8], "custom_rf_screener"),
    c(learners$names[9], "custom_rf_screener"),
    c(learners$names[10], "custom_rf_screener"),
    c(learners$names[11], "custom_rf_screener"),
    c(learners$names[12], "custom_rf_screener"),
    c("SL.glmnet", "custom_rf_screener")
  )
)


# Section 5: Evaluate performance of the SuperLearner  --------------------------------------------------


# Predict on the validation set

# Predict on validation set ----

# Run prediction based on Ensemble Model:
pred <- predict(s1, x_holdout, onlySL = TRUE)
#replace with cv superlearner here and see if it works 


# Evaluate performance of the model

# AUC
pred_rocr <- ROCR::prediction(pred$pred, y_holdout)
auc <- ROCR::performance(pred_rocr, measure = "auc", x.measure = "cutoff")@y.values[[1]]
auc

pred_binary <- round(pred$pred, digits = 0)


# Accuracy
accuracy <- Metrics::accuracy(y_holdout, pred_binary)

# Precision
precision <- Metrics::precision(y_holdout, pred_binary)

# Recall
recall <- Metrics::recall(y_holdout, pred_binary)


#Balanced accuracy

y_holdout_factor <- as.factor(y_holdout)
pred_binary_factor <- as.factor(pred_binary)

balanced_accuracy <- bal_accuracy_vec(y_holdout_factor, pred_binary_factor)


# Return dataframe summarizing performance

F1 <- (2*recall*precision)/(recall+precision)


superlearner_performance <- data.frame(
  AUC = auc,
  Accuracy = accuracy,
  Balanced_Accuracy = balanced_accuracy,
  Precision = precision,
  Recall = recall,
  F1 = F1
)



# 5) Apply SuperLearner Algorithm to non-DNA sample -------------------------

# Pre-process survey data

# Isolate observations without DNA measurement
df_DNA_prediction <- df_seeds_clean_with_categoricals %>%
  filter(is.na(dna)) %>%
  dplyr::select(-c(dna, categoricals_used_in_appendix, categorical))


# Isolate only DNA fingerprinting data to append to the final data-frame later
df_DNA_incl_genetic_fingerprinting <- df_seeds_clean_with_categoricals %>%
  filter(!is.na(dna)) %>%
  mutate(dna = as.character(dna))


# Perform the same operations on merge dataset
df_DNA_prediction_merge <- df_split_categoricals_merge %>%
  filter(is.na(dna)) %>%
  dplyr::select(-c(dna))


df_DNA_incl_genetic_fingerprinting_merge <- df_split_categoricals_merge %>%
  filter(!is.na(dna)) %>%
  mutate(dna = as.numeric(dna))



# Predict DNA on testing data and save outputs ----


predicted_DNA_testing_sample <- predict(s1, df_DNA_prediction, onlySL = TRUE)


df_predicted_DNA_full <- as.data.frame(predicted_DNA_testing_sample[["pred"]]) %>%
  rename(dna = V1)


# Bind prediction result column with survey data and combine with DNA fingerprinting data ----


df_merged <- df_predicted_DNA_full %>%
  bind_cols(df_DNA_prediction_merge) %>%
  mutate(dna = as.numeric(dna)) %>%
  bind_rows(df_DNA_incl_genetic_fingerprinting_merge)


# Calculate TP/FP/TN/FN percentage  ----


df_merge_full_conf <- df_merged %>%
  dplyr::select(dna, belief, everything()) %>%
  mutate(belief = as.numeric(belief)) %>%
  mutate(tp_percentage = case_when(
    belief == 0 ~ 0,
    belief == 1 ~ dna, TRUE ~ 0
  )) %>%
  mutate(fp_percentage = case_when(
    belief == 0 ~ 0,
    belief == 1 ~ 1 - dna, TRUE ~ 0
  )) %>%
  mutate(tn_percentage = case_when(
    belief == 0 ~ 1 - dna,
    belief == 1 ~ 0, TRUE ~ 0
  )) %>%
  mutate(fn_percentage = case_when(
    belief == 0 ~ dna,
    belief == 1 ~ 0, TRUE ~ 0
  )) %>%
  dplyr::select(dna, belief, tp_percentage, fp_percentage, tn_percentage, fn_percentage, everything())



# Save output


df_lasso_saved <- df_merge_full_conf %>%
  cbind(df_lasso_variables)


write.dta(df_lasso_saved, paste0(global_path, "data/main_prediction_output.dta"))



# Percentage share of misclassification group in wider sample ----


df_predition_percentage_share <- df_merge_full_conf %>%
  summarise(
    tp = sum(tp_percentage),
    fp = sum(fp_percentage),
    tn = sum(tn_percentage),
    fn = sum(fn_percentage)
  ) %>%
  mutate(
    tp_pct = tp / (tp + fp + tn + fn),
    fp_pct = fp / (tp + fp + tn + fn),
    tn_pct = tn / (tp + fp + tn + fn),
    fn_pct = fn / (tp + fp + tn + fn)
  ) %>%
  dplyr::select(tp_pct, fp_pct, tn_pct, fn_pct) %>%
  mutate(description = "Shares of belief types")


# Percentage share when population weights are applied ----

df_merged_full_incl_pw <- df_merge_full_conf %>%
  dplyr::select(dna, pw_w4, dna, belief, tp_percentage, fp_percentage, tn_percentage, fn_percentage) %>%
  mutate(
    tp_pw = tp_percentage * pw_w4,
    fp_pw = fp_percentage * pw_w4,
    tn_pw = tn_percentage * pw_w4,
    fn_pw = fn_percentage * pw_w4
  )

pw_results <- df_merged_full_incl_pw %>%
  summarise(
    tp_sum = sum(tp_pw),
    fp_sum = sum(fp_pw),
    tn_sum = sum(tn_pw),
    fn_sum = sum(fn_pw)
  ) %>%
  mutate(
    tp_pct = tp_sum / (tp_sum + tn_sum + fp_sum + fn_sum),
    fp_pct = fp_sum / (tp_sum + tn_sum + fp_sum + fn_sum),
    tn_pct = tn_sum / (tp_sum + tn_sum + fp_sum + fn_sum),
    fn_pct = fn_sum / (tp_sum + tn_sum + fp_sum + fn_sum)
  ) %>%
  dplyr::select(tp_pct, fp_pct, tn_pct, fn_pct) %>%
  mutate(description = "Shares of belief types, population weighted")


# Percentage when hectrage per plot is applied ----

df_per_hectar_estimates <- df_merge_full_conf %>%
  dplyr::select(dna, pw_w4, dna, belief, tp_percentage, fp_percentage, tn_percentage, fn_percentage, s3q08) %>%
  mutate(size_in_hectar = s3q08 * 0.0001) %>%
  mutate(
    tp_pw_hectar = tp_percentage * pw_w4 * size_in_hectar,
    fp_pw_hectar = fp_percentage * pw_w4 * size_in_hectar,
    tn_pw_hectar = tn_percentage * pw_w4 * size_in_hectar,
    fn_pw_hectar = fn_percentage * pw_w4 * size_in_hectar
  )



pw_hectar_results <- df_per_hectar_estimates %>%
  summarise(
    tp_sum = sum(tp_pw_hectar),
    fp_sum = sum(fp_pw_hectar),
    tn_sum = sum(tn_pw_hectar),
    fn_sum = sum(fn_pw_hectar)
  ) %>%
  mutate(
    tp_pct = tp_sum / (tp_sum + fp_sum + tn_sum + fn_sum),
    fp_pct = fp_sum / (tp_sum + fp_sum + tn_sum + fn_sum),
    tn_pct = tn_sum / (tp_sum + fp_sum + tn_sum + fn_sum),
    fn_pct = fn_sum / (tp_sum + fp_sum + tn_sum + fn_sum)
  ) %>%
  dplyr::select(tp_pct, fp_pct, tn_pct, fn_pct) %>%
  mutate(description = "Shares of maize area , population weighted")



# Return dataframe summarizing percentages

percentage_output <- rbind(df_predition_percentage_share, pw_results, pw_hectar_results) %>%
  dplyr::select(description, tp_pct, fp_pct, tn_pct, fn_pct)



# Apply percentage shares to national-level hectarage estimates  ----

# Total Hectarage according to USDA: 2,415,000 Ha (https://ipad.fas.usda.gov/countrysummary/Default.aspx?id=ET&crop=Corn)


hectar_tp <- pw_hectar_results$tp_pct * 2415000

hectar_fp <- pw_hectar_results$fp_pct * 2415000

hectar_tn <- pw_hectar_results$tn_pct * 2415000

hectar_fn <- pw_hectar_results$fn_pct * 2415000


# Save outputs in dataframe
hectarage_output <- data.frame(
  TP_hectar = hectar_tp,
  FP_hectar = hectar_fp,
  TN_hectar = hectar_tn,
  FN_hectar = hectar_fn
)


# Multiply estimates with fertilizer to calculate fertilizer used per group ----


df_nitrogen_estimates <- df_merge_full_conf %>%
  dplyr::select(dna, pw_w4, dna, belief, tp_percentage, fp_percentage, tn_percentage, fn_percentage, s3q08, nitrogen_kg_pha) %>%
  mutate(
    N_tp = sum(nitrogen_kg_pha * belief * dna * pw_w4),
    N_fp = sum(nitrogen_kg_pha * belief * (1 - dna)* pw_w4),
    N_tn = sum(nitrogen_kg_pha * (1 - belief) * (1 - dna)* pw_w4),
    N_fn = sum(nitrogen_kg_pha * (1 - belief) * dna* pw_w4)
  ) %>%
  mutate(
    tp = sum(dna * belief* pw_w4),
    fp = sum((1 - dna) * belief* pw_w4),
    tn = sum((1 - dna) * (1 - belief)* pw_w4),
    fn = sum(dna * (1 - belief)* pw_w4)
  ) %>%
  mutate(
    mean_N_TP = N_tp / tp,
    mean_N_FP = N_fp / fp,
    mean_N_TN = N_tn / tn,
    mean_N_FN = N_fn / fn
  ) %>%
  dplyr::select(mean_N_TP, mean_N_FP, mean_N_TN, mean_N_FN) %>%
  distinct()



# Calculate national level nitrogen results

nitrogen_tp <- (hectar_tp * df_nitrogen_estimates$mean_N_TP) / 1000


nitrogen_fp <- (hectar_fp * df_nitrogen_estimates$mean_N_FP) / 1000


nitrogen_tn <- (hectar_tn * df_nitrogen_estimates$mean_N_TN) / 1000


nitrogen_fn <- (hectar_fn * df_nitrogen_estimates$mean_N_FN) / 1000


# Save outputs in dataframe

fertilizer_output_per_ha <- data.frame(
  TP_fertilizer_per_ha = df_nitrogen_estimates$mean_N_TP,
  FP_fertilizer_per_ha = df_nitrogen_estimates$mean_N_FP,
  TN_fertilizer_per_ha = df_nitrogen_estimates$mean_N_TN,
  FN_fertilizer_per_ha = df_nitrogen_estimates$mean_N_FN
)


fertilizer_output <- data.frame(
  TP_fertilizer = nitrogen_tp,
  FP_fertilizer = nitrogen_fp,
  TN_fertilizer = nitrogen_tn,
  FN_fertilizer = nitrogen_fn
)



#Calculate nitrogen use under counterfactual scenarios (corrected belief coefficients are derived from table_3_prediction.do)

nitrogen_fp_corrected_beliefs <- (hectar_fp * 59.32) / 1000

nitrogen_fn_corrected_beliefs <- (hectar_fn * 49.05) / 1000

fertilizer_output_corrected_belief <-  data.frame(
  FP_fertilizer_corrected = nitrogen_fp_corrected_beliefs,
  FN_fertilizer_corrected = nitrogen_fn_corrected_beliefs
)
