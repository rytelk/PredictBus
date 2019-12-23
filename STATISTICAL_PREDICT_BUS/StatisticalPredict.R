# --------------------------------------------------------------------------------
# Parameters of prediction
# TODO - get full frame of input data

GLOBAL_bus_stop_id <- '3027'
GLOBAL_bus_line <- 'N81'
GLOBAL_query_datetime <- '2018-05-21 00:04:41'
GLOBAL_seconds_margin <- 800

input_df = data.frame(GLOBAL_bus_stop_id, GLOBAL_bus_line, GLOBAL_query_datetime, GLOBAL_seconds_margin, stringsAsFactors = FALSE)
colnames(input_df) <- c('bus_stop_id', 'bus_line', 'query_datetime', 'seconds_margin')
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
# set main path
path_czarnockig = "C:\\Development\\_university\\PredictBus\\"
path_rytelk = "/home/krystian/Documents/PredictBus/"
path_mataa = "C:/Users/amata/Desktop/PPD-REPO/STATISTICAL_PREDICT_BUS/"

path = path_mataa
# --------------------------------------------------------------------------------
# get functions
source(paste(path, 'ProjectFunctionsLibrary.R', sep = ''))
# --------------------------------------------------------------------------------
# open connection
db_filename <- paste(path, "Buses.db", sep = '')
connection <- dbConnect(RSQLite::SQLite(), db_filename)
# --------------------------------------------------------------------------------
# predict delay
main_output_df <- data.frame(
                             real_delay <- numeric(),
                             schedule_arrival_time <- factor(),
                             predicted_delay <- numeric(),
                             predict_percentage_error <- numeric(),
                             predict_error <- numeric()
                            )

for(current_row in 1:nrow(input_df))
{
  predicted_df <- statisticalPredict(
                                      path = path,
                                      connection = connection,
                                      INPUT_seconds_margin = input_df[current_row, "seconds_margin"],
                                      INPUT_bus_stop_id = input_df[current_row, "bus_stop_id"],
                                      INPUT_query_datetime = input_df[current_row, "query_datetime"],
                                      INPUT_bus_line = input_df[current_row, "bus_line"]
                                    )
  main_output_df <- rbind(main_output_df, predicted_df)
}
# --------------------------------------------------------------------------------
# print the result
# TODO
# --------------------------------------------------------------------------------
# close the connection
dbDisconnect(connection)
# --------------------------------------------------------------------------------
