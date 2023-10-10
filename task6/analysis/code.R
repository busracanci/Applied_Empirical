# PACKAGES

library(mltools)
library(data.table)
library(dplyr)       # Data manipulation (0.8.0.1)
library(fBasics)     # Summary statistics (3042.89)
library(corrplot)    # Correlations (0.84)
library(psych)       # Correlation p-values (1.8.12)
library(grf)         # Generalized random forests (0.10.2)
library(rpart)       # Classification and regression trees, or CART (4.1-13)
library(rpart.plot)  # Plotting trees (3.0.6)
library(treeClust)   # Predicting leaf position for causal trees (1.1-7)
library(car)         # linear hypothesis testing for causal tree (3.0-2)
library(remotes)    # Install packages from github (2.0.1)
library(readr)       # Reading csv files (1.3.1)
library(tidyr)       # Database operations (0.8.3)
library(tibble)      # Modern alternative to data frames (2.1.1)
library(knitr)       # RMarkdown (1.21)
library(kableExtra)  # Prettier RMarkdown (1.0.1)
library(ggplot2)     # general plotting tool (3.1.0)
library(haven)       # read stata files (2.0.0)
library(aod)         # hypothesis testing (1.3.1)
library(evtree)      # evolutionary learning of globally optimal trees (1.0-7)
library(estimatr)    # simple interface for OLS estimation w/ robust std errors ()

remotes::install_github('susanathey/causalTree') # Uncomment this to install the causalTree package
library(causalTree)
remotes::install_github('grf-labs/sufrep') # Uncomment this to install the sufrep package
library(sufrep)

setwd("C:/Users/buca4591/Desktop/GIT/Applied_Empirical/task6")

load("raw/politician_gender_prefs.rdata")

set.seed(101023)

# Ex1

ols <- lm(picked_cand_a ~ cand_a_female, df)
summary(ols)

# Ex2
df$y <- as.numeric(df$picked_cand_a)
df$w <- as.numeric(df$cand_a_female)
df<- one_hot(data.table(df))

train_fraction <- 0.75  # Use train_fraction % of the dataset to train our models
n <- dim(df)[1]
train_idx <- sample.int(n, replace=F, size=floor(n*train_fraction))
df_train <- df[train_idx,]
df_test <- df[-train_idx,]

covariates_train <- select(df_train,-cand_a_female, -picked_cand_a)

cf<- causal_forest( 
  Y = df_train$y,  
  X = covariates_train,  
  W = df_train$w,  
  num.trees = 5000
)

covariates_test <- select(df_test,-cand_a_female, -picked_cand_a)
test_pred<- predict(cf, newdata=as.matrix(covariates_test), estimate.variance=TRUE)
covariates_test$preds<- test_pred$predictions

# Ex3
ggplot(data = covariates_test, aes(x = preds)) +
  geom_histogram(fill = "deepskyblue3", color = "deepskyblue4", alpha = 0.7) +
  labs(title = "Predicted treatment effects", x = "Treatment effects", y = "Frequency")
ggsave("output/ex3.pdf")

# Ex4
covariate_names <- names(df)[-c(1,2)]
var_imp <- c(variable_importance(cf))
names(var_imp) <- covariate_names
sorted_var_imp <- data.frame(sort(var_imp, decreasing=TRUE))

predict_means <- covariates_test %>%  
  group_by(age) %>%  
  summarize(mean_predicted_te = mean(preds))  

ggplot(data = predict_means, aes(x = age, y = mean_predicted_te)) +
  geom_bar(stat = "identity", fill = "deepskyblue3", color = "deepskyblue4", alpha = 0.7) +  
  labs(title = "Mean Predicted Treatment Effects by Age", x = "Age", y = "Mean Predicted Treatment Effects")
ggsave("output/ex4-1.pdf")

predict_means <- covariates_test %>%  
  group_by(sdo) %>%  
  summarize(mean_predicted_te = mean(preds))  

ggplot(data = predict_means, aes(x = sdo, y = mean_predicted_te)) +
  geom_bar(stat = "identity", fill = "deepskyblue3", color = "deepskyblue4", alpha = 0.7) +  
  labs(title = "Mean Predicted Treatment Effects by sdo", x = "sdo", y = "Mean Predicted Treatment Effects")
ggsave("output/ex4-2.pdf")