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
