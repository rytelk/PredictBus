CastHourToString <- function(num_hour)
{
  if( num_hour < 10 )
  {
    return( paste("0", toString(num_hour), sep='') )
  }
  else
  {
    return( toString(num_hour) )
  }  
}

GetSurroundingHours <- function(start_hour)
{
  s_start_hour = CastHourToString(start_hour)
  s_prev_hour = ''
  s_next_hour = ''
  
  if(start_hour == 0)
  {
    s_prev_hour = CastHourToString(23)
  }
  else
  {
    s_prev_hour = CastHourToString(start_hour - 1)
  }
  
  
  if(start_hour == 23)
  {
    s_next_hour = CastHourToString(0)
  }
  else
  {
    s_next_hour = CastHourToString(start_hour + 1)
  }
  
  return( paste("'", s_prev_hour, "','", s_start_hour, "','", s_next_hour, "'", sep='') )
  
}

# make sure you installed those libraries:
# install.packages('plyr') # SQL
# install.packages('dplyr') # SQL
# install.packages("lubridate") # Dates operations
# install.packages("sqldf") # data frames with sql
# install.packages("stringr")
# install.packages("readtext")

library(plyr)
library(dplyr)
library(lubridate)
library(sqldf)
library(stringr) # string manipulation
library(readtext) #reading files

# TODO - podmienic sciezke na lokalna
folder_path = "C:\\Users\\amata\\Desktop\\PLIKI_PPD\\"
file_name = "DATA_SAMPLE.csv";
sql_file_name = "filter_data.sql"

# ----------------
# Input parameters
line_num = "172"
bus_stop = "3064-Goraszewska"
arrival_hour = 0
# ----------------

sql_script = readtext(paste(folder_path, sql_file_name, sep=''))

sql_script = sql_script$text %>%
  str_replace_all(">line_num<", line_num) %>%
  str_replace_all(">bus_stop<", bus_stop) %>%
  str_replace_all(">surrounding_hours<", GetSurroundingHours(arrival_hour))


df <- read.csv.sql(paste(folder_path, file_name, sep=''), header = TRUE, sep = ";", eol = "\n", sql = sql_script)

# Rozwi¹zanie Adama:

# odejmujemy 10 minut od daty wejsciowej
#lower_bound <- current_time - 10 * 60

# dodajemy 10 minut do daty wejsciowej
#upper_bound <- current_time + 10 * 60

# frame do selekcji danych
#df <- lab_data %>%
#  filter( as.POSIXct(strptime(timeDatetime, "%Y-%m-%d %H:%M:%S")) < upper_bound ) %>%
#  filter( as.POSIXct(strptime(timeDatetime, "%Y-%m-%d %H:%M:%S")) > lower_bound ) %>%
#  filter( lineString == lineNumber ) %>%
#  filter( nextStopString == busStop )