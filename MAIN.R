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

path = path_czarnockig # change this
source(paste(path,"BusesRepository.R",sep=''))

bus_stop = '3027-Dolna'
buses <- GetBuses(path, bus_stop)

paramLineString = "501";
current_time = "2019-12-01 14:34:25"
current_time_posix <- as.POSIXct(strptime(current_time, "%Y-%m-%d %H:%M:%S"))

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

# predykcja
cart.tree.pred <- predict(cart.tree, df_test)
summary(cart.tree)

output <- as.double(cart.tree.pred)
cat("Opóźnienie dla linii ", paramLineString, ", czas: ", current_time, " = ", output, " sekund", sep = '')