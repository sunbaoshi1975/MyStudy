# This source code belongs to R programming assignment III, including:
## function: rankall()

## Two arguments: an outcome (outcome) and a hospital ranking for that outcome (num)
## The function reads the outcome-of-care-measures.csv file and returns a 2-column data frame
## containing the hospital in each state that has the ranking specified in num.
## The function should return a value for every state (some may be NA). 
## The first column in the data frame is named hospital, which contains the hospital name,
## and the second column is named state, which contains the 2-character abbreviation
## for the state name.
rankall <- function(outcome, num = "best") {
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
    ## Get state list in order
    ls.state <- sort(factor(unique(data$State)))
    
    ## Check that state and outcome are valid
    if(!(state %in% ls.state)) {
        stop("invalid state")
    }
    
    if(!(outcome %in% ls.outcome)) {
        stop("invalid outcome")
    }

    ## Convert Death Rates to numeric
    suppressWarnings(data[, outcome] <- as.numeric(data[, outcome]))
    
    ## Remove rows with NAs in corresponsive outcome column
    data.clean <- data[!is.na(data[outcome]),]

    ## Put data in order: State, outcome, hospital
    data.ordered <- data.clean[order(data.clean["State"], data.clean[outcome], data.clean["hospital"]), ]
    
    ## For each state, find the hospital of the given rank
    ranks <- matrix(nrow=0, ncol=2, dimnames=list(NULL, c("hospital", "state")))
    for(lp_state in ls.state) {
        data.state <- data.ordered[data.ordered$State==lp_state,]

        ## Check argument: num
        if( num == "best" ) {
            rankhospital <- data.state[1, "hospital"]
        } else if( num == "worst" ) {
            rankhospital <- data.state[nrow(data.state), "hospital"]
        } else if(!is.numeric(num)) {
            stop("invalid num. Should be 'best', 'worst' or an integer")
        } else if(num > nrow(data.state) || num <= 0) {
            ## larger than the number of hospitals in that state
            rankhospital <- NA
        } else {
            rankhospital <- data.state[num, "hospital"]
        }
        
        ranks <- rbind(ranks, c(rankhospital, lp_state))
    }
    

    ## We got it!
    ## Return a data frame with the hospital names and the
    ## (abbreviated) state name
    as.data.frame(ranks)
}