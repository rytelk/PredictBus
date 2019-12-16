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
# set main path
path_czarnockig = "C:\\Development\\_university\\PredictBus\\"
path_rytelk = "/home/krystian/Documents/PredictBus/"
path_mataa = "C:/Users/amata/Desktop/MY_PREDICT_BUS_TREES/"

path = path_mataa
# --------------------------------------------------------------------------------
# function to get sql from file
source(paste(path, 'ProjectFunctionLib.R', sep = ''))

# --------------------------------------------------------------------------------
# open connection
db_filename <- paste(path, "Buses.db", sep = '')
connection <- dbConnect(RSQLite::SQLite(), db_filename)
# --------------------------------------------------------------------------------
# perform prediction
# TODO
output_data_frame <- makePrediction(
                                    path = path,
                                    connection = connection,
                                    INPUT_bus_stop_id = GLOBAL_bus_stop_id,
                                    INPUT_bus_line = GLOBAL_bus_line,
                                    INPUT_query_datetime = GLOBAL_query_datetime
                                   )
# --------------------------------------------------------------------------------
# close the connection
dbDisconnect(connection)
# --------------------------------------------------------------------------------