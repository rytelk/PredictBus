# --------------------------------------------------------------------------------
# Parameters of prediction
GLOBAL_bus_stop_id <- '3027'
GLOBAL_bus_line <- 'N81'
GLOBAL_query_datetime <- '2018-05-21 00:04:41'
GLOBAL_seconds_margin <- 800
# --------------------------------------------------------------------------------
# load libraries
library(plyr)
library(dplyr)
library(rpart)
library(lubridate)
library(sqldf)
library(stringr)
library(readtext)
library(RSQLite)
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
# --------------------------------------------------------------------------------
# set main path
path_czarnockig = "C:\\Development\\_university\\PredictBus\\"
path_rytelk = "/home/krystian/Documents/PredictBus/"
path_mataa = "C:/Users/amata/Desktop/MY_PREDICT_BUS/"

path = path_mataa
# --------------------------------------------------------------------------------
# open connection
db_filename <- paste(path, "Buses.db", sep = '')
connection <- dbConnect(RSQLite::SQLite(), db_filename)

# --------------------------------------------------------------------------------
# predict delay

left_end <- as.POSIXct(GLOBAL_query_datetime) - GLOBAL_seconds_margin
right_end <- as.POSIXct(GLOBAL_query_datetime) + GLOBAL_seconds_margin
l_date <- as.Date(ymd_hms(left_end))
r_date <- as.Date(ymd_hms(right_end))

if( l_date == r_date )
{
  EXTRACT_is_midnight_broken <- '0'
} else {
  EXTRACT_is_midnight_broken <- '1'
}



main_sql_file_path <- paste(path, "AveragePredictForR.sql", sep = '')
main_sql_code <- getSQL(main_sql_file_path)
main_sql_code <- str_replace_all(main_sql_code, '>>BUS_STOP_ID<<', GLOBAL_bus_stop_id)
main_sql_code <- str_replace_all(main_sql_code, '>>BUS_LINE<<', GLOBAL_bus_line)
main_sql_code <- str_replace_all(main_sql_code, '>>QUERY_DATETIME<<', GLOBAL_query_datetime)
main_sql_code <- str_replace_all(main_sql_code, '>>SECONDS_MARGIN<<', toString(GLOBAL_seconds_margin))
main_sql_code <- str_replace_all(main_sql_code, '>>IS_MIDNIGHT_BROKEN<<', EXTRACT_is_midnight_broken)

main_buses_data <- dbGetQuery(connection, main_sql_code)
predicted_delay <- main_buses_data$total_delay / main_buses_data$total_denominator
# --------------------------------------------------------------------------------
# get schedule arrival and real-world delay
side_sql_file_path <- paste(path, "GetClosestRecordForR.sql", sep = '')
side_sql_code <- getSQL(side_sql_file_path)
side_sql_code <- str_replace_all(side_sql_code, '>>BUS_STOP_ID<<', GLOBAL_bus_stop_id)
side_sql_code <- str_replace_all(side_sql_code, '>>BUS_LINE<<', GLOBAL_bus_line)
side_sql_code <- str_replace_all(side_sql_code, '>>QUERY_DATETIME<<', GLOBAL_query_datetime)

side_buses_data <- dbGetQuery(connection, side_sql_code)
real_world_delay <- mean(side_buses_data$delay)
real_world_arrival_datetime <- side_buses_data$timetable_datetime[1]
# --------------------------------------------------------------------------------
# compute error
statistical_predict_error <- abs(predicted_delay - real_world_delay) / abs(real_world_delay)
# --------------------------------------------------------------------------------
# print the result
# TODO
# --------------------------------------------------------------------------------
# close the connection
dbDisconnect(connection)
# --------------------------------------------------------------------------------
