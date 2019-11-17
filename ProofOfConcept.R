# make sure you installed those libraries:
# install.packages('plyr') # SQL
# install.packages('dplyr') # SQL
# install.packages("lubridate") # Dates operations
# install.packages("sqldf") # data frames with sql


library(plyr)
library(dplyr)
library(lubridate)
library(sqldf)
library(stringr) # string manipulation

# TODO - podmienic sciezke na lokalna
folder_path = "C:\\Users\\amata\\Desktop\\PLIKI_PPD\\"
file_name = "DATA_SAMPLE.csv";

# ----------------
# Input parameters
line_num = "172"
bus_stop = "3064-Goraszewska"
arrival_hour = "00"
# ----------------


sql_script = "
select *
  from file
 where lineString = '>line_num<'
   and nextStopString = '>bus_stop<'
   and substr(timeDatetime, 12, 2) = '>arrival_hour<'
"

sql_script = sql_script %>%
  str_replace_all(">line_num<", line_num) %>%
  str_replace_all(">bus_stop<", bus_stop) %>%
  str_replace_all(">arrival_hour<", arrival_hour)


df <- read.csv.sql(paste(folder_path, file_name, sep=''), header = TRUE, sep = ";", eol = "\n", sql = sql_script)

