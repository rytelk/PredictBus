select lineString,
       case when strftime('%w', timeDatetime) in (0, 6)
            then 1
            else 0
       end as isWeekend,
       cast( strftime('%H', timeDatetime) as integer ) as hour,
       delayLet as delay
  from Buses
 where nextStopString like '>>BUS_STOP_ID<<-%'
;
