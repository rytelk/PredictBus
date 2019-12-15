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
                 where nextStopString like '1085-%'
                   and statusString in ('MOVING', 'MOVING_SLOWLY')
                   and lineString = '104'
                   and datetime(timeDatetime) <= datetime('2018-05-21 00:00:00', '+10 minutes')
                   and datetime(timeDatetime) >= datetime('2018-05-21 00:00:00', '-10 minutes')
                 order by lineString, nextStopString, timeDatetime
             ) as MAIN_TAB
) as AVERAGE_TAB
;
