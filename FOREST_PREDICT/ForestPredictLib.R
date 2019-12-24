getSQL <- function(filepath)
{
  con = file(filepath, "r")
  sql.string <- ""
  
  while (TRUE)
  {
    line <- readLines(con, n = 1)
    
    if ( length(line) == 0 )
    {
      break
    }
    
    line <- gsub("\\t", " ", line)
    
    if(grepl("--",line) == TRUE)
    {
      line <- paste(sub("--","/*",line),"*/")
    }
    
    sql.string <- paste(sql.string, line)
  }
  
  close(con)
  return(sql.string)
}

makeForestPrediction <- function(path, connection, INPUT_bus_stop_id, INPUT_bus_line, INPUT_query_datetime)
{
    # get learn data
    forest_sql_file_path <- paste(path, "ForestPredictForR.sql", sep = '')
    forest_sql_code <- getSQL(forest_sql_file_path)
    forest_sql_code <- str_replace_all(forest_sql_code, '>>BUS_STOP_ID<<', INPUT_bus_stop_id)
    forest_buses_data <- dbGetQuery(connection, forest_sql_code)
    forest_buses_data$lineString <- as.factor(forest_buses_data$lineString)
    # --------------------------------------------------------------------------------
    # build predict model using random forest
    model_rf <- randomForest(delay ~ lineString + isWeekend + hour, data = forest_buses_data)
    # --------------------------------------------------------------------------------
    # prepare test data frame

    #INPUT_query_datetime <- '2018-05-21 00:04:41'
    #INPUT_bus_line <- 'N81'
    #INPUT_bus_stop_id <- '3027'
    
    
    EXTRACTED_POSIX_query_datetime <- as.POSIXct(strptime(INPUT_query_datetime, "%Y-%m-%d %H:%M:%S"))
    EXTRACTED_hour <- as.integer(hour(EXTRACTED_POSIX_query_datetime))
    EXTRACTED_day_of_week <- weekdays(EXTRACTED_POSIX_query_datetime)

    if( EXTRACTED_day_of_week == "Saturday" || EXTRACTED_day_of_week == "Sunday" )
    {
      EXTACTED_is_weekend <- as.integer(1)
    } else {
      EXTACTED_is_weekend <- as.integer(0)
    }

    bus_line_factors <- factor(INPUT_bus_line, levels = levels(forest_buses_data$lineString))
    df_test = data.frame(bus_line_factors, EXTACTED_is_weekend, EXTRACTED_hour)
    colnames(df_test) <- c("lineString", "isWeekend", "hour")
    # --------------------------------------------------------------------------------
    forest_prediction <- predict(model_rf, df_test)
    predicted_delay <- as.double(forest_prediction)
    # --------------------------------------------------------------------------------
    # compute error
    error_sql_code_path <- paste(path, "GetClosestRecordForR.sql", sep = '')
    error_sql_code <- getSQL(error_sql_code_path)
    error_sql_code <- str_replace_all(error_sql_code, '>>BUS_STOP_ID<<', INPUT_bus_stop_id)
    error_sql_code <- str_replace_all(error_sql_code, '>>BUS_LINE<<', INPUT_bus_line)
    error_sql_code <- str_replace_all(error_sql_code, '>>QUERY_DATETIME<<', INPUT_query_datetime)

    side_buses_data <- dbGetQuery(connection, error_sql_code)
    real_world_delay <- mean(side_buses_data$delay)
    real_world_arrival_datetime <- side_buses_data$timetable_datetime[1]
    percentage_error <- abs(predicted_delay - real_world_delay) / abs(real_world_delay)
    # predict_error = real_world_delay - predicted_delay
    predict_error <- real_world_delay - predicted_delay
    
    df <- data.frame(real_world_delay, as.character(real_world_arrival_datetime), predicted_delay, percentage_error, predict_error, stringsAsFactors = FALSE)
    colnames(df) <- c('real_delay', 'schedule_arrival_time', 'predicted_delay', 'predict_percentage_error', 'predict_error')
    
    return(df)
}
