library(plyr)
library(dplyr)
library(rpart)
library(lubridate)
library(sqldf)
library(stringr) # string manipulation
library(readtext) #reading files

path_mataa = "C:\\Users\\amata\\Desktop\\PLIKI_PPD\\PPD_DATES\\"
path_czarnockig = "C:\\Development\\_university\\PredictBus\\"
path_rytelk = "/home/krystian/Documents/PredictBus/"

path = path_rytelk # change this
source(paste(path,"BusesRepository.R",sep=''))

buses <- GetBuses('3027-Dolna')

cart.tree <- rpart(delay ~ lineString + hour + isWeekend, data = buses)
summary(cart.tree)


