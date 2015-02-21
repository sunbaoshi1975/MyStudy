# Practical Machine Learning
# Lecture 019 predictingWithTrees
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

# Plot iris petal widths / sepal width
qplot(Petal.Width, Sepal.Width, color=Species, data=training)

# Model: rpart, others are party, rpart and these in tree package
modFit <- train(Species ~ ., method="rpart", data=training)
print(modFit$finalModel)
# output: n= 105 
# output: 
# output: node), split, n, loss, yval, (yprob)
# output:       * denotes terminal node
# output: 
# output: 1) root 105 70 setosa (0.33333333 0.33333333 0.33333333)  
# output:   2) Petal.Length< 2.6 35  0 setosa (1.00000000 0.00000000 0.00000000) *
# output:   3) Petal.Length>=2.6 70 35 versicolor (0.00000000 0.50000000 0.50000000)  
# output:     6) Petal.Width< 1.65 35  1 versicolor (0.00000000 0.97142857 0.02857143) *
# output:     7) Petal.Width>=1.65 35  1 virginica (0.00000000 0.02857143 0.97142857) *

# Plot tree
plot(modFit$finalModel, uniform=TRUE, main="Classification Tree")
text(modFit$finalModel, use.n=TRUE, all=TRUE, cex=.8)

# Prettier plots
install.packages("rattle")
library(rattle)
rattle()
# !!!! no working
fancyRpartPlot(modFit$finalModel)

# Predicting new values
predict(modFit, newdata=testing)
# output: [1] setosa     setosa     setosa     setosa     setosa     setosa     setosa    
# output: [8] setosa     setosa     setosa     setosa     setosa     setosa     setosa    
# output:[15] setosa     versicolor versicolor versicolor versicolor versicolor versicolor
# output:[22] versicolor versicolor virginica  versicolor versicolor versicolor versicolor
# output:[29] versicolor versicolor virginica  virginica  virginica  virginica  virginica 
# output:[36] versicolor virginica  virginica  virginica  versicolor virginica  versicolor
# output:[43] virginica  virginica  virginica 
# output:Levels: setosa versicolor virginica
