# Practical Machine Learning
# Course Project Source Code
# Code exercise
rm(list = ls())
library(ggplot2)
library(caret)
library(randomForest)

# read original datasets, both training and testing examples
## setwd("D:/4 - Works/GitHub/MyStudy/PML Course Project")
rawData_training <- read.csv('pml-training.csv', header=TRUE, sep=',', na.strings=c("NA","#DIV/0!",""))
rawData_testing <- read.csv('pml-testing.csv', header=TRUE, sep=',', na.strings=c("NA","#DIV/0!",""))

# Raw Data Exploration
dim(rawData_training); dim(rawData_testing)
names(rawData_training)
table(rawData_training$user_name)
table(rawData_training$classe)
head(rawData_training, 3)

# number of rows with no NA values
sum(complete.cases(rawData_training))
# number of columns with at least one NA value
sum(sapply(names(rawData_training), function(x) any(is.na(rawData_training[,x]))))

set.seed(201502)

# Implementation
## Data cleaning
## For data cleaning, We have 3 tasks to do:
## 1. Delete irrelevant columns (the first 7)
training <- rawData_training[, -c(1:7)]
testing <- rawData_testing[, -c(1:7)]
## Convert everything except "classe" (last column) to numbers
features = dim(training)[2]
suppressWarnings(training[,-c(features)] <- sapply(training[,-c(features)], as.numeric))
suppressWarnings(testing[,-c(features)] <- sapply(testing[,-c(features)], as.numeric))

## 2. To deal with columns with NA values
# Option 1: to delete any columns containing NAs, simplest method but may lose information
training <- training[, colSums(is.na(training)) == 0]
testing <- testing[, colSums(is.na(testing)) == 0]
dim(training);dim(testing)

## Option 2: just remove columns with all or an excessive ratio of NAs. The threshold can be defined.
### We choose 80% here
Threshold_NARatio = 0.8
ExcessiveNAsCol <- (colSums(is.na(training)) > (nrow(training) * Threshold_NARatio))
training <- training[!ExcessiveNAsCol]
testing <- testing[!ExcessiveNAsCol]
dim(training);dim(testing)

## Option 3: to convert NAs with numbers (e.g. 0), easy way but will introduce additional assumptions
NAtoNum = 0.0
training <- replace(training, is.na(training), NAtoNum)
testing <- replace(testing, is.na(testing), NAtoNum)
### check number of columns with at least one NA value
sum(sapply(names(training), function(x) any(is.na(training[,x]))))

## 3. To trim off features with near zero variance [optional]
nzv <- nearZeroVar(training)
training <- training[, -nzv]
testing <- testing[, -nzv]

## Feature Selection
fitCtrl <- trainControl(method = "cv", number = 5)
modFit <- train(classe ~ ., method="rpart", data=training, na.action = na.pass, trControl = fitCtrl)
modFit
vi = varImp(modFit)
vi

## Weed out 0 importance features
impfeatures <- rownames(vi$importance)[vi$importance > 0]
impfeatures
# impfeatures = c("accel_arm_x","accel_belt_z","accel_dumbbell_y","magnet_arm_x","magnet_belt_y","magnet_dumbbell_y","magnet_dumbbell_z","pitch_forearm","roll_arm","roll_belt","roll_dumbbell","roll_forearm","total_accel_belt","yaw_belt")

# Creation of Working Datasets
## with 30% Cross Validation
set.seed(201502)
modFeatures = c(impfeatures, "classe")
training <- training[modFeatures]
inTrain <- createDataPartition(y=training$classe, p=0.7, list=FALSE)
selftraining <- training[inTrain,]
selftesting <- training[-inTrain,]
dim(selftraining); dim(selftesting)

### Model Training
#### rf
modrf = randomForest(classe ~ ., data=selftraining, na.action=na.omit)
#modrf = train(classe ~ ., data=selftraining, method="rf", prox=TRUE)
#### nb
modnb = train(classe ~ ., data=selftraining, method="nb")
modrf; modnb
# output: Call:
# output:  randomForest(formula = classe ~ ., data = selftraining, na.action = na.omit) 
# output:                Type of random forest: classification
# output:                      Number of trees: 500
# output: No. of variables tried at each split: 3
# output: 
# output:         OOB estimate of  error rate: 1.19%
# output: Confusion matrix:
# output:      A    B    C    D    E class.error
# output: A 3893   10    3    0    0 0.003328213
# output: B   23 2607   23    5    0 0.019187359
# output: C    0   20 2361   15    0 0.014607679
# output: D    3    3   33 2211    2 0.018206039
# output: E    0    4    7   12 2502 0.009108911

# output: Naive Bayes 
# output: 
# output: 13737 samples
# output:    14 predictor
# output:     5 classes: 'A', 'B', 'C', 'D', 'E' 
# output: 
# output: No pre-processing
# output: Resampling: Bootstrapped (25 reps) 
# output: 
# output: Summary of sample sizes: 13737, 13737, 13737, 13737, 13737, 13737, ... 
# output: 
# output: Resampling results across tuning parameters:
# output: 
# output:   usekernel  Accuracy   Kappa      Accuracy SD  Kappa SD   
# output:   FALSE      0.5028945  0.3694781  0.007829624  0.009641459
# output:    TRUE      0.6960488  0.6150536  0.006436330  0.008195897
# output: 
# output: Tuning parameter 'fL' was held constant at a value of 0
# output: Accuracy was used to select the optimal model using  the largest value.
# output: The final values used for the model were fL = 0 and usekernel = TRUE. 

#### Model Self-test
predrf = predict(modrf, selftesting)
prednb = predict(modnb, selftesting)

#### Comparison of two predictions
##### rf: Sample Accuracy
confusionMatrix(predrf, selftesting$classe)
##### nb: Sample Accuracy
confusionMatrix(prednb, selftesting$classe)

# output: Confusion Matrix and Statistics
# output: 
# output:           Reference
# output: Prediction    A    B    C    D    E
# output:          A 1670    1    0    0    0
# output:          B    4 1130   10    0    1
# output:          C    0    7 1013   10    1
# output:          D    0    1    3  951    4
# output:          E    0    0    0    3 1076
# output: 
# output: Overall Statistics
# output:                                           
# output:                Accuracy : 0.9924          
# output:                  95% CI : (0.9898, 0.9944)
# output:     No Information Rate : 0.2845          
# output:     P-Value [Acc > NIR] : < 2.2e-16       
# output:                                           
# output:                   Kappa : 0.9903          
# output:  Mcnemar's Test P-Value : NA              
# output: 
# output: Statistics by Class:
# output: 
# output:                      Class: A Class: B Class: C Class: D Class: E
# output: Sensitivity            0.9976   0.9921   0.9873   0.9865   0.9945
# output: Specificity            0.9998   0.9968   0.9963   0.9984   0.9994
# output: Pos Pred Value         0.9994   0.9869   0.9825   0.9917   0.9972
# output: Neg Pred Value         0.9991   0.9981   0.9973   0.9974   0.9988
# output: Prevalence             0.2845   0.1935   0.1743   0.1638   0.1839
# output: Detection Rate         0.2838   0.1920   0.1721   0.1616   0.1828
# output: Detection Prevalence   0.2839   0.1946   0.1752   0.1630   0.1833
# output: Balanced Accuracy      0.9987   0.9945   0.9918   0.9924   0.9969

# output: Confusion Matrix and Statistics
# output: 
# output:           Reference
# output: Prediction    A    B    C    D    E
# output:          A 1389  170   92   97   40
# output:          B   77  687   60   53  216
# output:          C   99  173  790  107  129
# output:          D  105   97   80  680   90
# output:          E    4   12    4   27  607
# output: 
# output: Overall Statistics
# output:                                           
# output:                Accuracy : 0.7057          
# output:                  95% CI : (0.6939, 0.7173)
# output:     No Information Rate : 0.2845          
# output:     P-Value [Acc > NIR] : < 2.2e-16       
# output:                                           
# output:                   Kappa : 0.6272          
# output:  Mcnemar's Test P-Value : < 2.2e-16       
# output: 
# output: Statistics by Class:
# output: 
# output:                      Class: A Class: B Class: C Class: D Class: E
# output: Sensitivity            0.8297   0.6032   0.7700   0.7054   0.5610
# output: Specificity            0.9052   0.9145   0.8955   0.9244   0.9902
# output: Pos Pred Value         0.7768   0.6285   0.6086   0.6464   0.9281
# output: Neg Pred Value         0.9304   0.9057   0.9486   0.9412   0.9092
# output: Prevalence             0.2845   0.1935   0.1743   0.1638   0.1839
# output: Detection Rate         0.2360   0.1167   0.1342   0.1155   0.1031
# output: Detection Prevalence   0.3038   0.1857   0.2206   0.1788   0.1111
# output: Balanced Accuracy      0.8675   0.7588   0.8327   0.8149   0.7756

### Prediction on Testing Dataset
finalpred = predict(modrf, testing)
finalpred
# output:  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 
# output:  B  A  B  A  A  E  D  B  A  A  B  C  B  A  E  E  A  B  B  B

# Save the results into a text file
write.table(finalpred, file="results.txt", quote=TRUE, sep=",", col.names=FALSE, row.names=FALSE)

### Final Variable Importance
finalvi = varImp(modrf)
finalvi
finalvi = data.frame(var = 1:nrow(finalvi), imp = finalvi$Overall)
finalvi[order(finalvi$imp, decreasing = T),]

# output:                     Overall
# output: accel_arm_x        453.4735
# output: accel_belt_z       592.8715
# output: accel_dumbbell_y   678.5102
# output: magnet_arm_x       443.0251
# output: magnet_belt_y      601.6317
# output: magnet_dumbbell_y  974.7378
# output: magnet_dumbbell_z 1072.8141
# output: pitch_forearm     1004.6471
# output: roll_arm           611.1098
# output: roll_belt         1418.3076
# output: roll_dumbbell      663.9278
# output: roll_forearm       796.0871
# output: total_accel_belt   315.0171
# output: yaw_belt          1233.0589