load("with_null.RData")

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


Samp <- full_data[sample(1:nrow(full_data), 15000, replace=FALSE),]
#SVM
SvmNyc1 <- svm(as.factor(knn) ~ Longitude + Latitude, data = Samp,
               cost= 20000, gamma=2)




# make predictions
pred_locs = data.frame(xyFromCell(r, 1:250000))
names(pred_locs) = c("Longitude","Latitude")#match name in the svm model

pred = predict(SvmNyc1,pred_locs)
r[] = pred
plot(r)
## Create Polygons

library(rgeos)
poly = rasterToPolygons(r,dissolve=TRUE)



names(poly@data) = "Name"
poly@data$Name = levels(Samp$knn)

setwd("/home/grad/yz273/bootcamp/")
source("write_geojson.R")
write_geojson(poly,"boroughs.json")





##################
