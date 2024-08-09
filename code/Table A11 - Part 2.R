#############################################################################################################################################################################
# Appendix Prediction Panel B: Performance of ensemble models for alternative outcomes 
#############################################################################################################################################################################

# Note: before running this script, set_up_R_environment.R needs to be run

# Note: when running the code to replicate the results in the paper, the script needs to be executed as a whole
# and not run line by line. Only this ensures that the seed is set accurately in order to replicate results

#Outputs: 

#Prediction Performance for extension participation variable 

#Performance on holdout DNA subsample: extension_holdout_performance
#Performane on wider sample (non-DNA): extension_non_DNA_data_performance

#Prediction performane for seed source variable 

#Performance on holdout DNA subsample: seed_source_holdout_performance
#Performance on wider sample (non-DNA): seed_source_non_DNA_data_performance


######################################################## Define packages and read in relevant data #################################################

#Install relevant packages ----

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


#Read in pre-processed dataframe (for pre-processing see Table 3 script) 


global_path <- ""

df_seeds_data_input <- readRDS(paste0(global_path,"data/seeds_data_prediction_preprocessed.rds"))


categorical <- c("saq01", "saq15", "s7q01", "s7q02", "s7q04", "s7q06", "s7q09", "s7q11_1", "s7q15", "s7q16", "s7q17", "s7q29", "s4q02", "s4q04", "s4q08", "s4q13a", "s4q13b", "s4q14", "s4q22", "s3q03b", "s3q04", "s3q12", "s3q14", "s3q17",
                 "s3q24", "s3q25", "s3q26", "s3q27", "s3q34", "s3q37", "s3q38", "s3q40", "s2q03", "s2q05", "s2q16", "s5q12", "s5q16", "s1q01", "s1q02", "s1q08", "s1q09", "s1q12", "s1q13", "s1q17", "s1q16", "s1q20", "s1q21", "s1q22", "s2q01", "s2q04", "s2q19",
                 "s4q01", "s4q33b", "s4q45", "s4q48", "s4q51", "s4q53", "s11b_ind_01", "cs2aq01", "cs2aq02", "cs2aq03", "cs2aq05", "cs2aq06", "cs2aq07", "cs2aq09", "cs2aq11", "cs3q01", "cs3q04a", "cs3q07", "cs3q08", "cs3q11a", "cs3q12a_1", "cs4q01", "cs4q03", "cs4q04__0", "cs4q04__1", "cs4q04__2", "cs4q04__3", "cs4q04__4",
                 "cs4q04__5", "cs4q04__6", "cs4q04__7", "cs4q04__8", "cs4q04__9", "cs4q04__10", "cs4q04__11", "cs4q04__12", "cs4q04__13", "cs4q05__0", "cs4q05__1", "cs4q05__2", "cs4q05__3", "cs4q05__4", "cs4q05__5", "cs4q05__6", "cs4q05__7", "cs4q05__8", "cs4q05__9", "cs4q05__10", "cs4q05__11", "cs4q05__12", "cs4q05__13", "cs4q11", "cs4q14", "cs4q19", "cs4q20", "cs4q22", "cs4q27",
                 "cs4q34", "cs4q38", "cs4q39", "cs4q41", "cs4q43", "cs4q47", "cs4q50", "cs4q52", "cs4q54", "cs4q56", "cs4q58", "cs5q01_1", "cs5q02", "cs5q06", "cs5q09", "cs6q01", "ssa_aez09", "sq1", "sq2", "sq3", "sq4", "sq5", "sq6", "sq7", "gender","s3q10")



# ######################################################## 1) Predict extension program participation with SuperLearner Model #################################################

set.seed(1)

#A: Set-up of the SuperLearner Algorithm ----

#Transform label data for extension program participation into numerical

df_seeds_data_input_extension <- df_seeds_data_input %>%
  dplyr::select(-c(categorical)) %>%
  mutate(s3q16 = as.numeric(s3q16)) %>% #1 corresponds to Yes, 2 corresponds to No
  mutate(s3q16 = ifelse(s3q16 == "1", 1, ifelse(s3q16 == "2", 0, NA))) %>%
  dplyr::select(-c(s3q16_2))


#Training Data:
df_training_extension <- df_seeds_data_input_extension %>%
  filter(!is.na(dna)) %>%
  dplyr::select(-s5q02) 


# Create a dataframe to contain our explanatory variables.
data_extension = subset(df_training_extension, select = c(-s3q16, -dna))

#Isolate training and validation dataset
train_obs_extension <- createDataPartition(df_training_extension$s3q16, p = 0.7, list = FALSE)[,1]

x_train_extension = data_extension[train_obs_extension, ]

# Create a holdout set for evaluating model performance.
x_holdout_extension = data_extension[-train_obs_extension,]

outcome_extension <- df_training_extension$s3q16

y_train_extension = outcome_extension[train_obs_extension]

y_holdout_extension = outcome_extension[-train_obs_extension]



#Hyperparameter tuning for the XGBOOST variable ----


tune = list(ntrees = c(50, 100, 150),
            max_depth = c(3,6),
            shrinkage = c(0.01, 0.1))


learners = create.Learner("SL.xgboost", tune = tune, detailed_names = TRUE, name_prefix = "xgb")


#Running the SuperLearner package ----

#Define a custom random forest alorithm to use as screening algorithm

custom_rf <- function (Y, X, family, nVar = 150, ntree = 1000, mtry = ifelse(family$family == "gaussian", floor(sqrt(ncol(X))), max(floor(ncol(X)/3), 1)), nodesize = ifelse(family$family == "gaussian", 5, 1), maxnodes = NULL,...)
{
  if (family$family == "gaussian") {
    rank.rf.fit <- randomForest::randomForest(Y ~ ., data = X, ntree = ntree, mtry = mtry, nodesize = nodesize, keep.forest = FALSE, maxnodes = maxnodes)
  }
  if (family$family == "binomial") {
    rank.rf.fit <- randomForest::randomForest(as.factor(Y) ~ ., data=X, ntree = ntree, mtry = mtry, nodesize = nodesize, keep.forest = FALSE, maxnodes = maxnodes)
  }
  whichVariable <- (rank(-rank.rf.fit$importance) <= nVar)
  return(whichVariable)
}
#Note: In order to ensure convergence of the algorithm, the number of variables selected by the screener algorithm is limited to 150 (as opposed to 200 in the main section)


#Random Forest

#B: Train SuperLearner Algorithm ----

s1 = SuperLearner(Y = y_train_extension, X = x_train_extension, family = binomial(),
                  cvControl = list(V = 6, stratifyCV = TRUE),
                  method = "method.AUC",
                  SL.library = list(c("SL.ipredbagg","custom_rf"),
                                    c("SL.randomForest","custom_rf"),
                                    c(learners$names[2],"custom_rf"),
                                    c(learners$names[3],"custom_rf"),
                                    c(learners$names[4],"custom_rf"),
                                    c(learners$names[5],"custom_rf"),
                                    c(learners$names[6],"custom_rf"),
                                    c(learners$names[7],"custom_rf"),
                                    c(learners$names[8],"custom_rf"),
                                    c(learners$names[9],"custom_rf"),
                                    c(learners$names[10],"custom_rf"),
                                    c(learners$names[11],"custom_rf"),
                                    c(learners$names[12],"custom_rf"),
                                    c("SL.glmnet", "custom_rf")))



#C: Evaluate the performance of the algorithm on the holdout data  ----


pred = predict(s1, x_holdout_extension, onlySL = TRUE)

pred_rocr = ROCR::prediction(pred$pred, y_holdout_extension)
auc_holdout_extension = ROCR::performance(pred_rocr, measure = "auc", x.measure = "cutoff")@y.values[[1]]


#Round variables to calculate accuracy, precision and recall
pred_binary <- round(pred$pred, digits = 0)


#Accuracy
accuracy_holdout_extension <- Metrics::accuracy(y_holdout_extension, pred_binary)


#Precision
precision_holdout_extension <- Metrics::precision(y_holdout_extension, pred_binary)


#Recall
recall_holdout_extension <- Metrics::recall(y_holdout_extension, pred_binary)

#F1
F1_holdout_extension <- (2*recall_holdout_extension*precision_holdout_extension)/(recall_holdout_extension+precision_holdout_extension)


#Balanced accuracy

y_holdout_factor <- as.factor(y_holdout_extension)
pred_binary_factor <- as.factor(pred_binary)

balanced_accuracy_holdout_extension <- bal_accuracy_vec(y_holdout_factor, pred_binary_factor)


extension_holdout_performance <- data.frame(
  AUC = auc_holdout_extension,
  Accuracy = accuracy_holdout_extension,
  Balanced_Accuracy = balanced_accuracy_holdout_extension,
  Precision = precision_holdout_extension,
  Recall = recall_holdout_extension,
  F1 = F1_holdout_extension
)




#D: Evaluate the performance of the algorithm on the testing data   ----


#Isolate non-DNA sample to apply prediction algorithm to
df_non_DNA_extension <- df_seeds_data_input_extension %>%
  filter(is.na(dna)) %>%
  dplyr::select(-c(dna, s3q16,s5q02))


#Isolate non-DNA sample with extension program participation to evaluate performance
df_non_DNA_extension_testing <- df_seeds_data_input_extension %>%
  filter(is.na(dna)) %>%
  dplyr::select(-c(dna))


#Predict extension program participation on non-DNA data


predicted_extension_testing_sample = predict(s1, df_non_DNA_extension, onlySL = TRUE)



df_predicted_extension_full <- as.data.frame(predicted_extension_testing_sample[["pred"]]) %>%
  rename(extension_participation_predicted = V1) %>%
  mutate(extension_participation_binary_predicted = round(extension_participation_predicted, digits = 0))

#Rounding adjusted here from conditional if/else to simple rounding 

#Compare the outputs of the prediction exercise in the wider sample with the observed variables

#Merge the predicted extension program participation with the wider dataset

df_comparison_extension <- df_predicted_extension_full %>%
  bind_cols(df_non_DNA_extension_testing)

#Compare predicted seed source with the observed outcome of the seed source variable----

#Accuracy
accuracy_non_DNA_extension <- Metrics::accuracy(df_comparison_extension$s3q16, df_comparison_extension$extension_participation_binary_predicted)


#Precision
precision_non_DNA_extension<- Metrics::precision(df_comparison_extension$s3q16, df_comparison_extension$extension_participation_binary_predicted)

#Recall
recall_non_DNA_extension <- Metrics::recall(df_comparison_extension$s3q16, df_comparison_extension$extension_participation_binary_predicted)

#AUC:

pred_rocr_extension_testing = ROCR::prediction(predicted_extension_testing_sample$pred, as.numeric(df_comparison_extension$s3q16))
auc_non_DNA_extension = ROCR::performance(pred_rocr_extension_testing, measure = "auc", x.measure = "cutoff")@y.values[[1]]


#F1
F1_non_DNA_extension <- (2*recall_non_DNA_extension*precision_non_DNA_extension)/(recall_non_DNA_extension+precision_non_DNA_extension)

#Balanced accuracy

y_holdout_factor <- as.factor(df_comparison_extension$s3q16)
pred_binary_factor <- as.factor(df_comparison_extension$extension_participation_binary_predicted)

balanced_accuracy_non_DNA_extension <- bal_accuracy_vec(y_holdout_factor, pred_binary_factor)


extension_non_DNA_data_performance <- data.frame(
  AUC = auc_non_DNA_extension,
  Accuracy = accuracy_non_DNA_extension,
  Balanced_Accuracy = balanced_accuracy_non_DNA_extension,
  Precision = precision_non_DNA_extension,
  Recall = recall_non_DNA_extension,
  F1 = F1_non_DNA_extension
)



######################################################## 2) Predict seed source with SuperLearner Model #################################################


#A: Set-up of the SuperLearner Algorithm ----

#Transform label data for seed source into numerical

df_seeds_data_input_seed_source <- df_seeds_data_input %>%
  dplyr::select(-c(categorical)) %>%
  mutate(s5q02 = as.numeric(s5q02)) %>% 
  dplyr::select(-c(s5q02_1))


#Training Data:
df_training_seed_source <- df_seeds_data_input_seed_source %>%
  filter(!is.na(dna)) %>%
  dplyr::select(-c(s3q16))



# Extract our outcome variable from the dataframe.
outcome_seed_source = df_training_seed_source$s5q02


# Create a dataframe to contain our explanatory variables.
data_seed_source = subset(df_training_seed_source, select = c(-s5q02, -dna))

#Isolate training and validation dataset
train_obs_seed_source <- createDataPartition(df_training_seed_source$s5q02, p = 0.7, list = FALSE)[,1]

x_train_seed_source = data_seed_source[train_obs_seed_source, ]
y_train_seed_source = outcome_seed_source[train_obs_seed_source]

# Create a holdout set for evaluating model performance.
x_holdout_seed_source = data_seed_source[-train_obs_seed_source,]

y_holdout_seed_source = outcome_seed_source[-train_obs_seed_source]


#Hyperparameter tuning for the XGBOOST variable ----


tune = list(ntrees = c(50, 100, 150),
            max_depth = c(3,6),
            shrinkage = c(0.01, 0.1))


learners = create.Learner("SL.xgboost", tune = tune, detailed_names = TRUE, name_prefix = "xgb")


#Running the SuperLearner package ----

#Train SuperLearner Algorithm ----

s1_seed_source = SuperLearner(Y = y_train_seed_source, X = x_train_seed_source, family = binomial(),
                  cvControl = list(V = 6, stratifyCV = TRUE),
                  method = "method.AUC",
                  SL.library = list(c("SL.ipredbagg","custom_rf"),
                                    c("SL.randomForest","custom_rf"),
                                    c(learners$names[2],"custom_rf"),
                                    c(learners$names[3],"custom_rf"),
                                    c(learners$names[4],"custom_rf"),
                                    c(learners$names[5],"custom_rf"),
                                    c(learners$names[6],"custom_rf"),
                                    c(learners$names[7],"custom_rf"),
                                    c(learners$names[8],"custom_rf"),
                                    c(learners$names[9],"custom_rf"),
                                    c(learners$names[10],"custom_rf"),
                                    c(learners$names[11],"custom_rf"),
                                    c(learners$names[12],"custom_rf"),
                                    c("SL.glmnet", "custom_rf")))



#C: Evaluate the performance of the algorithm on the holdout data  ----


pred_seed_source = predict(s1_seed_source, x_holdout_seed_source, onlySL = TRUE)


pred_rocr = ROCR::prediction(pred_seed_source$pred, y_holdout_seed_source)
auc_holdout_seed_source = ROCR::performance(pred_rocr, measure = "auc", x.measure = "cutoff")@y.values[[1]]
auc_holdout_seed_source

#Round variables to calculate accuracy, precision and recall
pred_binary_seed_source <- round(pred_seed_source$pred, digits = 0)


#Accuracy
accuracy_holdout_seed_source <- Metrics::accuracy(y_holdout_seed_source, pred_binary_seed_source)


#Precision
precision_holdout_seed_source <- Metrics::precision(y_holdout_seed_source, pred_binary_seed_source)


#Recall
recall_holdout_seed_source <- Metrics::recall(y_holdout_seed_source, pred_binary_seed_source)

#F1
F1_holdout_seed_source <- (2*recall_holdout_seed_source*precision_holdout_seed_source)/(recall_holdout_seed_source+precision_holdout_seed_source)

#Balanced accuracy

y_holdout_factor <- as.factor(y_holdout_seed_source)
pred_binary_factor <- as.factor(pred_binary_seed_source)

balanced_accuracy_seeds_source <- bal_accuracy_vec(y_holdout_factor, pred_binary_factor)


seed_source_holdout_performance <- data.frame(
  AUC = auc_holdout_seed_source,
  Accuracy = accuracy_holdout_seed_source,
  Balanced_Accuracy = balanced_accuracy_seeds_source,
  Precision = precision_holdout_seed_source,
  Recall = recall_holdout_seed_source,
  F1 = F1_holdout_seed_source
)


#D: Evaluate the performance of the algorithm on the testing data   ----


#Check what happens when we replace the above with the below -- outcome should be the same
df_non_DNA_seed_source <- df_seeds_data_input_seed_source %>%
  filter(is.na(dna)) %>%
  dplyr::select(-c(dna, s5q02, s3q16))



#Isolate non-DNA sample with extension program participation to evaluate performance
df_non_DNA_seed_source_test <- df_seeds_data_input_seed_source %>%
  filter(is.na(dna)) %>%
  dplyr::select(-c(dna))


#Predict seed source on non-DNA data

predicted_seed_source_testing_sample = predict(s1_seed_source, df_non_DNA_seed_source, onlySL = TRUE)


df_predicted_seed_source_full <- as.data.frame(predicted_seed_source_testing_sample[["pred"]]) %>%
  rename(seed_source_predicted = V1) %>%
  mutate(seed_source_binary_predicted = round(seed_source_predicted, digits = 0))



#Compare the outputs of the prediction exercise in the wider sample with the observed variables

#Merge the predicted seed sources with the wider dataset

df_comparison_seed_source <- df_predicted_seed_source_full %>%
  bind_cols(df_non_DNA_seed_source_test)

#Compare predicted seed source with the observed outcome of the seed source variable----

#Accuracy
accuracy_non_DNA_seed_source <- Metrics::accuracy(df_comparison_seed_source$s5q02, df_comparison_seed_source$seed_source_binary_predicted)


#Precision
precision_non_DNA_seed_source <- Metrics::precision(df_comparison_seed_source$s5q02, df_comparison_seed_source$seed_source_binary_predicted)

#Recall
recall_non_DNA_seed_source <- Metrics::recall(df_comparison_seed_source$s5q02, df_comparison_seed_source$seed_source_binary_predicted)


#AUC:
pred_rocr_seed_source_testing = ROCR::prediction(predicted_seed_source_testing_sample$pred, as.numeric(df_comparison_seed_source$s5q02))
auc_non_DNA_seed_source = ROCR::performance(pred_rocr_seed_source_testing, measure = "auc", x.measure = "cutoff")@y.values[[1]]
auc_non_DNA_seed_source

#F1
F1_non_DNA_seed_source <- (2*recall_non_DNA_seed_source*precision_non_DNA_seed_source)/(recall_non_DNA_seed_source+precision_non_DNA_seed_source)


#Balanced accuracy

y_holdout_factor <- as.factor(df_comparison_seed_source$s5q02)
pred_binary_factor <- as.factor(df_comparison_seed_source$seed_source_binary_predicted)

balanced_accuracy_non_DNA_seed_source <- bal_accuracy_vec(y_holdout_factor, pred_binary_factor)


seed_source_non_DNA_data_performance <- data.frame(
  AUC = auc_non_DNA_seed_source,
  Accuracy = accuracy_non_DNA_seed_source,
  Balanced_Accuracy = balanced_accuracy_non_DNA_seed_source,
  Precision = precision_non_DNA_seed_source,
  Recall = recall_non_DNA_seed_source,
  F1 = F1_non_DNA_seed_source
)


