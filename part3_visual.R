library(dplyr)
library(data.table)
library(ggplot2)

#read in the nyc file
nyc = fread('/home/vis/cr173/Sta523/data/nyc/nyc_311.csv')

  
complaint.data=nyc%>%select(6, 25)%>%
  filter(!is.na(Borough))%>%
  group_by(Borough, Complaint.Type)%>%
  summarize(n())

names(complaint.data)=c("Borough", "Complaint.Type", "Occurences")

rodent.data=complaint.data%>%
  filter(Complaint.Type=="Rodent")
rodent.data=rodent.data[-1,]

noise.data=complaint.data%>%
  filter(Complaint.Type=="Noise")
noise.data=noise.data[-1,]

graffiti.data=complaint.data%>%
  filter(Complaint.Type=="Graffiti")
graffiti.data=graffiti.data[-1,]

Animals_in_park=complaint.data%>%
  filter(Complaint.Type=="Animal in a Park")
Animals_in_park=Animals_in_park[-1,]

Standing_Water=complaint.data%>%
  filter(Complaint.Type=="Standing Water")


plot(rodent.data$Occurences, col=as.factor(rodent.data$Borough), pch=1, xlab="Boroughs",
     ylab="Occurences", main="Occurences of Different Complaints in NYC",
     ylim=c(0, 70000))
points(noise.data$Occurences, col=as.factor(noise.data$Borough), pch=2)
points(graffiti.data$Occurences, col=as.factor(graffiti.data$Borough), pch=3)
points(Animals_in_park$Occurences,col=as.factor(Animals_in_park$Borough), pch=4)
points(Standing_Water$Occurences,col=as.factor(Standing_Water$Borough), pch=5)

