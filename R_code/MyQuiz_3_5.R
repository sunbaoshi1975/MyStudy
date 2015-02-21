# Practical Machine Learning
# Quiz 3, question 5
# Code exercise
# Nodes: should add 'importance = TRUE' to the train() call
rm(list = ls())
library(caret)

# Load the vowel.train and vowel.test data sets
library(ElemStatLearn)
data(vowel.train)
data(vowel.test) 
names(vowel.train)
# output:   [1] "y"    "x.1"  "x.2"  "x.3"  "x.4"  "x.5"  "x.6"  "x.7"  "x.8" 
# output:   [10] "x.9"  "x.10"  

# Set the variable y to be a factor variable in both the training and test set. 
## Then set the seed to 33833.
## Fit a random forest predictor relating the factor variable y to the remaining variables.
set.seed(33833)
training <- vowel.train;
testing <- vowel.test;

modFit <- train(y ~ ., data=training, method="rf", prox=TRUE, importance = TRUE)
modFit
# output: Random Forest 
# output: 
# output: 528 samples
# output:  10 predictor
# output: 
# output: No pre-processing
# output: Resampling: Bootstrapped (25 reps) 
# output: 
# output: Summary of sample sizes: 528, 528, 528, 528, 528, 528, ... 
# output: 
# output: Resampling results across tuning parameters:
# output: 
# output:   mtry  RMSE      Rsquared   RMSE SD     Rsquared SD
# output:    2    1.039535  0.9114579  0.09436101  0.01903443 
# output:    6    1.029894  0.8985534  0.09821758  0.02036953 
# output:   10    1.121758  0.8741386  0.14049572  0.03159903 
# output: 
# output: RMSE was used to select the optimal model using  the smallest value.
# output: The final value used for the model was mtry = 6. 

# Read about variable importance in random forests here:
## http://www.stat.berkeley.edu/~breiman/RandomForests/cc_home.htm#ooberr
## about out-of-bag (oob) error estimate, Variable importance and Gini importance
## The caret package uses by defualt the Gini importance.
## Calculate the variable importance using the varImp function in the caret package.
## What is the order of variable importance?

# Option 1: use caret package
vi = varImp(modFit$finalModel)
order(vi,decreasing = T)
# output: [1]  1  2  6  8  5  3  9  4 10  7

vi = data.frame(var = 1:nrow(vi), imp = vi$Overall)
vi[order(vi$imp, decreasing = T),]
# output:    var      imp
# output: 1    1 75.90682
# output: 2    2 69.49329
# output: 6    6 42.81709
# output: 8    8 36.30805
# output: 5    5 29.77909
# output: 3    3 24.37574
# output: 9    9 22.10569
# output: 4    4 20.01878
# output: 10  10 18.91583
# output: 7    7 16.28122

# Option 2: use randomForest package
library(randomForest)
set.seed(33833)
modFit <- randomForest(y~., data=training, importance=TRUE)
vi <- varImp(modFit)
order(vi,decreasing = T)
# output: [1]  2  1  6  8  5  3  9 10  4  7

vi = data.frame(var = 1:nrow(vi), imp = vi$Overall)
vi[order(vi$imp, decreasing = T),]

# output:    var      imp
# output: 2    2 54.91284
# output: 1    1 50.05999
# output: 6    6 33.57375
# output: 8    8 28.21670
# output: 5    5 27.75572
# output: 3    3 24.88672
# output: 9    9 21.29792
# output: 10  10 20.27256
# output: 4    4 20.12771
# output: 7    7 19.49037

# notes: grade answer is x.2, x.1, x.5, x.6, x.8, x.4, x.9, x.3, x.7,x.10, not match either my calculation