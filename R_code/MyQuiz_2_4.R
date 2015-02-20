library(caret)
library(AppliedPredictiveModeling)
set.seed(3433)
data(AlzheimerDisease)
adData = data.frame(diagnosis,predictors)
inTrain = createDataPartition(adData$diagnosis, p = 3/4)[[1]]
training = adData[ inTrain,]
testing = adData[-inTrain,]

# Find all the predictor variables in the training set that begin with IL. 
## Perform principal components on these variables with the preProcess() function from the caret package. 
## Calculate the number of principal components needed to capture 90% of the variance.
colnm <- colnames(training)
IL_str <- grep("^IL", colnm, value = TRUE)
preProc <- preProcess(training[, IL_str], method = "pca", thresh = 0.9)
preProc$rotation
# We got PC1-PC9. If set capture rate to 80%, we will get PC1-PC7