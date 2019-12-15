select sum(delay) as total_delay,
       sum(denominator) as total_denominator
from (
        select case when delayLet is null
                    then 0
                    else delayLet
                end as delay,
               case when delayLet is null
                    then 0
                    else 1
                end as denominator
          from (
                select lineString,
                       nextStopString,
                       datetime(timeDatetime) as timeDatetime,
                       delayLet
                  from Buses
                 where nextStopString like '>>BUS_STOP_ID<<-%'
                   and statusString in ('MOVING', 'MOVING_SLOWLY')
                   and lineString = '>>BUS_LINE<<'
                   and datetime(timeDatetime) <= datetime('>>QUERY_DATETIME<<', '+>>SECONDS_MARGIN<< seconds')
                   and datetime(timeDatetime) >= datetime('>>QUERY_DATETIME<<', '->>SECONDS_MARGIN<< seconds')
                 order by lineString, nextStopString, timeDatetime
             ) as MAIN_TAB
) as AVERAGE_TAB
;
