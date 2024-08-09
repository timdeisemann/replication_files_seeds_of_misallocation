############################################################################################################################################################################
# Appendix Prediction Panel A: Performance of candidate models
#############################################################################################################################################################################

# Note: need to set up lock file (see Table 3.R script) before running this script

# Note: when running the code to replicate the results in the paper, the script needs to be executed as a whole
# and not run line by line. Only this ensures that the seed is set accurately in order to replicate results

# Output dataframes for different models:

#XG Boost: xgboost_performance
#GLMNET: glmnet_performance
#Random Forest: randomForest_performance
#Bagged classification trees: predbag_performance

######################################################## Define packages and read in relevant data #################################################


#Running the SuperLearner package ----

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

df_seeds_data <- readRDS(paste0(global_path,"data/seeds_data_prediction_preprocessed.rds"))

categoricals_used_in_appendix <- c("s3q16","s5q02")


categorical <- c("saq01", "saq15", "s7q01", "s7q02", "s7q04", "s7q06", "s7q09", "s7q11_1", "s7q15", "s7q16", "s7q17", "s7q29", "s4q02", "s4q04", "s4q08", "s4q13a", "s4q13b", "s4q14", "s4q22", "s3q03b", "s3q04", "s3q12", "s3q14", "s3q17",
                 "s3q24", "s3q25", "s3q26", "s3q27", "s3q34", "s3q37", "s3q38", "s3q40", "s2q03", "s2q05", "s2q16", "s5q12", "s5q16", "s1q01", "s1q02", "s1q08", "s1q09", "s1q12", "s1q13", "s1q17", "s1q16", "s1q20", "s1q21", "s1q22", "s2q01", "s2q04", "s2q19",
                 "s4q01", "s4q33b", "s4q45", "s4q48", "s4q51", "s4q53", "s11b_ind_01", "cs2aq01", "cs2aq02", "cs2aq03", "cs2aq05", "cs2aq06", "cs2aq07", "cs2aq09", "cs2aq11", "cs3q01", "cs3q04a", "cs3q07", "cs3q08", "cs3q11a", "cs3q12a_1", "cs4q01", "cs4q03", "cs4q04__0", "cs4q04__1", "cs4q04__2", "cs4q04__3", "cs4q04__4",
                 "cs4q04__5", "cs4q04__6", "cs4q04__7", "cs4q04__8", "cs4q04__9", "cs4q04__10", "cs4q04__11", "cs4q04__12", "cs4q04__13", "cs4q05__0", "cs4q05__1", "cs4q05__2", "cs4q05__3", "cs4q05__4", "cs4q05__5", "cs4q05__6", "cs4q05__7", "cs4q05__8", "cs4q05__9", "cs4q05__10", "cs4q05__11", "cs4q05__12", "cs4q05__13", "cs4q11", "cs4q14", "cs4q19", "cs4q20", "cs4q22", "cs4q27",
                 "cs4q34", "cs4q38", "cs4q39", "cs4q41", "cs4q43", "cs4q47", "cs4q50", "cs4q52", "cs4q54", "cs4q56", "cs4q58", "cs5q01_1", "cs5q02", "cs5q06", "cs5q09", "cs6q01", "ssa_aez09", "sq1", "sq2", "sq3", "sq4", "sq5", "sq6", "sq7", "gender","s3q10")



######################################################## Split sample and set-up algorithms #################################################


#A: Set-up of the SuperLearner Algorithm ----

set.seed(1)

#Training Data:
df_training <- df_seeds_data %>%
  filter(!is.na(dna))  %>%#Excluding the variables where there is no DNA allows us to isolate the 
  dplyr::select(-c(categoricals_used_in_appendix,categorical)) #Exclude list of categoricals that have been split into dummies (as these categoricals are only used in table3_prediction.do)


# Create a dataframe to contain our explanatory variables.
data = subset(df_training, select = c(-dna))


# Stratified sample splitting according to dna 

train_obs <- createDataPartition(df_training$dna, p = 0.7, list = FALSE)[,1]

#70/30 split between training and testing - ensuring that DNA is evenly distributed 

outcome_bin <- df_training$dna

x_train = data[train_obs, ]

y_train <- outcome_bin[train_obs]

# Create a holdout set for evaluating model performance.
x_holdout = data[-train_obs, ]

y_holdout = outcome_bin[-train_obs]


#B: Set up hyperparameter tuning and configure screening algorithm ----


#Hyperparameter tuning for the XGBOOST variable ---- 


tune = list(ntrees = c(50, 100, 150),
            max_depth = c(3,6),
            shrinkage = c(0.01, 0.1))



learners = create.Learner("SL.xgboost", tune = tune, detailed_names = TRUE, name_prefix = "xgb")



#Generate a custom screening random forest for variable selection 
custom_rf <- function (Y, X, family, nVar = 200, ntree = 1000, mtry = ifelse(family$family == "gaussian", floor(sqrt(ncol(X))), max(floor(ncol(X)/3), 1)), nodesize = ifelse(family$family == "gaussian", 5, 1), maxnodes = NULL,...)
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


######################################################## Calculate performance for SuperLearner candidate models #################################################


######################################################## GLMNET #################################################


print("Performance glmnet")

##  "SL.glmnet" ----


s1_glmnet = SuperLearner(Y = y_train, X = x_train, family = binomial(),
                         cvControl = list(V = 6, stratifyCV = TRUE),
                         method = "method.AUC",
                         SL.library = list(c("SL.glmnet", "custom_rf")))



#Check model performance on holdout data 

s1_glmnet

pred_glmnet = predict(s1_glmnet, x_holdout, onlySL = TRUE)

#AUC calculation: 

pred_rocr_glmnet = ROCR::prediction(pred_glmnet$pred, y_holdout)
auc_glmnet = ROCR::performance(pred_rocr_glmnet, measure = "auc", x.measure = "cutoff")@y.values[[1]]


pred_binary <- round(pred_glmnet$pred, digits = 0) 

#Accuracy
accuracy_glmnet <- Metrics::accuracy(y_holdout, pred_binary)

#Precision 
precision_glmnet <- Metrics::precision(y_holdout, pred_binary)


#Recall
recall_glmnet <- Metrics::recall(y_holdout, pred_binary)

#F1
F1_glmnet <- (2*recall_glmnet*precision_glmnet)/(recall_glmnet+precision_glmnet)

#Balanced accuracy

y_holdout_factor <- as.factor(y_holdout)
pred_binary_factor <- as.factor(pred_binary)

balanced_accuracy_glmnet <- bal_accuracy_vec(y_holdout_factor, pred_binary_factor)



glmnet_performance <- data.frame(
  AUC = auc_glmnet,
  Accuracy = accuracy_glmnet,
  Balanced_Accuracy = balanced_accuracy_glmnet,
  Precision = precision_glmnet,
  Recall = recall_glmnet,
  F1 = F1_glmnet
)

rm(s1_glmnet)
gc()

######################################################## XGBOOST #################################################

print("Performance xgboost")


##  "SL.xgboost" ----

#Model uses an ensemble of 12 differently tuned xg boost algorithms

s1_xgboost = SuperLearner(Y = y_train, X = x_train, family = binomial(),
                          method = "method.AUC",
                          cvControl = list(V = 6, stratifyCV = TRUE),
                          SL.library = list(c(learners$names[1],"custom_rf"),
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
                                            c(learners$names[12],"custom_rf")))

#Check model performance on holdout data 

s1_xgboost

pred_xgboost = predict(s1_xgboost, x_holdout, onlySL = TRUE)

#AUC calculation: 

pred_rocr_xgboost = ROCR::prediction(pred_xgboost$pred, y_holdout)
auc_xgboost = ROCR::performance(pred_rocr_xgboost, measure = "auc", x.measure = "cutoff")@y.values[[1]]


pred_binary <- round(pred_xgboost$pred, digits = 0) 

#Accuracy
accuracy_xgboost <- Metrics::accuracy(y_holdout, pred_binary)

#Precision 
precision_xgboost <-Metrics::precision(y_holdout, pred_binary)

#Recall
recall_xgboost <- Metrics::recall(y_holdout, pred_binary)

#F1
F1_xgboost <- (2*recall_xgboost*precision_xgboost)/(recall_xgboost+precision_xgboost)

#Balanced accuracy

y_holdout_factor <- as.factor(y_holdout)
pred_binary_factor <- as.factor(pred_binary)

balanced_accuracy_xgboost <- bal_accuracy_vec(y_holdout_factor, pred_binary_factor)


xgboost_performance <- data.frame(
  AUC = auc_xgboost,
  Accuracy = accuracy_xgboost,
  Balanced_Accuracy = balanced_accuracy_xgboost,
  Precision = precision_xgboost,
  Recall = recall_xgboost,
  F1 = F1_xgboost
)

rm(s1_xgboost)
gc()

######################################################## Performance random Forest #################################################


print("Performance randomForest")


s1_rf  = SuperLearner(Y = y_train, X = x_train, family = binomial(),
                                  method = "method.AUC",
                                  cvControl = list(V = 6, stratifyCV = TRUE),
                                  SL.library = list(c("SL.randomForest","custom_rf")))

#Check model performance on holdout data 

s1_rf

pred_rf = predict(s1_rf, x_holdout, onlySL = TRUE)

#AUC calculation: 

pred_rocr_rf = ROCR::prediction(pred_rf$pred, y_holdout)
auc_rf = ROCR::performance(pred_rocr_rf, measure = "auc", x.measure = "cutoff")@y.values[[1]]
auc_rf


pred_rf_rounded <- round(pred_rf$pred, digits = 0) 

#Accuracy
accuracy_rf <- Metrics::accuracy(y_holdout, pred_rf_rounded)


#Precision 
precision_rf <- Metrics::precision(y_holdout, pred_rf_rounded)


#Recall
recall_rf <- Metrics::recall(y_holdout, pred_rf_rounded)


#F1
F1_rf <- (2*recall_rf*precision_rf)/(recall_rf+precision_rf)


#Balanced accuracy

y_holdout_factor <- as.factor(y_holdout)
pred_binary_factor <- as.factor(pred_rf_rounded)

balanced_accuracy_rf <- bal_accuracy_vec(y_holdout_factor, pred_binary_factor)


randomForest_performance <- data.frame(
  AUC = auc_rf,
  Accuracy = accuracy_rf,
  Balanced_Accuracy = balanced_accuracy_rf,
  Precision = precision_rf,
  Recall = recall_rf,
  F1 = F1_rf
)

rm(s1_rf)
gc()


######################################################## Performance ipredbagg #################################################


print("Performance ipredbagg")


s1_predbag  = SuperLearner(Y = y_train, X = x_train, family = binomial(),
                      method = "method.AUC",
                      cvControl = list(V = 6, stratifyCV = TRUE),
                      SL.library = list(c("SL.ipredbagg","custom_rf")))

#Check model performance on holdout data 

s1_predbag

pred_ipred = predict(s1_predbag, x_holdout, onlySL = TRUE)

#AUC calculation: 

pred_rocr_ipred = ROCR::prediction(pred_ipred$pred, y_holdout)
auc_ipred = ROCR::performance(pred_rocr_ipred, measure = "auc", x.measure = "cutoff")@y.values[[1]]
auc_ipred


pred_ipred_rounded <- round(pred_ipred$pred, digits = 0) 

#Accuracy
accuracy_predbag <- Metrics::accuracy(y_holdout, pred_ipred_rounded)


#Precision 
precision_predbag <- Metrics::precision(y_holdout, pred_ipred_rounded)


#Recall
recall_predbag <- Metrics::recall(y_holdout, pred_ipred_rounded)

#F1
F1_predbag <- (2*recall_predbag*precision_predbag)/(recall_predbag+precision_predbag)


#Balanced accuracy

y_holdout_factor <- as.factor(y_holdout)
pred_binary_factor <- as.factor(pred_ipred_rounded)

balanced_accuracy_predbag <- bal_accuracy_vec(y_holdout_factor, pred_binary_factor)


predbag_performance <- data.frame(
  AUC = auc_ipred,
  Accuracy = accuracy_predbag,
  Balanced_Accuracy = balanced_accuracy_predbag,
  Precision = precision_predbag,
  Recall = recall_predbag,
  F1 = F1_predbag
)

rm(s1_predbag)
gc()

