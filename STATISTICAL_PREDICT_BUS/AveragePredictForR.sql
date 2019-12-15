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
                 where 1 = >>IS_MIDNIGHT_BROKEN<<
                   and nextStopString like '>>BUS_STOP_ID<<-%'
                   and statusString in ('MOVING', 'MOVING_SLOWLY')
                   and lineString = '>>BUS_LINE<<'
                   and
                   (
                    (
                        time(timeDatetime) >= time('>>QUERY_DATETIME<<', '->>SECONDS_MARGIN<< seconds')
                        and
                        time(timeDatetime) <= time('23:59:59')
                    )
                    or
                    (
                        time(timeDatetime) >= time('00:00:00')
                        and
                        time(timeDatetime) <= time('>>QUERY_DATETIME<<', '+>>SECONDS_MARGIN<< seconds')
                    )
                   )
                 union
                select lineString,
                       nextStopString,
                       datetime(timeDatetime) as timeDatetime,
                       delayLet
                  from Buses
                 where 0 = >>IS_MIDNIGHT_BROKEN<<
                   and nextStopString like '>>BUS_STOP_ID<<-%'
                   and statusString in ('MOVING', 'MOVING_SLOWLY')
                   and lineString = '>>BUS_LINE<<'
                   and time(timeDatetime) >= time('>>QUERY_DATETIME<<', '->>SECONDS_MARGIN<< seconds')
                   and time(timeDatetime) <= time('>>QUERY_DATETIME<<', '+>>SECONDS_MARGIN<< seconds')
             ) as MAIN_TAB
) as AVERAGE_TAB
;
