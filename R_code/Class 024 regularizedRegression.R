# Practical Machine Learning
# Lecture 024 regularizedRegression
# Regularized Regression can help with bias/variance tradeoff, keep features while prevent over fitting
# Code exercise
# http://www.biostat.jhsph.edu/~ririzarr/Teaching/649/
library(ElemStatLearn); data(prostate)
str(prostate)
# output: 'data.frame':	97 obs. of  10 variables:
# output:  $ lcavol : num  -0.58 -0.994 -0.511 -1.204 0.751 ...
# output:  $ lweight: num  2.77 3.32 2.69 3.28 3.43 ...
# output:  $ age    : int  50 58 74 58 62 50 64 58 47 63 ...
# output:  $ lbph   : num  -1.39 -1.39 -1.39 -1.39 -1.39 ...
# output:  $ svi    : int  0 0 0 0 0 0 0 0 0 0 ...
# output:  $ lcp    : num  -1.39 -1.39 -1.39 -1.39 -1.39 ...
# output:  $ gleason: int  6 6 7 6 6 6 6 6 6 6 ...
# output:  $ pgg45  : int  0 0 20 0 0 0 0 0 0 0 ...
# output:  $ lpsa   : num  -0.431 -0.163 -0.163 -0.163 0.372 ...
# output:  $ train  : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...

# Notes: Limited data
## 1. so cross validation is required
## 2. better no discard any features

small = prostate[1:5,]
lm(lpsa ~ ., data=small)
# output: Call:
# output: lm(formula = lpsa ~ ., data = small)
# output: 
# output: Coefficients:
# output: (Intercept)       lcavol      lweight          age         lbph          svi  
# output:     9.60615      0.13901     -0.79142      0.09516           NA           NA  
# output:         lcp      gleason        pgg45    trainTRUE  
# output:          NA     -2.08710           NA           NA  

