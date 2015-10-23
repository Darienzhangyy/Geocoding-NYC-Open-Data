library(dplyr)
library(data.table)
nyc=fread("/home/vis/cr173/Sta523/data/nyc/nyc_311.csv") %>% tbl_df()

summary(nyc)

library(foreign)

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
streets_join=full_join(streets,pluto, by="Address")
