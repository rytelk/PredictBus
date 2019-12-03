source(paste(path,"TimeUtils.R",sep=''))

GetBuses <- function(bus_stop)
{
  library(RSQLite)
  library(stringr)
  
  conn <- dbConnect(RSQLite::SQLite(), "Buses.db")
  
  sqlQuery <- str_interp("select lineString, cast(substr(timeDatetime, 12, 2) as integer) as hour, delayLet as delay, (case when cast(substr(timeDatetime, 9, 2) as integer) IN (26, 27) then 1 else 0 end) as isWeekend from Buses where nextStopString = '${bus_stop}';")
  
  buses <- dbGetQuery(conn, sqlQuery)
  dbDisconnect(conn)
  
  return(buses)
}