library(shiny)
library(ggplot2)
library(dplyr)
library(rockchalk)
library(plotly)
library(data.table)
library(dplyr)
library(plyr)
library(shiny)
library(leaflet)
library(sp)
library(rgeos)
library(rgdal)
library(leaflet.extras)
library(RColorBrewer)
library(raster)
library(shinythemes)
library(maptools)
library(scales)
library(lubridate)
library(rsconnect)

rsconnect::setAccountInfo(name = 'samirh47', 
                          token = 'C08B67D6CF5601FF580F057A2EB2A67A', 
                          secret = '9aQ+vqCwfNIT1u2xoShr9UbP2QZ1551WET6lo0RL')

# data processing
load("crime_data.rdata")

crime <- crime %>% mutate(HOUR = as.integer(substr(as.character(TIME), 1, 2)))
crime$DAY <- toupper(wday(crime$DATE, label = TRUE, abbr = FALSE))
crime$VIC_SEX[crime$VIC_SEX == 'F'] <- 'FEMALE'
crime$VIC_SEX[crime$VIC_SEX == 'M'] <- 'MALE'
crime$SUSP_SEX[crime$SUSP_SEX == 'F'] <- 'FEMALE'
crime$SUSP_SEX[crime$SUSP_SEX == 'M'] <- 'MALE'



crime$TIME <- revalue(crime$TIME, 
                      c('00:00:00-01:00:00' = '12AM-1AM',
                        '01:00:00-02:00:00' = '1AM-2AM',
                        '02:00:00-03:00:00' = '2AM-3AM',
                        '03:00:00-04:00:00' = '3AM-4AM',
                        '04:00:00-05:00:00' = '4AM-5AM',
                        '05:00:00-06:00:00' = '5AM-6AM',
                        '06:00:00-07:00:00' = '6AM-7AM',
                        '07:00:00-08:00:00' = '7AM-8AM',
                        '08:00:00-09:00:00' = '8AM-9AM',
                        '09:00:00-10:00:00' = '9AM-10AM',
                        '10:00:00-11:00:00' = '10AM-11AM',
                        '11:00:00-12:00:00' = '11AM-12AM',
                        '12:00:00-13:00:00' = '12PM-1PM',
                        '13:00:00-14:00:00' = '1PM-2PM',
                        '14:00:00-15:00:00' = '2PM-3PM',
                        '15:00:00-16:00:00' = '3PM-4PM',
                        '16:00:00-17:00:00' = '4PM-5PM',
                        '17:00:00-18:00:00' = '5PM-6PM',
                        '18:00:00-19:00:00' = '6PM-7PM',
                        '19:00:00-20:00:00' = '7PM-8PM',
                        '20:00:00-21:00:00' = '8PM-9PM',
                        '21:00:00-22:00:00' = '9PM-10PM',
                        '22:00:00-23:00:00' = '10PM-11PM',
                        '23:00:00-00:00:00' = '11PM-12AM'))

plot_breaks <- c(mdy_hms('10/07/2019 0:00:00'))
for (i in 1:24) { plot_breaks[i + 1] <- plot_breaks[1] + i*60*60 - 1}

weekday_list <- toupper(c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
gender_list <- c("FEMALE", "MALE")
age_list <- c("<18", "18-24", "25-44", "45-64", "65+")

time_list <- list('12AM-1AM',
                  '1AM-2AM',
                  '2AM-3AM',
                  '3AM-4AM',
                  '4AM-5AM',
                  '5AM-6AM',
                  '6AM-7AM',
                  '7AM-8AM',
                  '8AM-9AM',
                  '9AM-10AM',
                  '10AM-11AM',
                  '11AM-12AM',
                  '12PM-1PM',
                  '1PM-2PM',
                  '2PM-3PM',
                  '3PM-4PM',
                  '4PM-5PM',
                  '5PM-6PM',
                  '6PM-7PM',
                  '7PM-8PM',
                  '8PM-9PM',
                  '9PM-10PM',
                  '10PM-11PM',
                  '11PM-12AM')

location_list <- list("STREET", 
                      "RESIDENCE",
                      "STORES",
                      "SCHOOL",
                      "ENTERTAINMENT",
                      "PUBLIC AREA",
                      "PUBLIC TRANSPORTATION",
                      "TAXI",
                      "OTHER")

type_list <- list("ASSAULT",
                  "LARCENY",
                  "CRIMINAL MISCHIEF",
                  "ALCOHOL & DRUGS",
                  "OFFENSES AGAINST PUBLIC ORDER",
                  "MISCELLANEOUS PENAL LAW",
                  "TRAFFIC LAWS",
                  "HARRASSMENT")