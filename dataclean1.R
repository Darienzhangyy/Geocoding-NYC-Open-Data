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
#Load the pluto data
load(path.expand("/home/vis/cr173/Sta523/data/nyc/pluto/pluto.Rdata"))
str(pluto)

#keep the data in nyc, left joint pluto data
Join_Street = left_join(addr, pluto,by="Address")