# Install/load the ggplot2 package
install.packages("ggplot2")
library("ggplot2")

# Initialise the environment with the required datasets, 
# you should download the .zip from the course website
# and unzip into your working directory.
if(!exists("NEI"))
{
  print("Reading NEI data...")
  NEI <- readRDS("summarySCC_PM25.rds")  
}

# Subset the data to filter on fips == 24510, this will 
# return us all observations for Baltimore City, Maryland
subNEI <- NEI[NEI$fips == 24510, ]

# Aggregate the data based upon the observation years 
aggNEI <- aggregate(subNEI$Emissions, by=list(subNEI$year, subNEI$type), FUN=sum, na.rm=TRUE)

# Rename the columns to more appropriate names
colnames(aggNEI) <- c("obsYear", "type", "Emissions")

# Plot the dataset using ggplot2 to create a barplot, with appropriate labels
png("plot3.png", width=601, height=570)
ggplot(aggNEI, aes(x=factor(aggNEI$obsYear), y=aggNEI$Emissions, fill=factor(aggNEI$type))) + 
  geom_bar(position="dodge", stat="identity") +
  facet_wrap(~type, nrow=2) +
  geom_text(aes(y=Emissions, label=round(Emissions, 1)), color="black", vjust=-.5) +
  scale_y_continuous("PM2.5 Emissions in Tons", limits=c(0, 2200), breaks=seq(0, 2500, 250)) +
  scale_x_discrete("Year") + 
  scale_fill_discrete(name = "Source Type") +
  ggtitle("Baltimore City Emissions Analysis")
dev.off()