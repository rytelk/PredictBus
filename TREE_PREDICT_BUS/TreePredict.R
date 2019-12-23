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
path_mataa = "C:/Users/amata/Desktop/PPD-REPO/TREE_PREDICT_BUS/"

path = path_mataa
# --------------------------------------------------------------------------------
# Parameters of prediction
input_df_temp <- read.csv(paste(path, 'SampleData.csv', sep = ''), sep = ';')
input_df <- data.frame(
  as.character(input_df_temp$bus_stop_id),
  as.character(input_df_temp$bus_line),
  as.character(input_df_temp$query_datetime),
  stringsAsFactors = FALSE
)
colnames(input_df) <- c('bus_stop_id', 'bus_line', 'query_datetime')
rm(input_df_temp)
# --------------------------------------------------------------------------------
# function to get sql from file
source(paste(path, 'ProjectFunctionLib.R', sep = ''))

# --------------------------------------------------------------------------------
# open connection
db_filename <- paste(path, "Buses.db", sep = '')
connection <- dbConnect(RSQLite::SQLite(), db_filename)
# --------------------------------------------------------------------------------
# perform prediction
main_output_df <- data.frame(
                             real_delay <- numeric(),
                             schedule_arrival_time <- factor(),
                             predicted_delay <- numeric(),
                             predict_percentage_error <- numeric(),
                             predict_error <- numeric()
                            )

for(current_row in 1:nrow(input_df))
{
  output_df <- makePrediction(
                              path = path,
                              connection = connection,
                              INPUT_bus_stop_id = input_df[current_row, "bus_stop_id"],
                              INPUT_bus_line = input_df[current_row, "bus_line"],
                              INPUT_query_datetime = input_df[current_row, "query_datetime"]
                             )
  main_output_df <- rbind(main_output_df, output_df)
}
# --------------------------------------------------------------------------------
# close the connection
dbDisconnect(connection)
# --------------------------------------------------------------------------------
