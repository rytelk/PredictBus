# --------------------------------------------------------------------------------
# Parameters of prediction
GLOBAL_bus_stop_id <- '3027'
GLOBAL_bus_line <- 'N81'
GLOBAL_query_datetime <- '2018-05-21 00:04:41'
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
path_mataa = "C:/Users/amata/Desktop/MY_PREDICT_BUS_TREES/"

path = path_mataa
# --------------------------------------------------------------------------------
# open connection
db_filename <- paste(path, "Buses.db", sep = '')
connection <- dbConnect(RSQLite::SQLite(), db_filename)
# --------------------------------------------------------------------------------
# get learn data
tree_sql_file_path <- paste(path, "TreePredict.sql", sep = '')
tree_sql_code <- getSQL(tree_sql_file_path)
tree_sql_code <- str_replace_all(tree_sql_code, '>>BUS_STOP_ID<<', GLOBAL_bus_stop_id)
tree_buses_data <- dbGetQuery(connection, tree_sql_code)
# --------------------------------------------------------------------------------
# build predict model using tree
cart.tree <- rpart(delay ~ lineString + isWeekend + hour, data = tree_buses_data)
summary(cart.tree)
# --------------------------------------------------------------------------------
# prepare test data frame

EXTRACTED_POSIX_query_datetime <- as.POSIXct(strptime(GLOBAL_query_datetime, "%Y-%m-%d %H:%M:%S"))
EXTRACTED_hour <- as.integer(hour(EXTRACTED_POSIX_query_datetime))
EXTRACTED_day_of_week <- weekdays(EXTRACTED_POSIX_query_datetime)

if( EXTRACTED_day_of_week == "Saturday" || EXTRACTED_day_of_week == "Sunday" )
{
  EXTACTED_is_weekend <- 1
} else {
  EXTACTED_is_weekend <- 0
}

df_test = data.frame(GLOBAL_bus_line, EXTACTED_is_weekend, EXTRACTED_hour)
colnames(df_test) <- c("lineString", "hour", "isWeekend")
# --------------------------------------------------------------------------------
# make prediction
cart.tree.pred <- predict(cart.tree, df_test)
predicted_delay <- as.double(cart.tree.pred)
# --------------------------------------------------------------------------------
# compute error
error_sql_code_path <- paste(path, "GetClosestRecordForR.sql", sep = '')
error_sql_code <- getSQL(error_sql_code_path)
error_sql_code <- str_replace_all(error_sql_code, '>>BUS_STOP_ID<<', GLOBAL_bus_stop_id)
error_sql_code <- str_replace_all(error_sql_code, '>>BUS_LINE<<', GLOBAL_bus_line)
error_sql_code <- str_replace_all(error_sql_code, '>>QUERY_DATETIME<<', GLOBAL_query_datetime)

side_buses_data <- dbGetQuery(connection, error_sql_code)
real_world_delay <- mean(side_buses_data$delay)
real_world_arrival_datetime <- side_buses_data$timetable_datetime[1]

percentage_error <- abs(predicted_delay - real_world_delay) / abs(real_world_delay)
# --------------------------------------------------------------------------------
# close the connection
dbDisconnect(connection)
# --------------------------------------------------------------------------------