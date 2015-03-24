# This package is for R programming assignment II
#
# The purpose of this program is to implement cache feature for calculation of
## matrix inversion. Matrix inversion is usually a costly computation, so 
## caching the inverse of a matrix will avoid repeating computation and 
## return result quickly.
#
# There are 2 funtions in this file:
## 1. makeCacheMatrix() - This function creates a special "matrix" object 
##                        that can cache its inverse.
## 2. cacheSolve() - This function computes the inverse of the special "matrix" 
##                   returned by makeCacheMatrix above. 
##                   If the inverse has already been calculated (and the matrix has not changed), 
##                   then the cachesolve should retrieve the inverse from the cache.


# Creates a special "matrix" object, which includes two properties and four methods:
# Properties:
## 1. 'key': the original matrix
## 2. 'v_inv': the inverse of 'key'
# Methods:
## 1. 'set': set the key (value of the matrix)
## 2. 'get': set the key (value of the matrix)
## 3. 'setinv': set the inverse of the matrix
## 4. 'getinv': get the inverse of the matrix
makeCacheMatrix <- function(key = matrix()) {
    ## Initialize the caching storage variable
    v_inv <- NULL
    
    ## set method
    set <- function(newkey) {
        ## Store the 'key'
        key <<- newkey
        ## Reset the 'value' for the new key
        v_inv <<- NULL
    }
    
    ## get method
    get <- function() key
    
    ## setinv method
    setinv <- function(value) v_inv <<- value
    
    ## getinv method
    getinv <- function() v_inv
    
    list(set = set, get = get,
         setinv = setinv,
         getinv = getinv)
}


# Computes the inverse of the special "matrix"
##
## Input: a special "matrix" object, whose key is an invertible square matrix
## Output: the inverse of the input matrix
## Process: 
## 1. Check if there is cached result for the same input. 
##    Reture the result directly if find it.
## 2. Otherwise, conduct calculation, then cache and return the result
##
# Notes:
## 1. use solve() funtion to compute the inverse of a matrix
## 2. assume the matrix supplied is always invertible
##    (may need to add exception process later)
cacheSolve <- function(x, ...) {
    ## Check the cached data
    m <- x$getinv()
    if(!is.null(m)) {
        message("getting cached data")
        return(m)
    }
    
    ## Calculate value
    data <- x$get()
    m <- solve(data, ...)
    x$setinv(m)
    m
}
