library(dplyr)
library(data.table)
library(lubridate)
library(stringr)
library(magrittr)
library(foreign)

nyc=fread("/home/vis/cr173/Sta523/data/nyc/nyc_311.csv")%>% 
  as.data.frame() %>%
  tbl_df()
#Transfer to sql file
#db = src_sqlite("~cr173/Sta523/data/nyc/nyc_311.sqlite", create = TRUE)
#nyc_sql = copy_to(db, nyc, temporary = FALSE)
#str(nyc_sql)
#get the address info
addr = nyc %>%
  select(contains("Address")) %>%
  filter(Incident.Address != "")
str(addr)
colnames(addr)[1]="Address"

load(path.expand("/home/vis/cr173/Sta523/data/nyc/pluto/pluto.Rdata"))
str(pluto)


Join_Street=left_join(addr, pluto,by="Address")
#delete rows with NA longtitude or latitude
#Addresses in the same boroughs, average long and lat
Join_Street_clean = Join_Street %>%
  select(Address,x,y,Borough)%>%
  filter(!is.na(x))%>%
  group_by(Address,Borough)%>%
  summarise(x=mean(x),y=mean(y))

library(graphics)

plot(c(Join_Street_clean[,3],Join_Street_clean[,4]), cex = 0.5, col=as.factor(Join_Street_clean$Borough))



############ SVM ############

library(e1071)
library(raster)

r = raster(nrows=500, ncols=500,
           xmn=-74.3, xmx=-73.71,
           ymn=40.49, ymx=40.92)
r[]=NA


short_to_long = c("BK"="Brooklyn",
                  "BX"="Bronx",
                  "MN"="Manhattan",
                  "QN"="Queens",
                  "SI"="Staten Island")



# sample from the data
Samp <- Join_Street_clean[sample(1:nrow(Join_Street_clean), 2000, replace=FALSE),]
test <- Join_Street_clean[sample(1:nrow(Join_Street_clean), 1000, replace=FALSE),]
#SVM
SvmNyc <- svm(as.factor(Borough) ~ x + y, data = Samp, cost= 28000, gamma=2)
SvmNyc1 <- svm(as.factor(Borough) ~ x + y, data = Join_Street_clean, cost= 28000, gamma=2)




# make predictions
pred_locs = data.frame(xyFromCell(r, 1:250000))
names(pred_locs) = c("x","y")#match name in the svm model

pred = predict(SvmNyc1,pred_locs)
r[] = pred
plot(r)
## Create Polygons

library(rgeos)
poly = rasterToPolygons(r,dissolve=TRUE)



names(poly@data) = "Name"
poly@data$Names = short_to_long[levels(pred)]

source("write_geojson.R")
write_geojson(poly,"boroughs.json")








##################

plot(c(Join_Street_clean[,3],Join_Street_clean[,4]), cex = 0.5, col=as.factor(Join_Street_clean$Borough))


mysample <- Join_Street_clean[sample(1:nrow(Join_Street_clean), 2000, replace=FALSE),]
num_Bor = as.numeric(as.factor(mysample$Borough))
SVM = svm(num_Bor  ~ x + y, data= mysample, cost= 8, gamma=2)



library(raster)
r = raster(nrows=500, ncols=500, 
           xmn=-74.3, xmx=-73.71, 
           ymn=40.49, ymx=40.92)
r[]=NA


pred_locs = data.frame(xyFromCell(r, 1:250000))

preds = predict(SVM, pred_locs)
r[] = preds
poly = rasterToPolygons(r,dissolve=TRUE)





hpts1=chull(Samp[which(Samp$Borough=="BK"),3:4])
hpts1 <- c(hpts1, hpts1[1])
lines(Samp[hpts1,3:4])

hpts2=chull(Join_Street_clean[which(Join_Street_clean$Borough=="QN"),3:4])
hpts2 <- c(hpts2, hpts2[1])
lines(Join_Street_clean[hpts2,4:5])
