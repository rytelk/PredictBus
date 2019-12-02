create index line_nextstop_index 
on buses (lineString, nextStopString);

create view buses_data as
select lineString, brigadeString, timeDatetime, statusString, delayLet, 
delayAtStopString, plannedLeaveTimeDatetime, nearestStopString, nearestStopDistancefloat, previousStopString, 
previousStopDistancefloat, previousStopArrivalTimeDatetime, previousStopLeaveTimeDatetime, nextStopString, 
nextStopDistancefloat, nextStopTimetableVisitTimeDatetime, courseDirectionString, timetableIdentifierString, 
timetableStatusEnumeration, onWayToDepotBoolean, overlapsWithNextBrigadeBoolean, 
overlapsWithNextBrigadeStopLineBrigadeString, atStopBoolean, oldDelayFloat
from buses;
