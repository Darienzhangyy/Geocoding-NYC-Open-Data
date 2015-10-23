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
Join_Street_clean = Join_Street %>%
  filter(!is.na(x))

library(graphics)

plot(c(Join_Street_clean[,4],Join_Street_clean[,5]), cex = 0.5, col=as.factor(Join_Street_clean$Borough))

hpts1=chull(Join_Street_clean[which(Join_Street_clean[,7]=="BK"),4:5])
hpts1 <- c(hpts1, hpts1[1])
lines(Join_Street_clean[hpts1,4:5])

hpts2=chull(Join_Street_clean[which(Join_Street_clean[,7]=="QN"),4:5])
hpts2 <- c(hpts2, hpts2[1])
lines(Join_Street_clean[hpts2,4:5])
