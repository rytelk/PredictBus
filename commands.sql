create index IDX_nextStopString 
on Buses (nextStopString);

select * from Buses where nextStopString = "3027-Dolna";