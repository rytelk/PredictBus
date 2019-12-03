source(paste(path,"TimeUtils.R",sep=''))

GetBuses <- function(bus_stop)
{
  library(RSQLite)
  library(stringr)
  
  conn <- dbConnect(RSQLite::SQLite(), "Buses.db")
  
  sqlQuery <- str_interp('select lineString, cast(substr(timeDatetime, 12, 2) as integer) as timeDatetime, delayLet as delay from Buses where nextStopString = "${bus_stop}";')
  
  buses <- dbGetQuery(conn, sqlQuery)
  dbDisconnect(conn)
  
  return(buses)
}