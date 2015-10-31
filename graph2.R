# Clear the environment.
rm(list=ls())


# clean_but_keep()
#############################################################################################
# Input: objects, a character vector of objects to keep (NULL by default).
#
# Output: Nothing; all other objects are removed via rm() and gc().

clean_but_keep = function(objects=NULL) {
  rm(list=setdiff(ls(envir=globalenv()), c('clean_but_keep', objects)), envir=globalenv())
  invisible(gc())
}


# Create list of required packages.
packages_required = list('magrittr', 'stringr', 'plyr', 'ggplot2', 'data.table', 
                         'rgdal', 'dplyr', 'lubridate', 'foreign', 'class', 
                         'raster', 'e1071', 'rgeos')


# package_checker()
#############################################################################################
# Input: package, the name of a required R package.
#
# Output: Nothing; following installation if necessary, the package is loaded.

package_checker = function(package) {
  if(!(package %in% installed.packages()[,'Package'])) {
    install.packages(package, repos='http://cran.rstudio.com/') 
  }
  suppressPackageStartupMessages(library(package, character.only=T, quietly=T))
}

# Run package_checker to (if necessary, install, and) load packages.
invisible(lapply(packages_required, package_checker))

# Read in the NYC311 data set to a data frame called `nyc` and extract address column.
nyc = fread('/home/vis/cr173/Sta523/data/nyc/nyc_311.csv', data.table=F)
addr = nyc %>%
  select(contains('Incident.Address')) %>%
  filter(Incident.Address!='')
colnames(addr) = 'Address'

# Read in the Pluto data.
load(path.expand('/home/vis/cr173/Sta523/data/nyc/pluto/pluto.Rdata'))

# Merge Pluto and NYC data.
join_street = left_join(addr, pluto, by='Address')

# Remove rows without coordinates and average over identical addresses by borough.
clean_data = join_street %>%
  select(Address, x, y, Borough) %>%
  filter(!is.na(x)) %>%
  group_by(Address, Borough) %>%
  summarise(x=mean(x), y=mean(y))
colnames(clean_data)[3:4] = c('Longitude', 'Latitude')

# Clean up.
clean_but_keep('clean_data')

# Create raster grid for prediction locations.
r = raster(nrows=500, ncols=500, 
           xmn=-74.3, xmx=-73.6, 
           ymn=40.49, ymx=40.92)
r[] = NA
pred_locs = data.frame(xyFromCell(r, 1:250000))
names(pred_locs) = c('Longitude', 'Latitude')

# Construct vector to remap names.
short_to_long = c('BK'='Brooklyn',
                  'BX'='Bronx',
                  'MN'='Manhattan',
                  'QN'='Queens',
                  'SI'='Staten Island')

# Fit SVM and use to predict classification for `pred_locs` grid.
svm_fit = svm(as.factor(Borough) ~ Longitude + Latitude, data=clean_data, cost=28000, gamma=2)
pred = predict(svm_fit, pred_locs)

# Create spatial polygons from SVM output and write to disk as GEOJSON file.
r[] = pred
poly = rasterToPolygons(r, dissolve=T)
names(poly@data) = 'Name'
poly@data$Name = short_to_long[levels(pred)]
source('write_geojson.R')
write_geojson(poly, 'boroughs.json')