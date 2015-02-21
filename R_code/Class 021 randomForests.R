# Practical Machine Learning
# Lecture 021 randomForests
# Code exercise
# iris is an R included dataset
data(iris)
library(ggplot2)
library(caret)

names(iris)
# output: [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species"

# Create training and test sets
inTrain <- createDataPartition(y=iris$Species, p=0.7, list=FALSE)
training <- iris[inTrain,]
testing <- iris[-inTrain,]
dim(training); dim(testing)
# output: [1] 105   5
# output: [1] 45  5

# Model: Random Forests, others are party, rpart and these in tree package
modFit <- train(Species ~ ., data=training, method="rf", prox=TRUE)
modFit
# output: Random Forest 
# output: 
# output: 105 samples
# output:   4 predictor
# output:   3 classes: 'setosa', 'versicolor', 'virginica' 

# output: No pre-processing
# output: Resampling: Bootstrapped (25 reps) 
# output: 
# output: Summary of sample sizes: 105, 105, 105, 105, 105, 105, ... 
# output: 
# output: Resampling results across tuning parameters:
# output: 
# output:   mtry  Accuracy   Kappa      Accuracy SD  Kappa SD  
# output:   2     0.9683340  0.9517612  0.02677864   0.04070344
# output:   3     0.9660692  0.9483790  0.02996543   0.04537576
# output:   4     0.9639961  0.9452740  0.03346320   0.05051235
# output: 
# output: Accuracy was used to select the optimal model using  the largest value.
# output: The final value used for the model was mtry = 2. 

# Getting a single tree
getTree(modFit$finalModel, k=2)
# output:    left daughter right daughter split var split point status prediction
# output: 1              2              3         4        0.70      1          0
# output: 2              0              0         0        0.00     -1          1
# output: 3              4              5         3        4.75      1          0
# output: 4              0              0         0        0.00     -1          2
# output: 5              6              7         4        1.75      1          0
# output: 6              8              9         1        6.50      1          0
# output: 7              0              0         0        0.00     -1          3
# output: 8              0              0         0        0.00     -1          3
# output: 9             10             11         1        7.00      1          0
# output: 10             0              0         0        0.00     -1          2
# output: 11             0              0         0        0.00     -1          3

# Class "centers" & Plot
irisP <- classCenter(training[,c(3,4)], training$Species, modFit$finalModel$prox)
irisP <- as.data.frame(irisP); irisP$Species <- rownames(irisP)
p <- qplot(Petal.Width, Petal.Length, col=Species, data=training)
p + geom_point(aes(x=Petal.Width, y=Petal.Length, col=Species), size=5, shape=4, data=irisP)

# Predicting new values
pred <- predict(modFit, testing); testing$predRight <- pred==testing$Species
table(pred, testing$Species)
# output: pred         setosa versicolor virginica
# output:   setosa         15          0         0
# output:   versicolor      0         13         1
# output:   virginica       0          2        14

# Plot predict result
qplot(Petal.Width, Petal.Length, col=predRight, data=testing, main="newdata Preditions")
