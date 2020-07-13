#LOAD LIBRARIES
library(ggplot2)
library(dplyr)
library(formattable)
library(mgsub)
library(viridis)
options(scipen = 999)

#GET AND LAOD THE DATA

download.file(url="https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2", destfile = "StormData.csv.bz2", method="curl")
data = read.csv("StormData.csv.bz2")


#VIEW SUMMARY

str(data)
nrow(data) = nrow(data)

#DATA PRE-PROCESSING

#Select relevant columns
data =select(data,"BGN_DATE","EVTYPE","FATALITIES","INJURIES","PROPDMG","PROPDMGEXP","CROPDMG","CROPDMGEXP")

#Convert col names to lower case
names(data) = tolower(names(data))

#Encode crop and property exponents

levels(factor(data$propdmgexp))
data$propdmgexp[which(data$propdmgexp=="")] = 0
data$propdmgexp[which(data$propdmgexp=="+")] = 0
data$propdmgexp[data$propdmg>0] = mgsub(data$propdmgexp[data$propdmg>0] , c("-" ,"0" ,"2" ,"3" ,"4" ,"5" ,"6", "7","B","h", "H" ,"K" ,"m" ,"M") , replacement = c(0,1,100,1000,10^4,10^5,10^6,10^7,10^9,100,100,1000,10^6,10^6))

levels(factor(data$cropdmgexp))
data$cropdmgexp[which(data$cropdmgexp=="")]=0
data$cropdmgexp[data$cropdmg>0] = mgsub(data$cropdmgexp[data$cropdmg>0] , c("0" ,"B", "k", "K", "m", "M") , replacement = c(1,10^9,1000,1000,10^6,10^6))

#Reduce number of unique categories

#Tells us num of unique categories
length(unique(data$evtype)) 

#Slice out summaries from event type

data = slice(data , -(grep("^summary",data$evtype,ignore.case = TRUE)))

#Reduce number of categories to roughly those mentioned in the code book
events = c("Extreme Cold","^Cold/Wind Chill$","^cold$", "record cold", 
"sleet","lake-effect|lake effect","heavy snow","light snow|moderate snow","^snow$",
"^avalanche$" , "^blizzard$","^landslide$",
"coastal flood" , "flash flood","lakeshore","river","urban","^flood$",
"dense fog|^fog$","freezing fog",
"Astronomical Low Tide", "smoke",
"^excessive heat$","drought","^heat wav(e|es)$","^heat$",
"dust devil","dust storm",
"Frost/Freeze" , "^Funnel Cloud$",
"marine hail" , "^hail|TSTM WIND/HAIL",
"^heavy rai(n|ns)$" , "High Surf",
"^High win(d|ds)$","Marine High Wind ","hurricane|typhoon" ,
"^ice storm$",
"^lightnin(g|gs)$",
"^Strong Win(d|ds)$", "Marine strong wind",
"^rip curren(t|ts)$" , "seiche", "Storm Surge",
"^Thunderstorm Win(d|ds)$|^TSTM WIND$","Marine Thunderstorm Wind|MARINE TSTM WIND",
"^tornado$",
"Tropical Depression" , "tropical storm","^winter storm$",
"tsunami","waterspout","volcanic ash","wildfire","winter weather",
"wild/forest fire","^dry microburst$")

replacements = c("Extreme Cold","Cold/Wind Chill","Cold", "Record Cold", 
"Sleet","Lake-Effect snow","Heavy Snow","Light/Moderate Snow","Snow",
"Avalanche" , "Blizzard","Landslide",
"Coastal Flood" , "Flash Flood","Lakeshore flood","River flood","Urban Flood","Floods",
"Dense Fog","Freezing Fog",
"Astronomical Low Tide", "Smoke",
"Excessive Heat","Drought","Heat Wave","Heat",
"Dust Devil","Dust Storm",
"Frost/Freeze" , "Funnel Cloud",
"Marine Hail" , "Hail",
"Heavy Rain" , "High Surf",
"High Winds","Marine High Wind","Hurricane/Typhoon" ,
"Ice Storm",
"Lightning",
"Strong Winds", "Marine Strong Wind",
"Rip Current" , "Seiche", "Storm Surge",
"Thunderstorm Winds","Marine Thunderstorm Winds",
"Tornado",
"Tropical Depression" , "Tropical Storm","Winter Storm",
"Tsunami","Waterspout","Volcanic Ash","Wildfire","Winter Weather",
"Wildfire","Dry Microburst")

tidy.data = data.frame()
for(i in 1:length(events))
{
  indices = grep(events[i],data$evtype,ignore.case = TRUE)
  data$evtype[indices] = replacements[i]
  tidy.data = bind_rows(tidy.data,slice(data,indices))
}


#Percentage observations lost
((nrow(data) - nrow(tidy.data))/nrow(data))*100


#EXPLORATORY DATA ANALYSIS

#Analyzing impact of each event on human health

damage.to.health = aggregate(fatalities+injuries ~ evtype , data = tidy.data , FUN = sum)
colnames(damage.to.health)[2] = "affected"
damage.to.health = damage.to.health[order(damage.to.health$affected,decreasing = TRUE),]
 
ggplot(damage.to.health[1:10,] , aes(x = evtype , y = affected,fill = evtype)) + geom_bar(stat = "identity" ) + coord_flip() + labs(x = "Events\n\n" , y = "\n\nTotal Fatalities/Injuries") + theme(axis.text  = element_text(size = 12) , axis.title = element_text(size = 12, face = "bold"),legend.position = "none")  + scale_fill_viridis(discrete = TRUE,begin = 0.8,end=0.1)+ expand_limits(y = 100500)

row.names(damage.to.health)=NULL
formattable(damage.to.health[11:15,], align= c("l","c") , col = c("Event" , "Total Fatalities/Injuries") , list(`evtype` = formatter("span", style = ~ style(color = "cornflowerblue")) , `affected` = formatter("span", style = ~ style(color = "coral" , font.weight = "bold"))))

#Analyzing impact of each event on economy

tidy.data = mutate(tidy.data , actualpropertydamage = as.numeric(tidy.data$propdmg) * as.numeric(tidy.data$propdmgexp) , actualcropdamage = as.numeric(tidy.data$cropdmg) * as.numeric(tidy.data$cropdmgexp))

property = tidy.data[!is.na(tidy.data$actualpropertydamage),]
property = property[property$actualpropertydamage > 0,]
property = select(property , -c("cropdmg","cropdmgexp","actualcropdamage"))
property = aggregate(actualpropertydamage ~ evtype , data = property , FUN = sum)
property = mutate(property , percentdamage = (actualpropertydamage/sum(actualpropertydamage)) * 100)  
property = property[order(property$percentdamage , decreasing = TRUE),]

ggplot(property[1:10,] , aes(x = evtype , y = percentdamage,fill = evtype)) + geom_bar(stat = "identity" ) + coord_flip() + labs(x = "Events\n\n" , y = "\n\nPercent damage to property") + theme(axis.text  = element_text(size = 12) , axis.title = element_text(size = 12, face = "bold"),legend.position = "none")  + scale_fill_viridis(discrete = TRUE,begin = 0.8,end=0.1)


crops = tidy.data[!is.na(tidy.data$actualcropdamage),]
crops = crops[crops$actualcropdamage > 0,]
property = select(crops , -c("propdmg","propdmgexp","actualpropertydamage"))
crops = aggregate(actualcropdamage ~ evtype , data = crops , FUN = sum)
crops = mutate(crops , percentdamage = (actualcropdamage/sum(actualcropdamage)) * 100)  
crops = crops[order(crops$percentdamage , decreasing = TRUE),]

ggplot(crops[1:10,] , aes(x = evtype , y = percentdamage,fill = evtype)) + geom_bar(stat = "identity" ) + coord_flip() + labs(x = "Events\n\n" , y = "\n\nPercent damage to crops") + theme(axis.text  = element_text(size = 12) , axis.title = element_text(size = 12, face = "bold"),legend.position = "none")  + scale_fill_viridis(discrete = TRUE,begin = 0.1,end=0.8)
