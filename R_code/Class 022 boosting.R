# Practical Machine Learning
# Lecture 022 boosting
# Code exercise
# Wage dataset in ISLR package
install.packages("ISLR")
library(ISLR)
data(Wage)
library(ggplot2)
library(caret)

names(Wage)
# output:  [1] "year"       "age"        "sex"        "maritl"     "race"       "education" 
# output:  [7] "region"     "jobclass"   "health"     "health_ins" "logwage"    "wage"  

# Create training and test sets
Wage <- subset(Wage, select=-c(logwage))
inTrain <- createDataPartition(y=Wage$wage, p=0.7, list=FALSE)
training <- Wage[inTrain,]
testing <- Wage[-inTrain,]

# Fit the model, method can be one of following boosting libearies
## gbm - boosting with tree
## mboost - model based boosting
## ada - statistical boosting based on additive logistic regression
## gamBoost - for boosting generalized additive models
modFit <- train(wage ~ ., method="gbm", data=training, verbose=FALSE)
print(modFit)
# output:  Stochastic Gradient Boosting 
# output:  
# output:  2102 samples
# output:    10 predictor
# output:  
# output:  No pre-processing
# output:  Resampling: Bootstrapped (25 reps) 
# output:  
# output:  Summary of sample sizes: 2102, 2102, 2102, 2102, 2102, 2102, ... 
# output:  
# output:  Resampling results across tuning parameters:
# output:  
# output:    interaction.depth  n.trees  RMSE      Rsquared   RMSE SD   Rsquared SD
# output:    1                   50      34.19731  0.3235866  1.661161  0.03049952 
# output:    1                  100      33.67663  0.3334855  1.602064  0.02756937 
# output:    1                  150      33.59185  0.3357642  1.564275  0.02534315 
# output:    2                   50      33.67847  0.3345248  1.644303  0.02886595 
# output:    2                  100      33.52068  0.3382478  1.565110  0.02461802 
# output:    2                  150      33.59747  0.3356035  1.515022  0.02243729 
# output:    3                   50      33.56505  0.3372840  1.616824  0.02756932 
# output:    3                  100      33.67426  0.3330513  1.570557  0.02456849 
# output:    3                  150      33.81397  0.3288325  1.518982  0.02237334 
# output:  
# output:  Tuning parameter 'shrinkage' was held constant at a value of 0.1
# output:  RMSE was used to select the optimal model using  the smallest value.
# output:  The final values used for the model were n.trees = 100, interaction.depth = 2
# output:  and shrinkage = 0.1. 

# Plot the results
qplot(predict(modFit, testing), wage, data=testing)