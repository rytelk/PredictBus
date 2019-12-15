select delayLet as delay,
       nextStopTimetableVisitTimeDatetime as timetable_datetime
  from (
        select MAIN_TAB.*,
               abs( 
                    strftime('%s','>>QUERY_DATETIME<<')
                    -
                    strftime('%s', timeDatetime)
                  ) as time_diff
          from (
                select Buses.*
                  from Buses
                 where nextStopString like '>>BUS_STOP_ID<<-%'
                   and statusString in ('MOVING', 'MOVING_SLOWLY')
                   and lineString = '>>BUS_LINE<<'
               ) as MAIN_TAB
       ) as DIFF_TAB
 group by DIFF_TAB.lineString
having min(time_diff) = time_diff
;
