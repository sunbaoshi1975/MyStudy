# Practical Machine Learning
# Quiz 4, question 1
# Code exercise
library(ElemStatLearn)
library(caret)
data(vowel.train)
data(vowel.test) 

rm(list = ls())

# Set the variable y to be a factor variable in both the training and test set.
vowel.train$y = factor(vowel.train$y)
vowel.test$y = factor(vowel.test$y)
dim(vowel.train)

# Then set the seed to 33833. 
set.seed(33833)

# Fit (1) a random forest predictor relating the factor variable y to the remaining variables
mod1 <- train(y ~., method="rf", data=vowel.train)

# Fit (2) a boosted predictor using the "gbm" method
mod2 <- train(y ~., method="gbm", data=vowel.train)
mod1; mod2

# output: Random Forest 
# output: 
# output: 528 samples
# output:  10 predictor
# output:  11 classes: '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11' 
# output: 
# output: No pre-processing
# output: Resampling: Bootstrapped (25 reps) 
# output: 
# output: Summary of sample sizes: 528, 528, 528, 528, 528, 528, ... 
# output: 
# output: Resampling results across tuning parameters:
# output: 
# output:   mtry  Accuracy   Kappa      Accuracy SD  Kappa SD  
# output:    2    0.9341862  0.9274159  0.01971666   0.02171790
# output:    6    0.9089027  0.8995434  0.02083897   0.02296907
# output:   10    0.8777698  0.8652411  0.02601655   0.02867501
# output: 
# output: Accuracy was used to select the optimal model using  the largest value.
# output: The final value used for the model was mtry = 2. 

# output: Stochastic Gradient Boosting 
# output: 
# output: 528 samples
# output:  10 predictor
# output:  11 classes: '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11' 
# output: 
# output: No pre-processing
# output: Resampling: Bootstrapped (25 reps) 
# output: 
# output: Summary of sample sizes: 528, 528, 528, 528, 528, 528, ... 
# output: 
# output: Resampling results across tuning parameters:
# output: 
# output:   interaction.depth  n.trees  Accuracy   Kappa      Accuracy SD  Kappa SD  
# output:   1                   50      0.6882069  0.6568812  0.03932782   0.04316009
# output:   1                  100      0.7528032  0.7277478  0.03554453   0.03918298
# output:   1                  150      0.7884002  0.7668854  0.03289100   0.03625402
# output:   2                   50      0.7978801  0.7773700  0.03085819   0.03398221
# output:   2                  100      0.8424753  0.8264114  0.03279007   0.03607873
# output:   2                  150      0.8577171  0.8431620  0.03224849   0.03549186
# output:   3                   50      0.8297705  0.8124297  0.03220348   0.03545406
# output:   3                  100      0.8583106  0.8438618  0.02539759   0.02795812
# output:   3                  150      0.8685738  0.8551426  0.02492084   0.02743122
# output: 
# output: Tuning parameter 'shrinkage' was held constant at a value of 0.1
# output: Accuracy was used to select the optimal model using  the largest value.
# output: The final values used for the model were n.trees = 150, interaction.depth = 3
# output:  and shrinkage = 0.1. 
 
# Predict
pred1 <- predict(mod1, vowel.test); pred2 <- predict(mod2, vowel.test)

# Get the accuracies for the two approaches
confusionMatrix(pred1, vowel.test$y)		# Accuracy : 0.6061
confusionMatrix(pred2, vowel.test$y)		# Accuracy : 0.5303
confusionMatrix(pred1, pred2)				# Accuracy : 0.6602 

# Manual calculation
sum((pred1 == vowel.test$y)) / length(vowel.test$y)		# [1] 0.6060606
sum((pred2 == vowel.test$y)) / length(vowel.test$y)		# [1] 0.530303
sum((pred1 == pred2)) / length(vowel.test$y)			# [1] 0.6601732
sum((pred1 == pred2) & (pred2 == vowel.test$y)) / length(vowel.test$y)  # [1] 0.4372294
# "What is the accuracy among the test set samples where the two methods agree?"
# According the description of the question, the third answer should be 0.437. But there is no such option.

# output: Confusion Matrix and Statistics
# output: 
# output:           Reference
# output: Prediction  1  2  3  4  5  6  7  8  9 10 11
# output:         1  29  0  1  0  0  0  0  0  0  4  0
# output:         2   4 39  8  1  0  2  2  0  3  1  4
# output:         3   0  3 18 11  0 11  4  0  0  0  6
# output:         4   0  0  1 24  1  8  0  0  0  0  1
# output:         5   0  0  0  0 19  2  9  2  0  0  1
# output:         6   0  0  0  1  6 40  9  0  0  0  3
# output:         7   0  1  0  0  1  0 41  0  2  0  0
# output:         8   0  0  0  0  0  0  1 33  2  0  0
# output:         9   0  0  0  0  0  4  1  4 35  0  1
# output:         10  0  2  0  1  0  1  0  1  3 16  0
# output:         11  0  0  0  0  1 10  3  0  9  0 11
# output: 
# output: Overall Statistics
# output:                                          
# output:                Accuracy : 0.6602         
# output:                  95% CI : (0.615, 0.7033)
# output:     No Information Rate : 0.1688         
# output:     P-Value [Acc > NIR] : < 2.2e-16      
# output:                                          
# output:                   Kappa : 0.6235         
# output:  Mcnemar's Test P-Value : NA             
