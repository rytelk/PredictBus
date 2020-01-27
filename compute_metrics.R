path_czarnockig = "C:\\Development\\_university\\PredictBus\\"
path_rytelk = "/home/krystian/Documents/PredictBus/"
path_mataa = "C:/Users/amata/Desktop/PPD-REPO/STATISTICAL_PREDICT_BUS/"

path = path_czarnockig
datapath = "STATISTICAL_PREDICT_BUS\\results\\"
# --------------------------------------------------------------------------------

files <- c('buses_weekend_day.csv', 'buses_weekend_night.csv', 'buses_weekday_day.csv', 'buses_weekday_night.csv')
for (datafile in files) {
  # Parameters of prediction
  print(datafile)
  input <- read.csv(paste(path, datapath, datafile, sep = ''), sep = ',')
  
  print("Predict_error")
  mean(input$predict_error, na.rm=TRUE)
  sd(input$predict_error, na.rm=TRUE);
  print("Percentage_error`")
  mean(input$predict_percentage_error, na.rm=TRUE)
}
