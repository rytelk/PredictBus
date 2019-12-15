library(plyr)
library(dplyr)
library(rpart)
library(lubridate)
library(sqldf)
library(stringr)
library(readtext)

Sys.setlocale("LC_TIME", "C")

path_mataa = "C:/Users/amata/Desktop/PLIKI_PPD/NEWEST_PPD/PredictBus-master/"
path_czarnockig = "C:\\Development\\_university\\PredictBus\\"
path_rytelk = "/home/krystian/Documents/PredictBus/"

path = path_mataa
source(paste(path,"BusesRepository.R",sep=''))

bus_stop = '3027-Dolna'
buses <- GetBuses(path, bus_stop)

paramLineString = "N81";
current_time = "2019-12-01 00:00:01"
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
cart.tree <- rpart(delay ~ lineString + hour + isWeekend, data = buses)
cart.tree.pred <- predict(cart.tree, df_test)
summary(cart.tree)

output <- as.double(cart.tree.pred)
# --------------------------------------------------------------------------------
# function to get sql from file
getSQL <- function(filepath)
{
  con = file(filepath, "r")
  sql.string <- ""
  
  while (TRUE)
  {
    line <- readLines(con, n = 1)
    
    if ( length(line) == 0 )
    {
      break
    }
    
    line <- gsub("\\t", " ", line)
    
    if(grepl("--",line) == TRUE)
    {
      line <- paste(sub("--","/*",line),"*/")
    }
    
    sql.string <- paste(sql.string, line)
  }
  
  close(con)
  return(sql.string)
}
# ----------------------------------------------------
# obliczenie bledu
bus_stop_id <- '3027'
bus_line <- 'N81'
query_datetime <- '2019-12-01 00:00:01'

error_sql_code_path <- paste(path, "GetClosestRecordForR.sql", sep = '')
error_sql_code <- getSQL(error_sql_code_path)
error_sql_code <- str_replace_all(error_sql_code, '>>BUS_STOP_ID<<', bus_stop_id)
error_sql_code <- str_replace_all(error_sql_code, '>>BUS_LINE<<', bus_line)
error_sql_code <- str_replace_all(error_sql_code, '>>QUERY_DATETIME<<', query_datetime)

db_filename <- paste(path, "Buses.db", sep = '')
connection <- dbConnect(RSQLite::SQLite(), db_filename)
side_buses_data <- dbGetQuery(connection, error_sql_code)
dbDisconnect(connection)

real_world_delay <- mean(side_buses_data$delay)
real_world_arrival_datetime <- side_buses_data$timetable_datetime[1]

percentage_error <- abs(output - real_world_delay) / abs(real_world_delay)

# ----------------------------------------------------

cat("Opóźnienie dla linii ", paramLineString, ", czas: ", current_time, " = ", output, " sekund", sep = '')
