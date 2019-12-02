library(plyr)
library(dplyr)
library(rpart)
library(lubridate)
library(sqldf)
library(stringr) # string manipulation
library(readtext) #reading files

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

path_mataa = "C:\\Users\\amata\\Desktop\\PLIKI_PPD\\PPD_DATES\\"
path_czarnockig = "C:\\Development\\_university\\PredictBus\\"
path_rytelk = "..."

path = path_czarnockig # change this
filename = "PART_1.csv"
lab_data = read.csv(paste(path, filename, sep=''), sep = ';')
sql_file_name = "filter_data.sql"

# parametry wejsciowe
current_time <- as.POSIXct(strptime("2018-05-21 09:30:00", "%Y-%m-%d %H:%M:%S"))
lineNumber <- "172"
busStop <- "3027-Dolna"

current_hour = as.numeric(format(current_time, "%H"))

sql_script = readtext(paste(path, sql_file_name, sep=''))

# godzina w przód, i w ty³
sql_script = sql_script$text %>%
  str_replace_all(">line_num<", lineNumber) %>%
  str_replace_all(">bus_stop<", busStop) %>%
  str_replace_all(">surrounding_hours<", GetSurroundingHours(current_hour))

df <- read.csv.sql(paste(path, filename, sep=''), header = TRUE, sep = ";", eol = "\n", sql = sql_script)

# dodaæ wyci¹gniêcie danych z ca³ego tygodnia

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
