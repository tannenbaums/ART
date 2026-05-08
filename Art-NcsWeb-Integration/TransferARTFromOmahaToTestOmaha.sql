--transfar omaha art data to omaha test just in order to test, this should only be applicable for test omaha, i think
select pe.Id, pe.Name--, c.*
from tblPhysicalEntity pe
join tblResident r on r.PeId = pe.Id
join tblCase c on c.ResId = r.Id
where 1=1
and pe.name like '%Omaha%'
and pe.LevelId = 3
and pe.Id = 39494   --42541   

select pe.Id, pe.Name
from tblPhysicalEntity pe
join tblResident r1 on r1.PeId = pe.Id and r1.PeId = 39494
join tblResident r2 on r1.SystemNo = r2.SystemNo and r2.PeId = 42541
where 1=1
and pe.name like '%Omaha%'
and pe.LevelId = 3


select count(*)
from tblPayor
where PeId = 39494

select count(*)
from tblPayor
where PeId = 42541

---first clean up all the cases and againg data from omaha test
/*
delete
from tblCase 
--select c.*
from tblResident r
join tblCase c on r.Id = c.ResId
where r.PeId = 42541

delete from [tblAging.Bill]
--select b.*
from [tblAging.Bill] b
join tblResident r on b.ResId = r.Id
where r.PeId = 42541


delete from [tblAging.Cr]
--select b.*
from [tblAging.Cr] b
join tblResident r on b.ResId = r.Id
where r.PeId = 42541

delete from [tblAging.Bal] 
--select b.*
from [tblAging.Bal] b
join tblResident r on b.ResId = r.Id
where r.PeId = 42541

*/

--move art data from omaha to test omaha
select b.*
from [tblAging.BalCase] b
join [tblAging.Bal] bal on b.BalId = bal.Id
join tblResident r on Bal.ResId = r.Id
where r.PeId = 42541


select b.*
from [tblAging.Bill] b
join tblResident r on b.ResId = r.Id
where r.PeId = 39494

update c
set c.ResId = r2.Id
--select r1.PeId, *
from tblCase c
join tblResident r1 on c.ResId = r1.Id and r1.PeId = 39494 --omaha
join tblResident r2 on r1.SystemNo = r2.SystemNo and r2.PeId = 42541 --test omaha


update b
set b.ResId = r2.Id
,UniqueIdentifier = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.UniqueIdentifier, CHARINDEX('-', b.UniqueIdentifier), LEN(b.UniqueIdentifier))
,[AgingKey-RPPSM] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPPSM], CHARINDEX('-', b.[AgingKey-RPPSM]), LEN(b.[AgingKey-RPPSM]))
,[AgingKey-RPPS] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPPS], CHARINDEX('-', b.[AgingKey-RPPS]), LEN(b.[AgingKey-RPPS]))
,[AgingKey-RPSM] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPSM], CHARINDEX('-', b.[AgingKey-RPSM]), LEN(b.[AgingKey-RPSM]))
,[AgingKey-RPPSD] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPPSD], CHARINDEX('-', b.[AgingKey-RPPSD]), LEN(b.[AgingKey-RPPSD]))
--select r1.PeId, *
from [tblAging.Bill] b
join tblResident r1 on b.ResId = r1.Id and r1.PeId = 39494 --omaha
join tblResident r2 on r1.SystemNo = r2.SystemNo and r2.PeId = 42541 --test omaha


update b
set b.ResId = r2.Id
,UniqueIdentifier = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.UniqueIdentifier, CHARINDEX('-', b.UniqueIdentifier), LEN(b.UniqueIdentifier))
,[AgingKey-RPPSM] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPPSM], CHARINDEX('-', b.[AgingKey-RPPSM]), LEN(b.[AgingKey-RPPSM]))
,[AgingKey-RPPS] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPPS], CHARINDEX('-', b.[AgingKey-RPPS]), LEN(b.[AgingKey-RPPS]))
,[AgingKey-RPSM] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPSM], CHARINDEX('-', b.[AgingKey-RPSM]), LEN(b.[AgingKey-RPSM]))
,[AgingKey-RPPSD] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPPSD], CHARINDEX('-', b.[AgingKey-RPPSD]), LEN(b.[AgingKey-RPPSD]))
--select r1.PeId, *
from [tblAging.Cr] b
join tblResident r1 on b.ResId = r1.Id and r1.PeId = 39494 --omaha
join tblResident r2 on r1.SystemNo = r2.SystemNo and r2.PeId = 42541 --test omaha


update b
set 
  b.ResId = r2.Id
 ,FacId = pe.Id
 ,Fac = pe.Name
 ,UniqueIdentifier = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.UniqueIdentifier, CHARINDEX('-', b.UniqueIdentifier), LEN(b.UniqueIdentifier))
,[AgingKey-RPPSM] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPPSM], CHARINDEX('-', b.[AgingKey-RPPSM]), LEN(b.[AgingKey-RPPSM]))
,[AgingKey-RPPS] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPPS], CHARINDEX('-', b.[AgingKey-RPPS]), LEN(b.[AgingKey-RPPS]))
,[AgingKey-RPPSD] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPPSD], CHARINDEX('-', b.[AgingKey-RPPSD]), LEN(b.[AgingKey-RPPSD]))
,[AgingKey-RPPSDM] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[AgingKey-RPPSDM], CHARINDEX('-', b.[AgingKey-RPPSDM]), LEN(b.[AgingKey-RPPSDM]))
,[TrackingIdentifier] = CAST(r2.Id AS VARCHAR(20)) + SUBSTRING(b.[TrackingIdentifier], CHARINDEX('-', b.[TrackingIdentifier]), LEN(b.[TrackingIdentifier]))
--select r1.PeId, *
from [tblAging.Bal] b
join tblResident r1 on b.ResId = r1.Id and r1.PeId = 39494 --omaha
join tblResident r2 on r1.SystemNo = r2.SystemNo and r2.PeId = 42541 --test omaha
join tblPhysicalEntity pe on r2.PeId = pe.Id


update c
set c.ResId = r2.Id
--select r1.PeId, *
from [tblAging.BalCaseDetail] c
join tblResident r1 on c.ResId = r1.Id and r1.PeId = 39494 --omaha
join tblResident r2 on r1.SystemNo = r2.SystemNo and r2.PeId = 42541 --test omaha

select b.*
from [tblAging.BalCase] b
join [tblAging.Bal] bal on b.BalId = bal.Id
join tblResident r on bal.ResId = r.Id and r.PeId = 42541 --test omaha

update b
set 
AgingKey = CAST(r.Id AS VARCHAR(20)) + SUBSTRING(b.AgingKey, CHARINDEX('-', b.AgingKey), LEN(b.AgingKey))
--select r1.PeId, *
from [tblAging.BalCase] b
join [tblAging.Bal] bal on b.BalId = bal.Id
join tblResident r on bal.ResId = r.Id and r.PeId = 42541 --test omaha
join tblPhysicalEntity pe on r.PeId = pe.Id

----looks good!!! bh