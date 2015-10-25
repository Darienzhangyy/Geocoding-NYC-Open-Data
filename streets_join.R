library(dplyr)
library(data.table)
library(foreign)
library(graphics)


nyc=fread("/home/vis/cr173/Sta523/data/nyc/nyc_311.csv") %>% tbl_df()


#read intersection file
intersection=read.dbf(path.expand(("/home/vis/cr173/Sta523/data/nyc/intersections/intersections.dbf")), as.is=TRUE)
#load pluto data
load(path.expand(("/home/vis/cr173/Sta523/data/nyc/pluto/pluto.Rdata")))
str(pluto)
#select unique streets name
streets=nyc%>%select(contains("Street.Name"))%>%distinct()
#name streets name as "Address"
names(streets)="Address"

#full join streets and pluto by "Address"
streets_join=right_join(streets,pluto, by="Address")

streets_join=streets_join%>%filter(!is.na(streets_join[,2]))

chull=chull(x=streets_join$x, y=streets_join$y)

plot(c(streets_join[,2], streets_join[,3]), cex=0.5, col=as.factor(streets_join$Borough))


 
