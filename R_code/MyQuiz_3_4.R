# Practical Machine Learning
# Quiz 3, question 4
# Code exercise
#install.packages("olive")
rm(list = ls())
library(caret)

# Load the South Africa Heart Disease Data and create training and test sets with the following code
library(ElemStatLearn)
data(SAheart)
names(SAheart)
# output:   [1] "sbp"       "tobacco"   "ldl"       "adiposity" "famhist"  
# output:   [6] "typea"     "obesity"   "alcohol"   "age"       "chd"  

set.seed(8484)
train = sample(1:dim(SAheart)[1],size=dim(SAheart)[1]/2,replace=F)
trainSA = SAheart[train,]
testSA = SAheart[-train,]
 
# Then set the seed to 13234 and fit a logistic regression model 
## (method="glm", be sure to specify family="binomial") with Coronary Heart Disease (chd)
## as the outcome and age at onset, current alcohol consumption, 
## obesity levels, cumulative tobacco, type-A behavior, and low density lipoprotein cholesterol as predictors.
## Calculate the misclassification rate for your model using this function and a prediction on the "response" scale
set.seed(13234)
training <- trainSA[,-c(1,4,5)]
testing <- testSA[,-c(1,4,5)]
modFit <- train(chd ~., data=training, method="glm", family="binomial")
print(modFit$finalModel)
# output:   Call:  NULL
# output:   
# output:   Coefficients:
# output:   (Intercept)      tobacco          ldl        typea      obesity  
# output:      -2.71236      0.10374      0.16544      0.02894     -0.13241  
# output:       alcohol          age  
# output:      -0.00324      0.06561  
# output:   
# output:   Degrees of Freedom: 230 Total (i.e. Null);  224 Residual
# output:   Null Deviance:	    302.8 
# output:   Residual Deviance: 237.7 	AIC: 251.7

trainPred = predict(modFit, newdata=training)
testPred = predict(modFit, newdata=testing)

missClass = function(values,prediction){sum(((prediction > 0.5)*1) != values)/length(values)}

trainMissClass = missClass(training$chd, trainPred)
testMissClass = missClass(testing$chd, testPred)
print(trainMissClass); print(testMissClass)
# output:  [1] 0.2727273
# output:  [1] 0.3116883