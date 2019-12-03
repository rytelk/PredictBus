library(plyr)
library(dplyr)
library(rpart)
library(lubridate)
library(sqldf)
library(stringr)
library(readtext)

Sys.setlocale("LC_TIME", "C")

path_mataa = "C:\\Users\\amata\\Desktop\\PLIKI_PPD\\PPD_DATES\\"
path_czarnockig = "C:\\Development\\_university\\PredictBus\\"
path_rytelk = "/home/krystian/Documents/PredictBus/"

path = path_rytelk
source(paste(path,"BusesRepository.R",sep=''))

buses <- GetBuses('3027-Dolna')

cart.tree <- rpart(delay ~ lineString + hour + isWeekend, data = buses)
summary(cart.tree)

paramLineString = "501";
current_time = "2019-12-01 14:34:25"
current_time_posix <- as.POSIXct(strptime("2018-05-21 09:30:00", "%Y-%m-%d %H:%M:%S"))
library(lubridate)
current_time_hour <- as.integer(hour(current_time_posix))
current_time_dw <- weekdays(current_time_posix)


if(current_time_dw == "Saturday" || current_time_dw == "Sunday")
{
  current_time_is_weekend <- 1 
} else {
  current_time_is_weekend <- 0
}


df_test <- data.frame(paramLineString, current_time_hour, current_time_is_weekend)
colnames(df_test) <- c("lineString", "hour", "isWeekend")

cart.tree.pred <- predict(cart.tree, df_test)
