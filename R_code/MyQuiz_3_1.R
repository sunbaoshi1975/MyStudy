# Practical Machine Learning
# Quiz 3, question 1
# Code exercise
library(AppliedPredictiveModeling)
library(caret)

rm(list = ls())

# 191 columns
data(segmentationOriginal)
names(segmentationOriginal)

# 1. Subset the data to a training set and testing set based on the Case variable in the data set.
data <- segmentationOriginal
training <- subset(data, Case == "Train")
testing <- subset(data, Case == "Test")
dim(training); dim(testing)
# output: [1] 1009  119
# output: [1] 1010 119

# 2. Set the seed to 125 and fit a CART model with the rpart method using all predictor variables and default caret settings. 
set.seed(125)
modFit <- train(Class ~., method="rpart", data=training)
print(modFit$finalModel)
# output: n= 1009 
# output: 
# output: node), split, n, loss, yval, (yprob)
# output:       * denotes terminal node
# output: 
# output: 1) root 1009 373 PS (0.63032706 0.36967294)  
# output:   2) TotalIntenCh2< 45323.5 454  34 PS (0.92511013 0.07488987) *
# output:   3) TotalIntenCh2>=45323.5 555 216 WS (0.38918919 0.61081081)  
# output:     6) FiberWidthCh1< 9.673245 154  47 PS (0.69480519 0.30519481) *
# output:     7) FiberWidthCh1>=9.673245 401 109 WS (0.27182045 0.72817955) *

# Plot tree
plot(modFit$finalModel, uniform=TRUE, main="Classification Tree")
text(modFit$finalModel, use.n=TRUE, all=TRUE, cex=.8)

# 3. In the final model what would be the final model prediction for cases with the following variable values
## a. TotalIntench2 = 23,000; FiberWidthCh1 = 10; PerimStatusCh1=2  -> PS
## b. TotalIntench2 = 50,000; FiberWidthCh1 = 10;VarIntenCh4 = 100  -> WS
## c. TotalIntench2 = 57,000; FiberWidthCh1 = 8;VarIntenCh4 = 100 	-> PS
## d. FiberWidthCh1 = 8;VarIntenCh4 = 100; PerimStatusCh1=2 		-> N/A

# Q 3-2
## If K is small in a K-fold cross validation is the bias in the estimate of out-of-sample (test set) accuracy smaller or bigger?
## If K is small is the variance in the estimate of out-of-sample (test set) accuracy smaller or bigger.
## Is K large or small in leave one out cross validation?
## Ans: The bias is larger and the variance is smaller. Under leave one out cross validation K is equal to the sample size.
