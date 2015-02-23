# Quiz 4, question 5
# Code exercise
#install.packages("e1071")
set.seed(3523)
library(AppliedPredictiveModeling)
data(concrete)
inTrain = createDataPartition(concrete$CompressiveStrength, p = 3/4)[[1]]
training = concrete[ inTrain,]
testing = concrete[-inTrain,]

# Fit a support vector machine using the e1071 package to predict Compressive Strength
# using the default settings
set.seed(352)
library(e1071)
mod <- svm(CompressiveStrength ~., data=training)
pred <- predict(mod, testing)

# Predict on the testing set. What is the RMSE?
# RMSE: root-mean-square error

library(forecast)
accuracy(pred, testing$CompressiveStrength)
# output:                 ME     RMSE      MAE       MPE     MAPE
# output: Test set 0.1682863 6.715009 5.120835 -7.102348 19.27739

# or manual calculation
RMSE = sqrt(mean((pred - testing$CompressiveStrength)^2))
RMSE
# output: [1] 6.715009
