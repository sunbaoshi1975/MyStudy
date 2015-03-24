# This source code belongs to R programming assignment III, including:
## function: best()

## Return hospital name in that state with lowest 30-day death rate
## Two arguments: the 2-character abbreviated name of a state and 
## an outcome name.
## The function reads the outcome-of-care-measures.csv file and returns a character vector
## with the name of the hospital that has the best (i.e. lowest) 30-day mortality for the specified outcome
## in that state.
best <- function(state, outcome) {
    ## Read outcome data
    data.original <- read.csv("outcome-of-care-measures.csv", colClasses = "character", na.strings=c("NA","#DIV/0!",""))
    
    ## Filter data
    columns <- c("Hospital.Name")
    columns <- c(columns, "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack")
    columns <- c(columns, "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure")
    columns <- c(columns, "Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia")
    columns <- c(columns, "State")
    data <- data.original[, columns]
    
    ## Give a short name to columns for convinence
    names(data)[1] <- "hospital"
    names(data)[2] <- "heart attack"
    names(data)[3] <- "heart failure"
    names(data)[4] <- "pneumonia"
    
    ## Get outcome list
    ls.outcome <- names(data)[2:4]
    ## Get state list
    ls.state <- factor(unique(data$State))
    
    ## Check that state and outcome are valid
    if(!(state %in% ls.state)) {
        stop("invalid state")
    }
    
    if(!(outcome %in% ls.outcome)) {
        stop("invalid outcome")
    }

    ## Filter by state (Notes: capital 'S' in $State)
    data.state <- data[data$State==state,]
    
    ## Optimized: do conversion later
    ## Convert Death Rates columns (2,3,4) to numeric
    #data[, c(2:4)] <- sapply(data[, c(2:4)], as.numeric)

    ## Convert Death Rates to numeric
    #data[, c(2:4)] <- sapply(data[, c(2:4)], as.numeric)
    suppressWarnings(data.state[, outcome] <- as.numeric(data.state[, outcome]))
    
    ## Remove rows with NAs in corresponsive outcome column
    data.state.clean <- data.state[!is.na(data.state[outcome]),]

    ## Find the lowest value
    lowestValue <- min(data.state.clean[outcome])
    
    ## Based on the lowestValue, filter out result table
    data.result <- data.state.clean[data.state.clean[outcome]==lowestValue,]
    
    ## Sort the result on hospital name in alphetical order
    bestHospital <- sort(data.result[, "hospital"])
    
    ## We got it!
    ## Return hospital name in that state with lowest 30-day death rate
    bestHospital
}