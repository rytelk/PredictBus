select delayLet as delay,
       nextStopTimetableVisitTimeDatetime as timetable_datetime
  from (
        select MAIN_TAB.*,
               abs( 
                    strftime('%s','2018-05-21 00:04:41')
                    -
                    strftime('%s', timeDatetime)
                  ) as time_diff
          from (
                select Buses.*
                  from Buses
                 where nextStopString like '1085-%'
                   and statusString in ('MOVING', 'MOVING_SLOWLY')
                   and lineString = '104'
               ) as MAIN_TAB
       ) as DIFF_TAB
 group by DIFF_TAB.lineString
having min(time_diff) = time_diff
;
