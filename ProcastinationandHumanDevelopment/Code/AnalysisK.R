library(ggplot2)
library(maps)

#5c Generating Visualization of AIP by HDI

#Creating dataframe of HDI and AIPMean by Country
topfifteenAIP <- aggregate(tidydata18_67[, c("AIPMean", "HDI")], list(tidydata18_67$Country), mean, na.rm=TRUE) 
colnames(topfifteenAIP)<-c("Country", "AIPMean", "HDI")

#Reordering dataframe by AIPMean in Descending Order
topfifteenAIP <- topfifteen[order(-topfifteenAIP$AIPMean), ]
topfifteenAIP$HumanDev<- cut(topfifteenAIP$HDI, c(-Inf, 0.549, 0.699, 0.799, Inf))
levels(topfifteenAIP$HumanDev) <- c("Low human development", "Medium human development", 
                                 "High human development", "Very high human development")
topfifteenAIP2 <- topfifteenAIP[(1:15), ]
theme_update(plot.title = element_text(hjust = 0.5))
ggplot(topfifteenAIP2, aes(x = reorder(Country, AIPMean), y = AIPMean, fill = HumanDev)) + 
  geom_bar(stat = "identity", width = 0.5) + 
  ggtitle("Top Fifteen Countries for Adult Inventory of Procrastination (AIP) Mean") +
  labs(x = "Country", y = "AIP Mean") +
  coord_flip() +
  scale_fill_brewer(palette = "Dark2")

#5d Answering relationship of Age vs. Income
#Generate Scatterplot
ggplot(na.omit(tidydata18_67), aes(Age, AnnIncome, color = Gender)) + 
  geom_point(shape = 16, size = 5, show.legend = FALSE, alpha = 1) + 
  geom_smooth(method = 'lm', color = "red") + 
  ggtitle("Age vs. Annual Income by Gender") + labs(x = "Age", y = "AnnIncome")
cor(tidydata18_67$AnnIncome, tidydata18_67$Age, method = "pearson", use="na.or.complete")

#Generate Linear Model & Display Statistics
AgeIncome<-lm(AnnIncome~Age, data=na.omit(tidydata))

#Output Linear Model results
summary(AgeIncome)

#Importing map.world data into environment to circumvent knitr's issues about environmental datasets
localmap.world<-read.csv("map.world.csv", header=TRUE)

#Create new dataframe that contains Country and Means for each Procrastination Index used in Maps
newmap<-as.data.frame(unique(localmap.world$region))
colnames(newmap)<-c("Country")
HDI_Means<-aggregate(tidydata18_67[, c("GPMean", "DPMean", "AIPMean", "SWLSMean")], list(tidydata18_67$Country), mean, na.rm=TRUE)    #Creates a new object which stores the mean GP, DP, AIP, and SWLS by country
colnames(HDI_Means)<-c("Country","GPMean", "DPMean", "AIPMean", "SWLSMean")

mapdata<-merge(newmap, HDI_Means, by="Country", all.x=TRUE, all.y=TRUE)
mapdata$Country<-sort(mapdata$Country)

#Cleaning up Names to match necessary names in localmap.world (United States -> US, United Kingdom->UK, Antigua & Barbuda->Antigua) and removing duplicate rows
mapdata$Country[255]<-mapdata$Country[241]
mapdata$Country[254]<-mapdata$Country[237]
mapdata$Country[257]<-mapdata$Country[9]
mapdata<-mapdata[-c(9, 237, 241),]

#Generating Maps for AIPMean, GPMean, SWLSMean, and DPMean
aipmap<- ggplot(mapdata, aes(map_id=Country))+    #sets the data and the primary key to link map and data
  geom_map(aes(fill=AIPMean), map=localmap.world)+         #sets the fill value that will determine color and the geographic map data
  expand_limits(x=localmap.world$long, y=localmap.world$lat)+ #Sets the latitude and longitudinal extents
  #coord_map()+                        #Sets the base geographic projection (mercator in this case)
  coord_equal()+
  scale_x_continuous(breaks=NULL)+
  scale_y_continuous(breaks=NULL)+
  labs(x = "", y = "") +
  ggtitle("Mean Adult Inventory of Procrastination Scores (AIP) by Country") + # Sets the title of the map
  scale_fill_gradient(low = "antiquewhite", high = "darkred", space = "Lab", na.value = "gray80", guide=guide_colourbar(title.position="top", barwidth=10, title="AIPMean",  title.hjust=0.5))+     #contols legend elements such as color gradiant, colors for NA values, and the size of the legend bar
  theme(plot.title = element_text(lineheight=.8, face="bold"),legend.position=c(.15, .25),legend.direction="horizontal",panel.background=element_blank(), panel.border=element_rect(colour="Grey50", fill=NA, size=2))+   #Theme elements such as the border around the map plot, the position of map components like the legend
  borders(database="world", regions=".", fill=NA, colour="grey25", xlim=NULL, ylim=NULL)

gpmap<- ggplot(mapdata, aes(map_id=Country))+    #sets the data and the primary key to link map and data
  geom_map(aes(fill=GPMean), map=localmap.world)+         #sets the fill value that will determine color and the geographic map data
  expand_limits(x=localmap.world$long, y=localmap.world$lat)+ #Sets the latitude and longitudinal extents
  #coord_map()+                        #Sets the base geographic projection (mercator in this case)
  coord_equal()+
  scale_x_continuous(breaks=NULL)+
  scale_y_continuous(breaks=NULL)+
  labs(x = "", y = "") +
  ggtitle("Mean General Procrastination (GP) by Country") + # Sets the title of the map
  scale_fill_gradient(low = "antiquewhite", high = "navyblue", space = "Lab",na.value = "gray80", guide=guide_colourbar(title.position="top", barwidth=10, title="GPMean",  title.hjust=0.5))+     #contols legend elements such as color gradiant, colors for NA values, and the size of the legend bar
  theme(plot.title = element_text(lineheight=.8, face="bold"),legend.position=c(.15, .25),legend.direction="horizontal",panel.background=element_blank(), panel.border=element_rect(colour="Grey50", fill=NA, size=2))+   #Theme elements such as the border around the map plot, the position of map components like the legend
  borders(database="world", regions=".", fill=NA, colour="grey25", xlim=NULL, ylim=NULL)

dpmap<- ggplot(mapdata, aes(map_id=Country))+    #sets the data and the primary key to link map and data
  geom_map(aes(fill=DPMean), map=localmap.world)+         #sets the fill value that will determine color and the geographic map data
  expand_limits(x=localmap.world$long, y=localmap.world$lat)+ #Sets the latitude and longitudinal extents
  #coord_map()+                        #Sets the base geographic projection (mercator in this case)
  coord_equal()+
  scale_x_continuous(breaks=NULL)+
  scale_y_continuous(breaks=NULL)+
  labs(x = "", y = "") +
  ggtitle("Mean Decisional Procrastination (DP) by Country") + # Sets the title of the map
  scale_fill_gradient(low = "antiquewhite", high = "darkgreen", space = "Lab",na.value = "gray80", guide=guide_colourbar(title.position="top", barwidth=10, title="DPMean",  title.hjust=0.5))+     #contols legend elements such as color gradiant, colors for NA values, and the size of the legend bar
  theme(plot.title = element_text(lineheight=.8, face="bold"),legend.position=c(.15, .25),legend.direction="horizontal",panel.background=element_blank(), panel.border=element_rect(colour="Grey50", fill=NA, size=2))+   #Theme elements such as the border around the map plot, the position of map components like the legend
  borders(database="world", regions=".", fill=NA, colour="grey25", xlim=NULL, ylim=NULL)

swlsmap<- ggplot(mapdata, aes(map_id=Country))+    #sets the data and the primary key to link map and data
  geom_map(aes(fill=SWLSMean), map=localmap.world)+         #sets the fill value that will determine color and the geographic map data
  expand_limits(x=localmap.world$long, y=localmap.world$lat)+ #Sets the latitude and longitudinal extents
  #coord_map()+                        #Sets the base geographic projection (mercator in this case)
  coord_equal()+
  scale_x_continuous(breaks=NULL)+
  scale_y_continuous(breaks=NULL)+
  labs(x = "", y = "") +
  ggtitle("Mean Satisfaction of Life (SWLS) by Country") + # Sets the title of the map
  scale_fill_gradient(low = "antiquewhite", high = "darkorange4", space = "Lab",na.value = "gray80", guide=guide_colourbar(title.position="top", barwidth=10, title="SWLS",  title.hjust=0.5))+     #contols legend elements such as color gradiant, colors for NA values, and the size of the legend bar
  theme(plot.title = element_text(lineheight=.8, face="bold"),legend.position=c(.15, .25),legend.direction="horizontal",panel.background=element_blank(), panel.border=element_rect(colour="Grey50", fill=NA, size=2))+   #Theme elements such as the border around the map plot, the position of map components like the legend
  borders(database="world", regions=".", fill=NA, colour="grey25", xlim=NULL, ylim=NULL)

aipmap 
gpmap
dpmap
swlsmap