# Exploratory Data Analysis
# Course Porject 2 - Plot 4
#--------------------------------
## Q4: Across the United States, how have emissions from coal combustion-related sources changed from 1999-2008?
#--------------------------------
plot4 <- function(genPNG=TRUE) {
    
    #--------------------------------
    # The following code snippet is shared through plot 1 to plot 6
    ## Loading Data
    ## This first line will likely take a few seconds. Be patient!
    NEI <- readRDS("summarySCC_PM25.rds")
    SCC <- readRDS("Source_Classification_Code.rds")
    #--------------------------------
    
    #--------------------------------
    ## Prepare plotting data
    ### coal related sources
    scc_coal <- as.vector(SCC[grepl("coal", SCC$EI.Sector, ignore.case = TRUE),1])
    
    library(dplyr)
    data.all <- tbl_df(NEI)
    data.totalcoal <- filter(data.all, SCC %in% scc_coal) %>%
        group_by(year) %>%
        summarize(sumEmissions=sum(Emissions))
    #--------------------------------
    
    #--------------------------------
    ## Save as png
    if (genPNG) {
        png("./plot4.png")
    }
    
    ## Draw Plot
    with(data.totalcoal, {
        plot(year, sumEmissions, type="b", col="black", xlab="Year", ylab="Total Emissions", main="Q4: Coal Combustion-related PM2.5 Emissions in the U.S.")
    })
    
    ## Close device
    if (genPNG) {
        dev.off()
    }    
    #--------------------------------
}