path_czarnockig = "C:\\Development\\_university\\PredictBus\\"
path_rytelk = "/home/krystian/Documents/PredictBus/"
path_mataa = "C:/Users/amata/Desktop/PPD-REPO/STATISTICAL_PREDICT_BUS/"

path = path_czarnockig

data = "FOREST_PREDICT\\results\\buses_weekend_day.csv"
# --------------------------------------------------------------------------------
# Parameters of prediction
input <- read.csv(paste(path, data, sep = ''), sep = ',')

print("Predict_error")
mean(input$predict_error, na.rm=TRUE)
sd(input$predict_error, na.rm=TRUE);
print("Percentage_error`")
mean(input$predict_percentage_error, na.rm=TRUE)
sd(input$predict_percentage_error, na.rm=TRUE)
