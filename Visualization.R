library('ggplot2')
library('ggmap')

#Load complain data "with_null.RData"
load("/Users/andrea/Team5_hw3/with_null.RData")

## Get New YorK City map
NYC <- get_map("New York City", zoom = 11)
ggmap(NYC)

## Get crime locations
full_data$Longitude <- round(as.numeric(full_data$Longitude), 2)
full_data$Latitude <- round(as.numeric(full_data$Latitude), 2)

#create a data frame containing the coordinates of all complains
locationCrimes <- as.data.frame(table(full_data$Longitude, full_data$Latitude))

names(locationCrimes) <- c('long', 'lat', 'Frequency')
locationCrimes$long <- as.numeric(as.character(locationCrimes$long))
locationCrimes$lat <- as.numeric(as.character(locationCrimes$lat))

## Plotting the location heatmap
ggmap(NYC) + geom_tile(data = locationCrimes, aes(x = long, y = lat, alpha = Frequency),
                           fill = 'red') + theme(axis.title.y = element_blank(), axis.title.x = element_blank())



