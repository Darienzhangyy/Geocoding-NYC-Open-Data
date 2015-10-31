library(dplyr)
library(rgdal)


short_to_long = c("BK"="Brooklyn", 
                  "BX"="Bronx",
                  "MN"="Manhattan",
                  "QN"="Queens",
                  "SI"="Staten Island")

setwd("~/bootcamp/Team5_hw3")
load('with_null.RData')




## Create model
library(e1071)
library(raster)
library(rgeos)

r = raster(nrows=500, ncols=500,
           xmn=-74.3, xmx=-73.71,
           ymn=40.49, ymx=40.92)
r[]=NA


short_to_long = c("BK"="Brooklyn",
                  "BX"="Bronx",
                  "MN"="Manhattan",
                  "QN"="Queens",
                  "SI"="Staten Island")

sample.1=full_data[sample(1:nrow(full_data), 8000, replace=FALSE),]

SvmNyc <- svm(as.factor(knn) ~Longitude + Latitude, data = sample.1, cost= 20000, gamma=2)

## Create raster for prediction locations
r = raster(nrows=500, ncols=500, 
           xmn=-74.3, xmx=-73.71, 
           ymn=40.49, ymx=40.92)
r[]=NA

pred_locs = data.frame(xyFromCell(r, 1:250000))
names(pred_locs) = c("Longitude","Latitude")

pred = predict(SvmNyc,pred_locs)
r[] = pred


## Create Polygons

poly = rasterToPolygons(r,dissolve=TRUE)

names(poly@data) = "Name"
poly@data$Name = short_to_long[levels(pred)]

source("write_geojson.R")
write_geojson(poly,"boroughs.json")