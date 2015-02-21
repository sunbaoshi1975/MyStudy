# Practical Machine Learning
# Lecture 023 modelBasedPrediction
# Code exercise
# iris is an R included dataset
data(iris)
library(ggplot2)
library(caret)

names(iris)
# output: [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species"

table(iris$Species)
# output:     setosa versicolor  virginica 
# output:         50         50         50

# Create training and test sets
inTrain <- createDataPartition(y=iris$Species, p=0.7, list=FALSE)
training <- iris[inTrain,]
testing <- iris[-inTrain,]
dim(training); dim(testing)
# output: [1] 105   5
# output: [1] 45  5

# Build predictions with LDA and NB respectively
modlda = train(Species ~ ., data=training, method="lda")
modnb = train(Species ~ ., data=training, method="nb")
plda = predict(modlda, testing); pnb = predict(modnb, testing)
table(plda, pnb)
# output:             pnb
# output: plda         setosa versicolor virginica
# output:   setosa         15          0         0
# output:   versicolor      0         14         1
# output:   virginica       0          1        14

# Comparison of results
equalPredictions = (plda == pnb)
qplot(Petal.Width, Sepal.Width, color=equalPredictions, data=testing)