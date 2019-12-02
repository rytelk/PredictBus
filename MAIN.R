library(plyr)
library(dplyr)
library(rpart)

path = "C:\\Users\\amata\\Desktop\\PLIKI_PPD\\PPD_DATES\\"
filename = "PART_1.csv"
lab_data = read.csv(paste(path, filename, sep=''), sep = ';')

# parametry wejsciowe
current_time <- as.POSIXct(strptime("2018-05-21 09:30:00", "%Y-%m-%d %H:%M:%S"))
lineNumber <- "172"
busStop <- "3027-Dolna"

# odejmujemy 10 minut od daty wejsciowej
lower_bound <- current_time - 10 * 60

# dodajemy 10 minut do daty wejsciowej
upper_bound <- current_time + 10 * 60

# frame do selekcji danych
df <- lab_data %>%
  filter( as.POSIXct(strptime(timeDatetime, "%Y-%m-%d %H:%M:%S")) < upper_bound ) %>%
  filter( as.POSIXct(strptime(timeDatetime, "%Y-%m-%d %H:%M:%S")) > lower_bound ) %>%
  filter( lineString == lineNumber ) %>%
  filter( nextStopString == busStop )

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
