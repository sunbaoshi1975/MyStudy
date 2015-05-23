# Exploratory Data Analysis
# Course Porject 2 - Plot 3
#--------------------------------
### Use the ggplot2 plotting system to make a plot answer this question.
#--------------------------------
plot3 <- function(genPNG=TRUE) {
    
    #--------------------------------
    # The following code snippet is shared through plot 1 to plot 6
    ## Loading Data
    ## This first line will likely take a few seconds. Be patient!
    NEI <- readRDS("summarySCC_PM25.rds")
    SCC <- readRDS("Source_Classification_Code.rds")
    #--------------------------------
    
    #--------------------------------
    ## Prepare plotting data
    library(dplyr)
    data.all <- tbl_df(NEI)
    data.baltimoretypes <- filter(data.all, fips=="24510") %>%
        group_by(year, type) %>%
        summarize(sumEmissions=sum(Emissions))
    #--------------------------------
    
    #--------------------------------
    library(ggplot2)
    ## Save as png
    if (genPNG) {
        png("./plot3.png")
    }
    
    ## Draw Plot
    #p <- qplot(year, sumEmissions, data=data.baltimoretypes, facets=.~type)
    p <- qplot(year, sumEmissions, data=data.baltimoretypes, geom=c("line"), color=type)
    print(p)
    
    ## Close device
    if (genPNG) {
        dev.off()
    }    
    #--------------------------------
}