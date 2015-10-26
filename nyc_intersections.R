# JASON: setwd('C:/Users/Jason/Downloads')

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
packages_required = list('rvest', 'magrittr', 'stringr', 'plyr', 'ggplot2', 'data.table', 
                         'rgdal', 'dplyr')


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

# Create `data` subdirectory, if one does not already exist.
invisible(dir.create('data/'))

# Read in the specified columns of the NYC311 data set to a data frame called `nyc`.
keeper_columns = c('Unique.Key', 'Incident.Zip', 'Incident.Address', 'Street.Name', 'Cross.Street.1', 
                   'Cross.Street.2', 'Intersection.Street.1', 'Intersection.Street.2', 'Address.Type',
                   'Borough')
# JASON: nyc = fread('nyc_311.csv', select=keeper_columns, data.table=F)
nyc = fread('/home/vis/cr173/Sta523/data/nyc/nyc_311.csv', select=keeper_columns, data.table=F)

# Remove `nyc` rows with NEITHER $ZIP code NOR $Borough.
nyc = nyc[!(nyc$Incident.Zip=='' & nyc$Borough=='Unspecified'),]

# Remove `nyc` rows with non-empty $ZIP code values of less than 5 characters AND no assigned $Borough.
nyc = nyc[!(nyc$Incident.Zip!='' & nchar(nyc$Incident.Zip)<5 & nyc$Borough=='Unspecified'),]

# Extract the first 5 characters of all 9- and 10-character $ZIP code values, which are likely ZIP+4 values.
nyc$Incident.Zip[(nchar(nyc$Incident.Zip)>=9)] = nyc$Incident.Zip[(nchar(nyc$Incident.Zip)>=9)] %>% str_sub(end=5)

# Assign NAs to all $ZIP code values not containing exactly 5 digits.
nyc$Incident.Zip[!(str_detect(nyc$Incident.Zip, '^\\d{5}$'))] = NA

# Tabulate $Borough values by $ZIP code values.
borough_by_zip = table(nyc$Incident.Zip, nyc$Borough) %>% as.data.frame.matrix
borough_by_zip$zip = rownames(borough_by_zip)


# best_borough()
#############################################################################################
# Input: row, a partial row of a table.
#
# Output: either the name of the column which contains the maximum value in the row, or (if
#         all values in the row equal zero) the label "Unspecified".

best_borough = function(row) { 
  if(sum(row)>0) {
    return(names(row)[which.max(row)])
  } else {
    return('Unspecified')
  }
}

# For all non-NA $ZIP code values with at least one $Borough value, determine the most common such $Borough value,
# and reassign the $Borough value of corresponding entries in `nyc` accordingly.
borough_by_zip$Borough = apply(borough_by_zip[,1:5], 1, best_borough)
nyc$Borough[which(!(is.na(nyc$Incident.Zip)))] = match(nyc$Incident.Zip[which(!(is.na(nyc$Incident.Zip)))], borough_by_zip$zip) %>% 
  borough_by_zip$Borough[.]

# Remove `nyc` rows WITHOUT informative $Borough, $ZIP, or $Incident.Address values.
nyc = nyc[!(nyc$Borough=='Unspecified' & 
              is.na(nyc$Incident.Zip) &
              (is.na(nyc$Incident.Address) | 
                 str_detect(nyc$Incident.Address, 'UNKNOWN') |
                 str_detect(nyc$Incident.Address, 'UNKNWN') |
                 str_detect(nyc$Incident.Address, "DON'T KNOW") |
                 str_detect(nyc$Incident.Address, 'ANONYMOUS') |
                 str_detect(nyc$Incident.Address, 'REFUSED') |
                 str_detect(nyc$Incident.Address, '^X X') |
                 str_detect(nyc$Incident.Address, 'XXXX') |
                 str_detect(nyc$Incident.Address, 'OOOO') |
                 str_detect(nyc$Incident.Address, '^000') |
                 str_detect(nyc$Incident.Address, 'PO BOX') |
                 str_detect(nyc$Incident.Address, 'P.O. BOX') |
                 str_detect(nyc$Incident.Address, 'AIRPORT') |
                 str_detect(nyc$Incident.Address, 'JFK') |
                 str_detect(nyc$Incident.Address, 'NEWARK') |
                 str_detect(nyc$Incident.Address, 'N/A') |
                 str_detect(nyc$Incident.Address, 'NA NA') |
                 str_detect(nyc$Incident.Address, '[A-Z]')==F)),]

# Remove `nyc` rows which contain NAs for $Borough, $ZIP, AND $Incident.Address
nyc = nyc[!(is.na(nyc$Incident.Zip) & is.na(nyc$Incident.Address) & is.na(nyc$Borough)),]

# Subset `nyc`, keeping rows with EITHER a street and cross street, two intersection streets, 
# or an incident address.
street_cross = which((str_length(nyc$Street.Name)>0) & (str_length(nyc$Cross.Street.1)>0))
intersection = which((str_length(nyc$Intersection.Street.1)>0) & (str_length(nyc$Intersection.Street.2)>0))
has_address = which(str_length(nyc$Incident.Address)>0)
valid_rows = sort(unique(c(street_cross, intersection, has_address)))
nyc = nyc[valid_rows,]

# Download and clean CSV file containing US ZIP codes, cities, states, latitude, and longitude.
if(!file.exists('zip.csv')) {
  download.file(url='https://duke.box.com/shared/static/h9kqw77eho1pt6gwlb7v3ggery0dacrw.csv',
                destfile='zip.csv', quiet=T)
}
zip = suppressWarnings(readLines('zip.csv'))
zip = zip[(nchar(zip)>0)]
zip = str_split_fixed(zip, '\",\"', 6)
zip[,1] = str_sub(zip[,1], start=2L)
colnames(zip) = zip[1,]
zip = zip[-1,]
zip = as.data.frame(zip, stringsAsFactors=F)

# Subset `zip` to the New York rows, with columns for ZIP code, locale, latitude, and longitude.
boroughs = c('New York', 'Brooklyn', 'Bronx', 'Manhattan', 'Queens', 'Staten Island')
zip = zip[(zip$state=='NY' & zip$city %in% boroughs),]
zip = zip[,c(1,2,4,5)]
colnames(zip) = c('Incident.Zip', suppressWarnings(str_c('zip', colnames(zip)[2:4], sep='.')))
zip$zip.city = toupper(zip$zip.city)
zip$zip.city[(zip$zip.city=='NEW YORK')] = 'Unspecified'

# Merge the ZIP code-based latitude and longitude coordinates into `nyc`.
nyc = merge(nyc, zip, by='Incident.Zip', all.x=T)

# Clean up, retaining `nyc` data frame.
clean_but_keep('nyc')

# Read in `intersections` shapefile and extract the coordinates and attached data into `data`.
# JASON: inter = readOGR(paste0(getwd(), '/intersections'), 'intersections', stringsAsFactors=F)
inter = readOGR(paste0(path.expand('~cr173'), '/Sta523/data/nyc/intersections'), 
                'intersections', stringsAsFactors=F)
data = inter@data
data = cbind(data, coordinates(inter))

# Subset `data`, keeping rows with ONLY two non-boundary listings as streets.
to_keep = str_split(data$streets, ':') %>% 
  llply(function(x) { str_detect(x, 'BOUNDARY') %>% identical(c(F, F))} ) %>%
  unlist
data = data[to_keep,]

# Split these intersections into separate columns.
data = cbind.data.frame(data, str_split_fixed(data$streets, ':', 2), stringsAsFactors=F)

# Omit duplicate rows and unneeded columns.
data = distinct(data, streets)
data$streets = data$id = NULL

# Rename columns and sort by first and second streets. 
colnames(data) = c('longitude', 'latitude', 'street_1', 'street_2')
data = data[order(data$street_1, data$street_2),]


# standardize_streets()
#############################################################################################
# Input: col, a column in `data` data frame.
#
# Output: the same column, but with standardized address formatting.

standardize_streets = function(col) { 
  str_replace(col,  ' ST$', ' STREET') %>% 
    str_replace(' AVE$', ' AVENUE') %>%
    str_replace(' CT$', ' COURT') %>%
    str_replace(' BLVD$', ' BOULEVARD') %>%
    str_replace(' PL$', ' PLACE') %>%
    str_replace(' LN$', ' LANE') %>%
    str_replace(' RD$', ' ROAD') %>%
    str_replace(' CONC$', ' CONCOURSE') %>%
    str_replace(' EXPY$', ' EXPRESSWAY') %>%
    str_replace(' PKWY$', ' PARKWAY') %>%
    str_replace(' TER$', ' TERRACE') %>%
    str_replace(' BRG$', ' BRIDGE') %>%
    str_replace(' SQ$', ' SQUARE') %>%
    str_replace(' CIR$', ' CIRCLE') %>%
    str_replace(' TRL$', ' TRAIL') %>%
    str_replace(' CRES$', ' CRESCENT') %>%
    str_replace(' PLZ$', ' PLAZA') %>%
    str_replace(' N ', ' NORTH ') %>%
    str_replace(' S ', ' SOUTH ') %>%
    str_replace(' E ', ' EAST ') %>%
    str_replace(' W ', ' WEST ') %>%
    str_replace('^N ', 'NORTH ') %>%
    str_replace('^S ', 'SOUTH ') %>%
    str_replace('^E ', 'EAST ') %>%
    str_replace('^W ', 'WEST ')
}

# Standardize the addresses and street names in `data` to match `nyc`.
data[,3:4] = apply(data[,3:4], 2, standardize_streets)

# Clean up.
clean_but_keep(c('nyc', 'data'))

# Merge `nyc` and `data`, matching $Street.Name to $street_1 or $street_2 and 
# $Cross.Street.1 to $street_2 or $street_1.
p1 = merge(nyc, data, 
           by.x=c('Street.Name', 'Cross.Street.1'), 
           by.y=c('street_1', 'street_2'))
p2 = merge(nyc, data, 
           by.x=c('Street.Name', 'Cross.Street.1'), 
           by.y=c('street_2', 'street_1'))
h1 = rbind(p1, p2)

# Clean up.
clean_but_keep(c('nyc', 'data', 'h1'))

# Merge `nyc` and `data`, matching $Intersection.Street.1 to $street_1 or $street_2 and 
# $Intersection.Street.2 to $street_2 or $street_1.
p1 = merge(nyc, data, by.x=c('Intersection.Street.1', 'Intersection.Street.2'), by.y=c('street_1', 'street_2'))
p2 = merge(nyc, data, by.x=c('Intersection.Street.1', 'Intersection.Street.2'), by.y=c('street_2', 'street_1'))
h2 = rbind(p1, p2)

# Clean up.
clean_but_keep(c('nyc', 'data', 'h1', 'h2'))

# Merge `nyc` and `data` into data frame called `geocoded` and write to disk.
geocoded = rbind(h1, h2)

# Clean up.
clean_but_keep(c('nyc', 'data', 'geocoded'))

geocoded_unique = distinct(geocoded, Incident.Address)

nyc_map = ggplot(geocoded_unique, aes(x=longitude, y=latitude, color=Borough)) +
  geom_point(size=1, alpha=.5, shape=20) + 
  coord_map()
nyc_map
