library(dplyr)
library(data.table)
library(foreign)

#load data of intersection
load("/home/vis/cr173/Sta523/data/nyc/intersections/intersections.Rdata")
intersection <- data.frame(data, stringsAsFactors = FALSE)
intersection$Stree1 <- as.character(intersection$Stree1)
intersection$Street2 <- as.character(intersection$Street2)

names(nyc)[c(1, which(names(nyc) == 'Incident.Address'), which(names(nyc) == 'Borough'))] <- c('intersection_Unique.Key', 'intersection_Incident.Address', 'intersection_Borough')

#select informative data from nyc dataset
intersection_nyc = nyc %>%
  select(contains("Intersection")) %>%
  filter(intersection_Incident.Address != "") %>%
  filter(Intersection.Street.1 != "")
#rename dataframe, in order to merge data in next step
names(intersection_nyc)[3:4] <- names(intersection)[4:5]

#merge longitude and latitude into nyc data
Join_Intersection = left_join(intersection_nyc, intersection, by = c("Stree1", "Street2"))

#select useful data which contain information of longitude and latitude
index <- which(is.na(Join_Intersection$longitude) == FALSE)
Clean_Join_Intersection <- Join_Intersection[index, ]

#select unique streets name
streets.name=nyc%>%select(contains("Street.Name"))%>%distinct()
#name streets name as "Address"
names(streets.name)="streets"
Clean_Join_Intersection=left_join(streets.name, Clean_Join_Intersection, by="streets")

#plot intersection borough graph
plot(Clean_Join_Intersection$longitude,Clean_Join_Intersection$latitude,cex = 0.1, col=as.factor(Clean_Join_Intersection$intersection_Borough))
