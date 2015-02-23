# Practical Machine Learning
# Lecture 025 combining predictors
# Code exercise
library(ISLR); data(Wage)
library(ggplot2); library(caret)

Wage <- subset(Wage, select=-c(logwage))

# Create a building data set and validation set
## 30% - validation; 21% (70% * 30%) testing; 49% (70% * 70%) training
inBuild <- createDataPartition(y=Wage$wage, p=0.7, list=FALSE)
validation <- Wage[-inBuild,]; buildData <- Wage[inBuild,]
inTrain <- createDataPartition(y=buildData$wage, p=0.7, list=FALSE)
training <- buildData[inTrain,]; testing <- buildData[-inTrain,]
dim(training); dim(testing); dim(validation)
# output: [1] 1474   11
# output: [1] 628  11
# output: [1] 898  11

# Build two different models
mod1 <- train(wage ~., method="glm", data=training)
## Random Forests with 3 fold cross validation
mod2 <- train(wage ~., method="rf", data=training, trControl=trainControl(method="cv"),number=3)

# Predict and plot
pred1 <- predict(mod1, testing); pred2 <- predict(mod2, testing)
qplot(pred1, pred2, color=wage, data=testing)

# Fit a model that combines predictors
predDF <- data.frame(pred1, pred2, wage=testing$wage)
combModFit <- train(wage ~., method="gam", data=predDF)
combPred <- predict(combModFit, predDF) # ???
combPred <- predict(combModFit, testing)

# Testing errors
sqrt(sum((pred1-testing$wage)^2)); sqrt(sum((pred2-testing$wage)^2)); sqrt(sum((combPred-testing$wage)^2))
[1] 876.4146
[1] 902.4933
[1] 862.7428  # ??? no improvement

# Predict on validation data set
pred1V <- predict(mod1, validation)
pred2V <- predict(mod2, validation)
predVDF <- data.frame(pred1=pred1V, pred2=pred2V)
combPredV <- predict(combModFit, predVDF)

# Evaluation on validation
sqrt(sum((pred1V-validation$wage)^2)); sqrt(sum((pred2V-validation$wage)^2)); sqrt(sum((combPredV-validation$wage)^2))
[1] 1091.948
[1] 1112.936
[1] 1077.592

