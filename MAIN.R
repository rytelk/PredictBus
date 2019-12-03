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

path = path_rytelk # change this
source(paste(path,"BusesRepository.R",sep=''))

buses <- GetBuses('7032-Chmielna')

filename = "PART_1.csv"
lab_data = read.csv(paste(path, filename, sep=''), sep = ';')
sql_file_name = "filter_data.sql"

# parametry wejsciowe
current_time <- as.POSIXct(strptime("2018-05-21 09:30:00", "%Y-%m-%d %H:%M:%S"))
lineNumber <- "172"
busStop <- "3027-Dolna"



current_hour = as.numeric(format(current_time, "%H"))

sql_script = readtext(paste(path, sql_file_name, sep=''))

# godzina w prz?d, i w ty?
sql_script = sql_script$text %>%
  str_replace_all(">line_num<", lineNumber) %>%
  str_replace_all(">bus_stop<", busStop) %>%
  str_replace_all(">surrounding_hours<", GetSurroundingHours(current_hour))

df <- read.csv.sql(paste(path, filename, sep=''), header = TRUE, sep = ";", eol = "\n", sql = sql_script)

# frame do testow
df_learn <- df %>%
  select(delayLet, timeDatetime)

# budowa modelu do predykcji z wykorzystaniem drzewa CART
cart.tree <- rpart(delayLet ~ timeDatetime, data = df_learn)
summary(cart.tree)

# dostarczenie parametru daty do predykcji w odpowiednim formacie
df_test <- data.frame(as.factor(current_time))
colnames(df_test) <- c("timeDatetime")

# predykcja
cart.tree.pred <- predict(cart.tree, df_test)

# cast na double dla outputu
output <- as.double(cart.tree.pred)
