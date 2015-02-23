# Quiz 4, question 3
# Code exercise
set.seed(3523)
library(AppliedPredictiveModeling)
data(concrete)
inTrain = createDataPartition(concrete$CompressiveStrength, p = 3/4)[[1]]
training = concrete[ inTrain,]
testing = concrete[-inTrain,]

set.seed(233)
# fit a lasso model to predict Compressive Strength
# Which variable is the last coefficient to be set to zero as the penalty increases
# Hint: it may be useful to look up ?plot.enet
model = train(CompressiveStrength ~ ., method = 'lasso', data = training)
model
plot(model$finalModel)
plot.enet(model$finalModel, xvar="penalty",use.color = TRUE)
# As can be seen, Cement is the last coefficient to approach 0

# output: The lasso 
# output: 
# output: 774 samples
# output:   8 predictor
# output: 
# output: No pre-processing
# output: Resampling: Bootstrapped (25 reps) 
# output: 
# output: Summary of sample sizes: 774, 774, 774, 774, 774, 774, ... 
# output: 
# output: Resampling results across tuning parameters:
# output: 
# output:   fraction  RMSE      Rsquared   RMSE SD    Rsquared SD
# output:   0.1       15.25688  0.3396976  0.6020528  0.05290710 
# output:   0.5       11.63307  0.5644277  0.5637856  0.03292817 
# output:   0.9       10.60719  0.6046048  0.3639370  0.02125698 
# output: 
# output: RMSE was used to select the optimal model using  the smallest value.
# output: The final value used for the model was fraction = 0.9. 