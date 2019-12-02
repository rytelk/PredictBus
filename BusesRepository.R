source(paste(path,"TimeUtils.R",sep=''))

GetBuses <- function(line_num, bus_stop, query_time)
{
  library(RSQLite)
  library(stringr)
  
  conn <- dbConnect(RSQLite::SQLite(), "Buses")
  
  limit <- 5; 
  
  sqlQuery <- str_interp("SELECT * FROM Buses LIMIT 5;")
  buses <- dbGetQuery(conn, sqlQuery)
    
  dbDisconnect(conn)
  
  return(buses)
}