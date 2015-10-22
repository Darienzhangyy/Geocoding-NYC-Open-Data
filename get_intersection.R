library(rgdal)
path.expand("~cr173")

inter <- readOGR(path.expand('~cr173/Sta523/data/nyc/intersections/'),
                 'intersections', stringsAsFactors = FALSE)

library(stringr)
sub = str_detect(inter@data$streets, ':')
head(inter@data$streets[sub])


inter = inter[!is.na(inter@data$streets), ]
inter = inter[str_detect(inter@data$streets, ':'), ]
inter = inter[!str_detect(inter@data$streets, ':.*:'), ]

plot(inter, axes = TRUE, pch = 16, cex = .001, col = adjustcolor('black', .8))

data <- inter@data
data <- cbind(data, coordinates(inter))
names(data)[3 : 4] = c('longitude', 'latitude')
data$id <- NULL

data <- cbind(data, str_split_fixed(data$streets, ':', 2))
names(data)[4 : 5]<- c('street1', 'street2')
data$streets <- NULL
