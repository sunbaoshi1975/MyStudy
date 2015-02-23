# Practical Machine Learning
# Quiz 4, question 2
# Code exercise
library(caret)
library(gbm)
set.seed(3433)
library(AppliedPredictiveModeling)
data(AlzheimerDisease)
adData = data.frame(diagnosis,predictors)
inTrain = createDataPartition(adData$diagnosis, p = 3/4)[[1]]
training = adData[ inTrain,]
testing = adData[-inTrain,]

set.seed(62433)
mod_rf <- train(diagnosis ~., method="rf", data=training)
mod_gbm <- train(diagnosis ~., method="gbm", data=training)
mod_lda <- train(diagnosis ~., method="lda", data=training)

# Stack the predictions together using random forests ("rf")
pred_rf <- predict(mod_rf, training); pred_gbm <- predict(mod_gbm, training); pred_lda <- predict(mod_lda, training)
predDF <- data.frame(rf=pred_rf, gbm=pred_gbm, lda=pred_lda, diagnosis=training$diagnosis)
mod_comb <- train(diagnosis ~., method="rf", data=predDF)

pred_rf_test <- predict(mod_rf, testing)
pred_gbm_test <- predict(mod_gbm, testing)
pred_lda_test <- predict(mod_lda, testing)
comb_data_test <- data.frame(rf=pred_rf_test, gbm=pred_gbm_test, lda=pred_lda_test, diagnosis=testing$diagnosis)
pred_comb_test <- predict(mod_comb, comb_data_test)

accuracy_rf = sum(pred_rf_test == testing$diagnosis) / length(testing$diagnosis)
accuracy_gbm = sum(pred_gbm_test == testing$diagnosis) / length(testing$diagnosis)
accuracy_lda = sum(pred_lda_test == testing$diagnosis) / length(testing$diagnosis)
accuracy_comb = sum(pred_comb_test == comb_data_test$diagnosis) / length(testing$diagnosis)

accuracy_rf; accuracy_gbm; accuracy_lda; accuracy_comb
# output: [1] 0.7682927
# output: [1] 0.7926829
# output: [1] 0.7682927
# output: [1] 0.7926829