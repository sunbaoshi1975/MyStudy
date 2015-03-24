# This source code belongs to R programming assignment III, including:
## function: rankhospital()

## Return hospital name in that state with the given rank 30-day death rate
## Three arguments: the 2-character abbreviated name of a state (state), 
## an outcome (outcome), and the ranking of a hospital in that state for that outcome (num)
## The function reads the outcome-of-care-measures.csv file and returns a character vector
## with the name of the hospital that has the ranking specified by the num argument
## in that state.
rankhospital <- function(state, outcome, num = "best") {
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

    ## Check argument: num
    if( num == "best" ) {
        num <- 1
    } else if( num == "worst" ) {
        num <- nrow(data.state.clean)
    } else if(!is.numeric(num)) {
        stop("invalid num. Should be 'best', 'worst' or an integer")
    } else if(num > nrow(data.state.clean) || num <= 0) {
        ## larger than the number of hospitals in that state
        rankhospital <- NA
        rankhospital
        return
    }
    
    ## Put data in order: outcome, hospital
    data.ordered <- data.state.clean[order(data.state.clean[outcome], data.state.clean["hospital"]), ]
    
    ## We got it!
    ## Return hospital name in that state with the given rank
    ## 30-day death rate
    rankhospital <- data.ordered[num, "hospital"]
    rankhospital
}