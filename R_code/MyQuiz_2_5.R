library(caret)
library(AppliedPredictiveModeling)
set.seed(3433)
data(AlzheimerDisease)
adData = data.frame(diagnosis,predictors)
inTrain = createDataPartition(adData$diagnosis, p = 3/4)[[1]]
training = adData[ inTrain,]
testing = adData[-inTrain,]

# Create a training data set consisting of only the predictors with variable names beginning with IL and the diagnosis. 
## Build two predictive models, one using the predictors as they are and one using PCA with principal components explaining 80% of the variance in the predictors. 
## Use method="glm" in the train function.colnm <- colnames(training)
IL_str <- grep("^IL", colnm, value = TRUE)

subtrain = training[, IL_str]
subtest = testing[, IL_str]

r = preProcess(subtrain, method = "pca", thresh = 0.8)
rtrain = predict(r, subtrain)
rtrain$diagnosis = training$diagnosis
modelfit_PCA = train(rtrain$diagnosis ~ ., method = 'glm', data = rtrain)
summary(modelfit_PCA)

strain = subtrain
strain$diagnosis = training$diagnosis
modelfit_noPCA = train(strain$diagnosis ~ ., method = 'glm', data = strain)
summary(modelfit_noPCA)

test_pca = predict(r, subtest)
test_nopca = subtest

test_pca$diagnosis = testing$diagnosis
test_nopca$diagnosis = testing$diagnosis

test_pca_pred = predict(modelfit_PCA, test_pca)
test_nopca_pred = predict(modelfit_noPCA, test_nopca)

cm_pca <- confusionMatrix(test_pca_pred, testing$diagnosis)
cm_nopca <- confusionMatrix(test_nopca_pred, testing$diagnosis)

A_pcs <- cm_pca$overall["Accuracy"]
A_nopcs <- cm_nopca$overall["Accuracy"]

print(A_pcs)
print(A_nopcs)
# Non-PCA Accuracy: 0.65
# PCA Accuracy: 0.72