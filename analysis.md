---
title: "**Analysing the impact of extreme weather events in the USA**"
author: "Pranavi Shekhar"
date: "11/07/2020"
output: 
  html_document: 
    keep_md: yes
    highlight: pygments
    theme: yeti
    toc: true
    toc_float: 
      smooth_scroll: false
    toc_depth: 4
    
editor_options: 
  chunk_output_type: console
---
 
<style type="text/css">

div #TOC li {
    list-style:none;
    background-image:none;
    background-repeat:none;
    background-position:0;
  
}
div #TOC
{
  position: fixed;
  left: 20px;
  
}
 
pre {
  max-height: 250px;
  overflow-y: auto;
}

pre[class] {
 overflow-x : auto;
}
 
body
{
    position: absolute;
    left:-70px;
    top:20px;
}
.main-container {
  max-width: 1500px !important;
}

.list-group-item.active, .list-group-item.active:focus, .list-group-item.active:hover {
    background-color: #4682B4;
}
</style>



 
## **Synopsis**

Storms and other severe weather events can cause both public health and economic problems for communities and municipalities. Many severe events can result in fatalities, injuries, and property damage, and preventing such outcomes to the extent possible is a key concern.

This project involves exploring the U.S. National Oceanic and Atmospheric Administration's (NOAA) storm database. This database tracks characteristics of major storms and weather events in the United States, including when and where they occur, as well as estimates of any fatalities, injuries, property and crop damage.The events in the database start in the year 1950 and end in November 2011.

## **1. Loading the relevant libraries**

Before starting anything, load the libraries to be used in the course of the analysis.  

***ggplot2*** is used for plotting and visualizing , ***dplyr*** for transforming and processing raw data and ***formattable*** for displaying tabular data.


```r
knitr::opts_chunk$set(cache = TRUE,comment = "")

library(ggplot2)
library(dplyr)
library(plotly)
library(mgsub)
library(viridis)
options(scipen = 999)
```

## **2. Getting and Loading the data**

The data for this assignment come in the form of a comma-separated-value file compressed via the bzip2 algorithm to reduce its size. The following code downloads the data and saves it in the current directory in the name *StormData.csv.bz2*, which can then be loaded into R.

A description of the data set can be found <b>[here](https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf)</b>


```r
download.file(url="https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2", destfile = "StormData.csv.bz2", method="curl")

#Load the data into R
data = read.csv("StormData.csv.bz2")
```

## **3. Understanding the data**

A basic summary of the data set can be viewed using the **str()** command in R


```r
str(data)
```

```
'data.frame':	902297 obs. of  37 variables:
 $ STATE__   : num  1 1 1 1 1 1 1 1 1 1 ...
 $ BGN_DATE  : chr  "4/18/1950 0:00:00" "4/18/1950 0:00:00" "2/20/1951 0:00:00" "6/8/1951 0:00:00" ...
 $ BGN_TIME  : chr  "0130" "0145" "1600" "0900" ...
 $ TIME_ZONE : chr  "CST" "CST" "CST" "CST" ...
 $ COUNTY    : num  97 3 57 89 43 77 9 123 125 57 ...
 $ COUNTYNAME: chr  "MOBILE" "BALDWIN" "FAYETTE" "MADISON" ...
 $ STATE     : chr  "AL" "AL" "AL" "AL" ...
 $ EVTYPE    : chr  "TORNADO" "TORNADO" "TORNADO" "TORNADO" ...
 $ BGN_RANGE : num  0 0 0 0 0 0 0 0 0 0 ...
 $ BGN_AZI   : chr  "" "" "" "" ...
 $ BGN_LOCATI: chr  "" "" "" "" ...
 $ END_DATE  : chr  "" "" "" "" ...
 $ END_TIME  : chr  "" "" "" "" ...
 $ COUNTY_END: num  0 0 0 0 0 0 0 0 0 0 ...
 $ COUNTYENDN: logi  NA NA NA NA NA NA ...
 $ END_RANGE : num  0 0 0 0 0 0 0 0 0 0 ...
 $ END_AZI   : chr  "" "" "" "" ...
 $ END_LOCATI: chr  "" "" "" "" ...
 $ LENGTH    : num  14 2 0.1 0 0 1.5 1.5 0 3.3 2.3 ...
 $ WIDTH     : num  100 150 123 100 150 177 33 33 100 100 ...
 $ F         : int  3 2 2 2 2 2 2 1 3 3 ...
 $ MAG       : num  0 0 0 0 0 0 0 0 0 0 ...
 $ FATALITIES: num  0 0 0 0 0 0 0 0 1 0 ...
 $ INJURIES  : num  15 0 2 2 2 6 1 0 14 0 ...
 $ PROPDMG   : num  25 2.5 25 2.5 2.5 2.5 2.5 2.5 25 25 ...
 $ PROPDMGEXP: chr  "K" "K" "K" "K" ...
 $ CROPDMG   : num  0 0 0 0 0 0 0 0 0 0 ...
 $ CROPDMGEXP: chr  "" "" "" "" ...
 $ WFO       : chr  "" "" "" "" ...
 $ STATEOFFIC: chr  "" "" "" "" ...
 $ ZONENAMES : chr  "" "" "" "" ...
 $ LATITUDE  : num  3040 3042 3340 3458 3412 ...
 $ LONGITUDE : num  8812 8755 8742 8626 8642 ...
 $ LATITUDE_E: num  3051 0 0 0 0 ...
 $ LONGITUDE_: num  8806 0 0 0 0 ...
 $ REMARKS   : chr  "" "" "" "" ...
 $ REFNUM    : num  1 2 3 4 5 6 7 8 9 10 ...
```

```r
# Store the total number of observations, for future use
totalobservations = nrow(data)
```

It can be observed that there are **37 measurements** taken, for each row/observation. Details regarding what each variable represents can be found in the documentation.  

However, we are interested only in learning about the fatalities and injuries caused by each weather event, and its economic impact.  

*Therefore, the columns relevant to us are only the date of event - *<span style="color : steelblue;">**BGN_DATE**</span>*, type of event - *<span style="color : steelblue;">**EVTYPE**</span>*, fatalities - *<span style="color : steelblue;">**FATALITIES**</span>*, injuries - *<span style="color : steelblue;">**INJURIES**</span>*, property and crop damage - *<span style="color : steelblue;">**PROPDMG**</span>*, *<span style="color : steelblue;">**PROPDMGEXP**</span>*, *<span style="color : steelblue;">**CROPDMG**</span>*, *<span style="color : steelblue;">**CROPDMGEXP**</span>

## **4. Data Pre-Processing**

In this section, we will clean and process the data to ensure that it is in a format suited to our objective. We will decide on the attributes to retain for analysis and re-encode categorical variables to make them consistent.<br>

### **4.1. Basic changes**

The first step is to keep only the relevant columns, as described in the previous section. The **select()** command of ***dplyr*** can be used to pick the desired columns.


```r
data = select(data,"BGN_DATE","EVTYPE","FATALITIES","INJURIES","PROPDMG","PROPDMGEXP","CROPDMG","CROPDMGEXP")
```

The column names are then converted to lower case, for easy usage and standard representation.


```r
names(data) = tolower(names(data))

#View changed data

str(data)
```

```
'data.frame':	902297 obs. of  8 variables:
 $ bgn_date  : chr  "4/18/1950 0:00:00" "4/18/1950 0:00:00" "2/20/1951 0:00:00" "6/8/1951 0:00:00" ...
 $ evtype    : chr  "TORNADO" "TORNADO" "TORNADO" "TORNADO" ...
 $ fatalities: num  0 0 0 0 0 0 0 0 1 0 ...
 $ injuries  : num  15 0 2 2 2 6 1 0 14 0 ...
 $ propdmg   : num  25 2.5 25 2.5 2.5 2.5 2.5 2.5 25 25 ...
 $ propdmgexp: chr  "K" "K" "K" "K" ...
 $ cropdmg   : num  0 0 0 0 0 0 0 0 0 0 ...
 $ cropdmgexp: chr  "" "" "" "" ...
```


### **4.2. Re-Encoding exponents**

The columns ***propdmgexp*** and ***cropdmgexp*** represent the exponent(value to which 10 needs to be raised / power).   
***propdmg*** and ***cropdmg*** contain the damage in $(called the *mantissa*), after being stripped of zeroes.  

*Hence, to obtain the true monetary value of the damage caused, the corresponding exponent and mantissa observations must be multiplied.*

To understand this, the different types of exponents present in ***propdmgexp*** and ***cropdmgexp*** can be viewed by representing them as factors.   
This will enable us to view the different categories of exponents, by using  **levels()**


```r
levels(factor(data$propdmgexp))
```

```
 [1] ""  "-" "?" "+" "0" "1" "2" "3" "4" "5" "6" "7" "8" "B" "h" "H" "K" "m" "M"
```

```r
levels(factor(data$cropdmgexp))
```

```
[1] ""  "?" "0" "2" "B" "k" "K" "m" "M"
```

The output tells us that the exponents may be numerical i.e. **1,2,3...** to represent the power of ten, or a character **H/K/M/B** to represent 100/1000/1000000/1000000000 respectively (K=thousand , M=Million, B=Billion). Anything else is taken to be 0. 

For analyzing damages we need actual/true monetary values. So, the exponents must be converted to their expanded values/products of 10.   

**Example :** If ***propdmgexp*** is 3/K then we replace it with 1000. Similarly, M/m/6 is encoded as 10^6 = 1000000

This is achieved by using a vector substitution function **mgsub()**



```r
#Re-encode property damage exponents

data$propdmgexp[which(data$propdmgexp=="")] = 0
data$propdmgexp[which(data$propdmgexp=="+")] = 0
data$propdmgexp[data$propdmg>0] = mgsub(data$propdmgexp[data$propdmg>0] , c("-" ,"0" ,"2" ,"3" ,"4" ,"5" ,"6", "7","B","h", "H" ,"K" ,"m" ,"M") , replacement = c(0,1,100,1000,10^4,10^5,10^6,10^7,10^9,100,100,1000,10^6,10^6))

#Re-encode crop damage exponents

data$cropdmgexp[which(data$cropdmgexp=="")]=0
data$cropdmgexp[data$cropdmg>0] = mgsub(data$cropdmgexp[data$cropdmg>0] , c("0" ,"B", "k", "K", "m", "M") , replacement = c(1,10^9,1000,1000,10^6,10^6))
```

We only re-encode exponents having mantissas greater than 0 since zero damage has no relevance to the analysis and substitution time can be significantly minimized by omitting them.
<br>

### **4.3. Reducing the number of unique event types**

According to the data set's documentation, there are 48 official event types.       

However, the data itself contains many variations and representations of the official event names, leading to a large number of categories, as shown below.


```r
length(unique(data$evtype))
```

```
[1] 985
```

There are a whopping 985 categories of events! To determine whether each category is truly unique, we can take the event *Cold* as an example.


```r
levels(factor(data$evtype[grep("cold" , data$evtype,ignore.case = TRUE)]))
```

```
 [1] "Cold"                         "COLD"                        
 [3] "COLD AIR FUNNEL"              "COLD AIR FUNNELS"            
 [5] "COLD AIR TORNADO"             "Cold and Frost"              
 [7] "COLD AND FROST"               "COLD AND SNOW"               
 [9] "COLD AND WET CONDITIONS"      "Cold Temperature"            
[11] "COLD TEMPERATURES"            "COLD WAVE"                   
[13] "COLD WEATHER"                 "COLD WIND CHILL TEMPERATURES"
[15] "COLD/WIND CHILL"              "COLD/WINDS"                  
[17] "Excessive Cold"               "Extended Cold"               
[19] "Extreme Cold"                 "EXTREME COLD"                
[21] "EXTREME COLD/WIND CHILL"      "EXTREME/RECORD COLD"         
[23] "FOG AND COLD TEMPERATURES"    "HIGH WINDS/COLD"             
[25] "Prolong Cold"                 "PROLONG COLD"                
[27] "PROLONG COLD/SNOW"            "RECORD  COLD"                
[29] "Record Cold"                  "RECORD COLD"                 
[31] "RECORD COLD AND HIGH WIND"    "RECORD COLD/FROST"           
[33] "RECORD SNOW/COLD"             "SEVERE COLD"                 
[35] "SNOW AND COLD"                "SNOW/ BITTER COLD"           
[37] "SNOW/COLD"                    "SNOW\\COLD"                  
[39] "Unseasonable Cold"            "UNSEASONABLY COLD"           
[41] "UNUSUALLY COLD"              
```

R will perceive *each* of these as a unique/different category. But according to the documentation, there are only 3 events associated with the cold namely *Cold*,*Cold/Wind Chill* and *Extreme Cold/Wind chill*. All the others are different variations of the same and some others (such as *Snow*) belong in entirely different categories. R considers even the same category name with different capital/small letters as 2 unique categories.

Thus, there are several duplicates of the variables of the same group and cross-category variables, giving rise to a large number of overall categories. Since our entire analysis revolves around grouping variables by event, this could lead to extremely erroneous interpretations.  

*Therefore, the categories need to be condensed in accordance with the official documentation i.e. 985 categories need to be reduced to approximately 48, while accounting for any original categories, unspecified in the code book, that crop up.*

To do this, we first tabulate the frequency of occurrence of each categorical duplicate. Again *Cold* is taken as an example.


```r
table(data$evtype[grep("cold" , data$evtype,ignore.case = TRUE)])
```

```

                        Cold                         COLD 
                          10                           72 
             COLD AIR FUNNEL             COLD AIR FUNNELS 
                           4                            2 
            COLD AIR TORNADO               Cold and Frost 
                           1                            6 
              COLD AND FROST                COLD AND SNOW 
                           1                            1 
     COLD AND WET CONDITIONS             Cold Temperature 
                           1                            2 
           COLD TEMPERATURES                    COLD WAVE 
                           4                            3 
                COLD WEATHER COLD WIND CHILL TEMPERATURES 
                           4                            6 
             COLD/WIND CHILL                   COLD/WINDS 
                         539                            1 
              Excessive Cold                Extended Cold 
                           2                            1 
                Extreme Cold                 EXTREME COLD 
                           2                          655 
     EXTREME COLD/WIND CHILL          EXTREME/RECORD COLD 
                        1002                            4 
   FOG AND COLD TEMPERATURES              HIGH WINDS/COLD 
                           1                            5 
                Prolong Cold                 PROLONG COLD 
                           5                           17 
           PROLONG COLD/SNOW                 RECORD  COLD 
                           1                            1 
                 Record Cold                  RECORD COLD 
                           3                           64 
   RECORD COLD AND HIGH WIND            RECORD COLD/FROST 
                           1                            2 
            RECORD SNOW/COLD                  SEVERE COLD 
                           1                            1 
               SNOW AND COLD            SNOW/ BITTER COLD 
                           2                            1 
                   SNOW/COLD                   SNOW\\COLD 
                           2                            1 
           Unseasonable Cold            UNSEASONABLY COLD 
                           1                           23 
              UNUSUALLY COLD 
                           8 
```

The output depicts that 72 observations were recorded as *COLD* , 539 as *COLD/WINDCHILL* and 1002 as *EXTREME COLD/WIND CHILL*. The only other category with a significant number of observations, not specified int the documentation, is *RECORD COLD*. All the others are negligible.   

Since searching for every variation of an event name would be quite cumbersome, we will use regular expressions identify those categories which have maximum entries (and thus, more significance) and omit the rest (The event name to be searched for is derived from the documentation). The table above is used to identify what pattern to use in **grep()**, so as to cover maximum number of entries.

In our example, the first pattern will be *extreme cold*, with ignore.case set to *TRUE*. This will return indices of all entries containing *extreme cold*, regardless of case. Then we can re-encode all these as *Extreme Cold/Wind Chill*, in accordance with the documentation. 

This process is repeated for all 48 official categories, by taking a look at the frequency table for each, identifying search patterns and then re-encoding. If the results indicate any new majority, unspecified in the documentation, these are also considered. We also need to slice out summary variables from *evtype* using **slice()**.Further, we only consider those events in our data that are recognized by our documentation-inspired search patterns. The rest are omitted.


```r
data = slice(data , -(grep("^summary",data$evtype,ignore.case = TRUE)))

# Create a vector of all grep search patterns. These are obtained from manual 
# tabulations of each category followed by identifying the maximum (not shown here).

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

# Create a vector to specify what category should replace the one being searched for # in events, at the corresponding index.
# For instance, if events[1] is encountered, we replace it with replacements[1]

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

# Store the final, re-encoded data set in tidy.data
tidy.data = data.frame()

for(i in 1:length(events))
{
  indices = grep(events[i],data$evtype,ignore.case = TRUE)
  data$evtype[indices] = replacements[i]
  tidy.data = bind_rows(tidy.data,slice(data,indices))
}
```

**tidy.data** contains the data set after processing. Let us observe the number of unique categories and the number of observations lost/omitted during conversion.


```r
# Number of unique categories in tidy data set
length(unique(tidy.data$evtype))
```

```
[1] 55
```

```r
# Percentage loss of data

((totalobservations - nrow(tidy.data))/totalobservations)*100
```

```
[1] 0.5001679
```

We can see that the number of unique categories has been reduced to 55. This is more than the number of categories in the official documentation(48), but it ensures that we have not left out any major ones. 

It can be observed that in the process of reduction we have lost only 0.5% of the data or around 4400 observations. This is acceptable, considering the size of the data set.

## **5. Results / Exploratory Data analysis**

In this section, we aim to plot the tidy data and observe the results to answer the following questions : 

1. Across the United States, which types of events are most harmful with respect to population health?
2. Across the United States, which types of events have the greatest economic consequences?
<br>

### **5.1. Events most harmful to human health**

To determine the impact of extreme weather events on human health we need to take stock of the number of fatalities and injuries caused by each. This is achieved using **aggregate()**


```r
damage.to.health = aggregate(fatalities+injuries ~ evtype , data = tidy.data , FUN = sum)
colnames(damage.to.health)[2] = "affected"
damage.to.health = damage.to.health[order(damage.to.health$affected,decreasing = TRUE),]
row.names(damage.to.health)=NULL
head(damage.to.health,2)
```

```
              evtype affected
1            Tornado    96979
2 Thunderstorm Winds    10054
```

```r
nrow(damage.to.health)
```

```
[1] 55
```

**damage.to.health** contains the sum of fatalities and injuries caused by each event, in order of most damaging to least. Since we have 55 events, this matches the number of rows produced. We can now plot the data and observe the top 10 events that affect people the most.


```r
d=ggplot(damage.to.health[1:10,] , aes(x = evtype , y = affected,fill = evtype)) + geom_bar(stat = "identity" ) + coord_flip() + labs(x = "Events\n\n" , y = "\n\nTotal Fatalities/Injuries") + theme(axis.text  = element_text(size = 12) , axis.title = element_text(size = 12, face = "bold"),legend.position = "none")  + scale_fill_viridis(discrete = TRUE,begin = 0.8,end=0.1)+expand_limits(y = 100500)
ggplotly(d)
```

<div class="figure" style="text-align: left">
<!--html_preserve--><div id="htmlwidget-2e922d6e28f823e548a6" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-2e922d6e28f823e548a6">{"x":{"data":[{"orientation":"h","width":0.9,"base":0,"x":[8428],"y":[1],"text":"evtype: Excessive Heat<br />affected:  8428<br />evtype: Excessive Heat","type":"bar","marker":{"autocolorscale":false,"color":"rgba(122,209,81,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Excessive Heat","legendgroup":"Excessive Heat","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[2837],"y":[2],"text":"evtype: Flash Flood<br />affected:  2837<br />evtype: Flash Flood","type":"bar","marker":{"autocolorscale":false,"color":"rgba(78,195,107,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Flash Flood","legendgroup":"Flash Flood","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[7259],"y":[3],"text":"evtype: Floods<br />affected:  7259<br />evtype: Floods","type":"bar","marker":{"autocolorscale":false,"color":"rgba(45,178,125,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Floods","legendgroup":"Floods","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[3037],"y":[4],"text":"evtype: Heat<br />affected:  3037<br />evtype: Heat","type":"bar","marker":{"autocolorscale":false,"color":"rgba(31,161,136,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Heat","legendgroup":"Heat","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[1722],"y":[5],"text":"evtype: High Winds<br />affected:  1722<br />evtype: High Winds","type":"bar","marker":{"autocolorscale":false,"color":"rgba(33,142,141,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"High Winds","legendgroup":"High Winds","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[2064],"y":[6],"text":"evtype: Ice Storm<br />affected:  2064<br />evtype: Ice Storm","type":"bar","marker":{"autocolorscale":false,"color":"rgba(41,123,142,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Ice Storm","legendgroup":"Ice Storm","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[6046],"y":[7],"text":"evtype: Lightning<br />affected:  6046<br />evtype: Lightning","type":"bar","marker":{"autocolorscale":false,"color":"rgba(49,104,142,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Lightning","legendgroup":"Lightning","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.899999999999999,"base":0,"x":[10054],"y":[8],"text":"evtype: Thunderstorm Winds<br />affected: 10054<br />evtype: Thunderstorm Winds","type":"bar","marker":{"autocolorscale":false,"color":"rgba(58,83,139,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Thunderstorm Winds","legendgroup":"Thunderstorm Winds","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.899999999999999,"base":0,"x":[96979],"y":[9],"text":"evtype: Tornado<br />affected: 96979<br />evtype: Tornado","type":"bar","marker":{"autocolorscale":false,"color":"rgba(67,61,132,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Tornado","legendgroup":"Tornado","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.899999999999999,"base":0,"x":[1543],"y":[10],"text":"evtype: Wildfire<br />affected:  1543<br />evtype: Wildfire","type":"bar","marker":{"autocolorscale":false,"color":"rgba(72,37,118,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Wildfire","legendgroup":"Wildfire","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"visible":false,"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","x":[null],"y":[null],"frame":null}],"layout":{"margin":{"t":26.2283105022831,"r":7.30593607305936,"b":45.7617268576173,"l":170.361145703611},"plot_bgcolor":"rgba(235,235,235,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-5025,105525],"tickmode":"array","ticktext":["0","25000","50000","75000","100000"],"tickvals":[0,25000,50000,75000,100000],"categoryorder":"array","categoryarray":["0","25000","50000","75000","100000"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":15.9402241594022},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(255,255,255,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"y","title":{"text":"<b> <br /><br />Total Fatalities/Injuries <\/b>","font":{"color":"rgba(0,0,0,1)","family":"","size":15.9402241594022}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.4,10.6],"tickmode":"array","ticktext":["Excessive Heat","Flash Flood","Floods","Heat","High Winds","Ice Storm","Lightning","Thunderstorm Winds","Tornado","Wildfire"],"tickvals":[1,2,3,4,5,6,7,8,9,10],"categoryorder":"array","categoryarray":["Excessive Heat","Flash Flood","Floods","Heat","High Winds","Ice Storm","Lightning","Thunderstorm Winds","Tornado","Wildfire"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":15.9402241594022},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(255,255,255,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"x","title":{"text":"<b> Events<br /><br /> <\/b>","font":{"color":"rgba(0,0,0,1)","family":"","size":15.9402241594022}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.689497716895}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","showSendToCloud":false},"source":"A","attrs":{"10e475043bed":{"x":{},"y":{},"fill":{},"type":"bar"},"10e47d361c68":{"y":{}}},"cur_data":"10e475043bed","visdat":{"10e475043bed":["function (y) ","x"],"10e47d361c68":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->
<p class="caption">The above plot shows the total number of fatalities and injuries caused by extreme weather events in the USA from 1950-2011. Only the top 10 events most affecting human health have been plotted.</p>
</div>

*From the plot, it is clear that* ***Tornadoes*** *have the maximum impact on human lives, followed by* ***Thunderstorm Winds****,* ***Excessive Heat*** *and* ***Floods***. ***Tornadoes*** *alone cause almost thrice the amount of damage as the remaining three put together.*
<br>

### **5.2. Events with the greatest economic consequences**

To assess the economic impact caused by the events, we need to determine the cost incurred by the resulting property and crop damage. While re-encoding the exponents we have already seen that *to obtain the true monetary value of the damage caused, the corresponding exponent and mantissa observations must be multiplied.*

This basically means that each entry in ***propdmg*** must be multiplied with the corresponding entry in ***propdmgexp*** and stored in a separate column. The same applies to crop damage as well. We can use **mutate()** to do this.


```r
tidy.data = mutate(tidy.data , actualpropertydamage = as.numeric(tidy.data$propdmg) * as.numeric(tidy.data$propdmgexp) , actualcropdamage = as.numeric(tidy.data$cropdmg) * as.numeric(tidy.data$cropdmgexp))
```

```
Warning: Problem with `mutate()` input `actualpropertydamage`.
i NAs introduced by coercion
i Input `actualpropertydamage` is `as.numeric(tidy.data$propdmg) * as.numeric(tidy.data$propdmgexp)`.
```

```
Warning in mask$eval_all_mutate(dots[[i]]): NAs introduced by coercion
```

```
Warning: Problem with `mutate()` input `actualcropdamage`.
i NAs introduced by coercion
i Input `actualcropdamage` is `as.numeric(tidy.data$cropdmg) * as.numeric(tidy.data$cropdmgexp)`.
```

```
Warning in mask$eval_all_mutate(dots[[i]]): NAs introduced by coercion
```

There are some NA values introduced because we did not re-encode the exponents of mantissas=0 and many of these were character variables - leading to NA values when coerced into numeric formats for multiplication. We can omit these during analysis since they do not contribute to the event sums in any way.<br><br>

#### **5.2.1. Assessing Property Damage**

To estimate property damage, we first isolate the relevant data from **tidy.data**. This includes omitting NA values and extracting only property data (leaving crop data).


```r
property = tidy.data[!is.na(tidy.data$actualpropertydamage),]
property = property[property$actualpropertydamage > 0,]
property = select(property , -c("cropdmg","cropdmgexp","actualcropdamage","bgn_date"))
head(property , 5)
```

```
         evtype fatalities injuries propdmg propdmgexp actualpropertydamage
5  Extreme Cold          3        0       5    1000000              5000000
6  Extreme Cold          1        0     500       1000               500000
7  Extreme Cold          0        0     500       1000               500000
9  Extreme Cold          0        0      25    1000000             25000000
15 Extreme Cold          0       15       5    1000000              5000000
```

**property** contains the cost of property damage without any NA values and all values of damage costs greater than 0(damage costs are in the column *actualpropertydamage*). Only property values have been retained.

We need to determine total property damage caused by each event. This calls for **aggregate()** with a summing function to compute total damage per event. Further, the impact of each event can be represented as a percentage, for easy interpretability.


```r
property = aggregate(actualpropertydamage ~ evtype , data = property , FUN = sum)
property = mutate(property , percentdamage = (actualpropertydamage/sum(actualpropertydamage)) * 100)  
property = property[order(property$percentdamage , decreasing = TRUE),]
head(property,5)
```

```
              evtype actualpropertydamage percentdamage
15            Floods         144657709807      34.30276
26 Hurricane/Typhoon          85356410010      20.24061
46           Tornado          56947380677      13.50396
43       Storm Surge          47964724000      11.37390
14       Flash Flood          17588792096       4.17084
```

**property** is arranged in descending order of damage, to capture the 10 most damaging events. This is depicted in the plot below.


```r
p = ggplot(property[1:10,] , aes(x = evtype , y = percentdamage,fill = evtype)) + geom_bar(stat = "identity" ) + coord_flip() + labs(x = "Events\n\n" , y = "\n\nPercentage damage to property") + theme(axis.text  = element_text(size = 12) , axis.title = element_text(size = 12, face = "bold"),legend.position = "none")  + scale_fill_viridis(discrete = TRUE,begin = 0.8,end=0.1)
ggplotly(p)
```

<!--html_preserve--><div id="htmlwidget-b5927234e9c70e8df5b2" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-b5927234e9c70e8df5b2">{"x":{"data":[{"orientation":"h","width":0.9,"base":0,"x":[4.17083961669399],"y":[1],"text":"evtype: Flash Flood<br />percentdamage:  4.170840<br />evtype: Flash Flood","type":"bar","marker":{"autocolorscale":false,"color":"rgba(122,209,81,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Flash Flood","legendgroup":"Flash Flood","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[34.3027596001636],"y":[2],"text":"evtype: Floods<br />percentdamage: 34.302760<br />evtype: Floods","type":"bar","marker":{"autocolorscale":false,"color":"rgba(78,195,107,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Floods","legendgroup":"Floods","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[3.79925925549341],"y":[3],"text":"evtype: Hail<br />percentdamage:  3.799259<br />evtype: Hail","type":"bar","marker":{"autocolorscale":false,"color":"rgba(45,178,125,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Hail","legendgroup":"Hail","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[20.2406108655561],"y":[4],"text":"evtype: Hurricane/Typhoon<br />percentdamage: 20.240611<br />evtype: Hurricane/Typhoon","type":"bar","marker":{"autocolorscale":false,"color":"rgba(31,161,136,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Hurricane/Typhoon","legendgroup":"Hurricane/Typhoon","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[11.3739004914108],"y":[5],"text":"evtype: Storm Surge<br />percentdamage: 11.373900<br />evtype: Storm Surge","type":"bar","marker":{"autocolorscale":false,"color":"rgba(33,142,141,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Storm Surge","legendgroup":"Storm Surge","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[2.35059713788977],"y":[6],"text":"evtype: Thunderstorm Winds<br />percentdamage:  2.350597<br />evtype: Thunderstorm Winds","type":"bar","marker":{"autocolorscale":false,"color":"rgba(41,123,142,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Thunderstorm Winds","legendgroup":"Thunderstorm Winds","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[13.5039626426496],"y":[7],"text":"evtype: Tornado<br />percentdamage: 13.503963<br />evtype: Tornado","type":"bar","marker":{"autocolorscale":false,"color":"rgba(49,104,142,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Tornado","legendgroup":"Tornado","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.899999999999999,"base":0,"x":[1.82931753068317],"y":[8],"text":"evtype: Tropical Storm<br />percentdamage:  1.829318<br />evtype: Tropical Storm","type":"bar","marker":{"autocolorscale":false,"color":"rgba(58,83,139,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Tropical Storm","legendgroup":"Tropical Storm","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.899999999999999,"base":0,"x":[1.86561580066231],"y":[9],"text":"evtype: Wildfire<br />percentdamage:  1.865616<br />evtype: Wildfire","type":"bar","marker":{"autocolorscale":false,"color":"rgba(67,61,132,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Wildfire","legendgroup":"Wildfire","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.899999999999999,"base":0,"x":[1.58604690751371],"y":[10],"text":"evtype: Winter Storm<br />percentdamage:  1.586047<br />evtype: Winter Storm","type":"bar","marker":{"autocolorscale":false,"color":"rgba(72,37,118,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Winter Storm","legendgroup":"Winter Storm","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.2283105022831,"r":7.30593607305936,"b":45.7617268576173,"l":170.361145703611},"plot_bgcolor":"rgba(235,235,235,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-1.71513798000818,36.0178975801718],"tickmode":"array","ticktext":["0","10","20","30"],"tickvals":[0,10,20,30],"categoryorder":"array","categoryarray":["0","10","20","30"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":15.9402241594022},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(255,255,255,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"y","title":{"text":"<b> <br /><br />Percentage damage to property <\/b>","font":{"color":"rgba(0,0,0,1)","family":"","size":15.9402241594022}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.4,10.6],"tickmode":"array","ticktext":["Flash Flood","Floods","Hail","Hurricane/Typhoon","Storm Surge","Thunderstorm Winds","Tornado","Tropical Storm","Wildfire","Winter Storm"],"tickvals":[1,2,3,4,5,6,7,8,9,10],"categoryorder":"array","categoryarray":["Flash Flood","Floods","Hail","Hurricane/Typhoon","Storm Surge","Thunderstorm Winds","Tornado","Tropical Storm","Wildfire","Winter Storm"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":15.9402241594022},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(255,255,255,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"x","title":{"text":"<b> Events<br /><br /> <\/b>","font":{"color":"rgba(0,0,0,1)","family":"","size":15.9402241594022}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.689497716895}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","showSendToCloud":false},"source":"A","attrs":{"10e447091423":{"x":{},"y":{},"fill":{},"type":"bar"}},"cur_data":"10e447091423","visdat":{"10e447091423":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

The above plot depicts the 10 most damaging weather events with respect to cost of property damage.

*From the plot it is evident that* ***Floods*** *account for maximum property damage, followed quite closely by* ***Hurricanes***,***Storm Surges*** *and* ***Tornadoes***. <br><br>

#### **5.2.2. Assessing Crop Damage**

The methods employed to calculate event-wise cost of damaged crops follows the same pattern as property damage estimation - isolate applicable crop damage values from the tidy data, aggregate by event, order and then plot. The code below covers the same.


```r
crops = tidy.data[!is.na(tidy.data$actualcropdamage),]
crops = crops[crops$actualcropdamage > 0,]
crops = select(crops , -c("propdmg","propdmgexp","actualpropertydamage","bgn_date"))
head(crops,5)
```

```
         evtype fatalities injuries cropdmg cropdmgexp actualcropdamage
2  Extreme Cold          0        0     1.0    1000000          1000000
10 Extreme Cold          0        0     2.5    1000000          2500000
24 Extreme Cold          0        0   500.0       1000           500000
45 Extreme Cold          0        0    52.0    1000000         52000000
57 Extreme Cold          0        0    74.9    1000000         74900000
```

```r
crops = aggregate(actualcropdamage ~ evtype , data = crops , FUN = sum)
crops = mutate(crops , percentdamage = (actualcropdamage/sum(actualcropdamage)) * 100)  
crops = crops[order(crops$percentdamage , decreasing = TRUE),]
head(crops,5)
```

```
              evtype actualcropdamage percentdamage
4            Drought      13972621780      29.28505
10            Floods       5661968450      11.86685
19 Hurricane/Typhoon       5516117800      11.56117
24       River flood       5057484000      10.59992
20         Ice Storm       5022113500      10.52579
```

```r
c = ggplot(crops[1:10,] , aes(x = evtype , y = percentdamage,fill = evtype)) + geom_bar(stat = "identity" ) + coord_flip() + labs(x = "Events\n\n" , y = "\n\nPercentage damage to crops") + theme(axis.text  = element_text(size = 12) , axis.title = element_text(size = 12, face = "bold"),legend.position = "none")  + scale_fill_viridis(discrete = TRUE,begin = 0.1,end=0.8)
ggplotly(c)
```

<!--html_preserve--><div id="htmlwidget-5b5f680732b7454fdf2a" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-5b5f680732b7454fdf2a">{"x":{"data":[{"orientation":"h","width":0.9,"base":0,"x":[29.2850537265476],"y":[1],"text":"evtype: Drought<br />percentdamage: 29.285054<br />evtype: Drought","type":"bar","marker":{"autocolorscale":false,"color":"rgba(72,37,118,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Drought","legendgroup":"Drought","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[2.75194946980042],"y":[2],"text":"evtype: Extreme Cold<br />percentdamage:  2.751949<br />evtype: Extreme Cold","type":"bar","marker":{"autocolorscale":false,"color":"rgba(67,61,132,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Extreme Cold","legendgroup":"Extreme Cold","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[3.21131399417391],"y":[3],"text":"evtype: Flash Flood<br />percentdamage:  3.211314<br />evtype: Flash Flood","type":"bar","marker":{"autocolorscale":false,"color":"rgba(58,83,139,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Flash Flood","legendgroup":"Flash Flood","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[11.8668531122487],"y":[4],"text":"evtype: Floods<br />percentdamage: 11.866853<br />evtype: Floods","type":"bar","marker":{"autocolorscale":false,"color":"rgba(49,104,142,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Floods","legendgroup":"Floods","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[2.29329157414839],"y":[5],"text":"evtype: Frost/Freeze<br />percentdamage:  2.293292<br />evtype: Frost/Freeze","type":"bar","marker":{"autocolorscale":false,"color":"rgba(41,123,142,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Frost/Freeze","legendgroup":"Frost/Freeze","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[6.47795225538038],"y":[6],"text":"evtype: Hail<br />percentdamage:  6.477952<br />evtype: Hail","type":"bar","marker":{"autocolorscale":false,"color":"rgba(33,142,141,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Hail","legendgroup":"Hail","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.9,"base":0,"x":[11.5611664495341],"y":[7],"text":"evtype: Hurricane/Typhoon<br />percentdamage: 11.561166<br />evtype: Hurricane/Typhoon","type":"bar","marker":{"autocolorscale":false,"color":"rgba(31,161,136,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Hurricane/Typhoon","legendgroup":"Hurricane/Typhoon","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.899999999999999,"base":0,"x":[10.5257886446791],"y":[8],"text":"evtype: Ice Storm<br />percentdamage: 10.525789<br />evtype: Ice Storm","type":"bar","marker":{"autocolorscale":false,"color":"rgba(45,178,125,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Ice Storm","legendgroup":"Ice Storm","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.899999999999999,"base":0,"x":[10.5999212598135],"y":[9],"text":"evtype: River flood<br />percentdamage: 10.599921<br />evtype: River flood","type":"bar","marker":{"autocolorscale":false,"color":"rgba(78,195,107,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"River flood","legendgroup":"River flood","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"h","width":0.899999999999999,"base":0,"x":[2.43019329238515],"y":[10],"text":"evtype: Thunderstorm Winds<br />percentdamage:  2.430193<br />evtype: Thunderstorm Winds","type":"bar","marker":{"autocolorscale":false,"color":"rgba(122,209,81,1)","line":{"width":1.88976377952756,"color":"transparent"}},"name":"Thunderstorm Winds","legendgroup":"Thunderstorm Winds","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.2283105022831,"r":7.30593607305936,"b":45.7617268576173,"l":170.361145703611},"plot_bgcolor":"rgba(235,235,235,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-1.46425268632738,30.749306412875],"tickmode":"array","ticktext":["0","10","20","30"],"tickvals":[0,10,20,30],"categoryorder":"array","categoryarray":["0","10","20","30"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":15.9402241594022},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(255,255,255,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"y","title":{"text":"<b> <br /><br />Percentage damage to crops <\/b>","font":{"color":"rgba(0,0,0,1)","family":"","size":15.9402241594022}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.4,10.6],"tickmode":"array","ticktext":["Drought","Extreme Cold","Flash Flood","Floods","Frost/Freeze","Hail","Hurricane/Typhoon","Ice Storm","River flood","Thunderstorm Winds"],"tickvals":[1,2,3,4,5,6,7,8,9,10],"categoryorder":"array","categoryarray":["Drought","Extreme Cold","Flash Flood","Floods","Frost/Freeze","Hail","Hurricane/Typhoon","Ice Storm","River flood","Thunderstorm Winds"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":15.9402241594022},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(255,255,255,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"x","title":{"text":"<b> Events<br /><br /> <\/b>","font":{"color":"rgba(0,0,0,1)","family":"","size":15.9402241594022}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.689497716895}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","showSendToCloud":false},"source":"A","attrs":{"10e47cfe1e40":{"x":{},"y":{},"fill":{},"type":"bar"}},"cur_data":"10e47cfe1e40","visdat":{"10e47cfe1e40":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

The above plot depicts the 10 most damaging weather events with respect to cost of crop damage.

*From the plot it is evident that* ***Droughts*** *account for maximum damage of crops, followed by* ***Floods***,***Hurricanes*** *and* ***Ice Storms***. 

*Thus,* ***Floods***, ***Hurricanes***, ***Tornadoes***, ***Droughts*** *and* ***Storms*** *have maximum economic significance considering both property and crop damage.*<br>

## **6. Conclusion**

In this project, we aimed to explore the NOAA Storm Database and gather insights regarding events most harmful to human health and those with a maximum impact on the economy.

From the results of our analysis, we can conclude that ***Tornadoes*** and ***Thunderstorm Winds***  have the most devastating impact on human health while ***Floods***, ***Droughts*** and ***Hurricanes*** have maximum economical consequence.
<br><br>
