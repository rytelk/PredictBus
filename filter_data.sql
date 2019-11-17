select *
  from file
 where lineString = '>line_num<'
   and nextStopString = '>bus_stop<'
   and substr(timeDatetime, 12, 2) in (>surrounding_hours<)