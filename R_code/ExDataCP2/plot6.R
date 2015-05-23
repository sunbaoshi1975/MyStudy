# Exploratory Data Analysis
# Course Porject 2 - Plot 6
#--------------------------------
## Q6: Compare emissions from motor vehicle sources in Baltimore City with emissions from motor vehicle sources in Los Angeles County, California (fips == "06037").
##  Which city has seen greater changes over time in motor vehicle emissions?
#--------------------------------
plot6 <- function(genPNG=TRUE) {
    
    #--------------------------------
    # The following code snippet is shared through plot 1 to plot 6
    ## Loading Data
    ## This first line will likely take a few seconds. Be patient!
    NEI <- readRDS("summarySCC_PM25.rds")
    SCC <- readRDS("Source_Classification_Code.rds")
    #--------------------------------
    
    #--------------------------------
    ## Prepare plotting data
    ### motor vehicle sources: 'vehicle' in short.Name
    scc_motor <- as.vector(SCC[grepl("vehicle", SCC$Short.Name, ignore.case = TRUE),1])
    
    library(dplyr)
    data.all <- tbl_df(NEI)
    data.bal_los_motor <- filter(data.all, (SCC %in% scc_motor) & (fips == "24510" | fips == "06037")) %>%
        group_by(year, fips) %>%
        summarize(motor_Emissions=sum(Emissions))
    data.bal_los_motor$city <- "Baltimore"
    data.bal_los_motor$city[data.bal_los_motor$fips=="06037"] <- "Los Angeles"
    #--------------------------------
    
    #--------------------------------
    ## Save as png
    if (genPNG) {
        png("./plot6.png")
    }
    
    ## Draw Plot
    library(ggplot2)
    p <- qplot(year, motor_Emissions, data=data.bal_los_motor, geom=c("point", "smooth"), col=city, method="lm")
    print(p)
    
    ## Close device
    if (genPNG) {
        dev.off()
    }    
    #--------------------------------
}