---todo list:
---AutoNri in stay payor is not done yet look into.


declare @StartSyncing bit


-----------------------------------------------validations first------------------------------------------------------------------------
print 'Running validations...'
declare @nullDsIdCount int = 0

declare @FreeSyncPipeline bit

begin try
-----------------------------------------------end validations------------------------------------------------------------------------

-------------------------------------Prep tables as much as possible for as easy as possible prod intergration----------------------------------------------------------------------------

/*
select *
into #Companies
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].Companies
*/


--start sync
declare @ClientName varchar(50) = 'FCC'
--declare @CLientId int = 1

print 'starting sArTrackSync script at: ' + convert(varchar(100), cast(getdate() as Datetime2 (3)))


-------------------------load all necessary tables localy first one time only-----------------------------------------------
select max(ResponseTime) Timestamp
into ##LatestFullNCSCycle
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].ApiRequestLogs
where Endpoint = 'openMonthDates'


select top 100 *
from ##ResidentBills

select top 1000 *
from ##ResidentStayPayors

select top 1000 *
from ##ResidentStays
-------------------------end load---------------------------------------------------------------------------------------------

select top 5 *
from #Companies

select top 5 *
from ArTrackServer.xTrack.dbo.tblPhysicalEntity

select Id, ShortName Name, Name FriendlyName, ShortName LegacyName, ShortName LogicalName, 3 LevelId, Deleted
into [source].tblPhysicalEntity
from #Companies

select DsId Id, Name, FriendlyName, LegacyName, LogicalName, LevelId, ~Active Deleted
into [target].tblPhysicalEntity
from ArTrackServer.xTrack.dbo.tblPhysicalEntity
where LevelId = 3
and StateId = 1097


--Running SourceGenQuery for tblPerson
select Id, FirstName First, MiddleName Middle, LastName Last, SocialSecurityNumber Social, Case when Gender = 'Male' then 1 else 0 end Male
, DateOfBirth BDate, DateOfDeath EDate, 12 PersonTypeId, CompanyId PeSyncId, Deleted
into [source].tblPerson
from ##Person p

select Id, FirstName First, MiddleName Middle, LastName Last, SocialSecurityNumber Social, Case when Gender = 'Male' then 1 else 0 end Male
, DateOfBirth BDate, DateOfDeath EDate, 12 PersonTypeId, Deleted
into [source].tblPerson
from ##Person p

--Running TargetGenQuery for tblPerson

select p.SyncId Id, First, Middle, Last, Social, Male, BDate, EDate, 12 PersonTypeId, 0 Deleted
into [target].tblPerson
from ArTrackServer.xTrack.dbo.tblPerson p
where 1=1
and p.StateId = 1097

select p.SyncId Id, First, Middle, Last, Social, Male, BDate, EDate, 12 PersonTypeId, pe.SyncId PeSyncId, 0 Deleted
into [target].tblPerson
from ArTrackServer.xTrack.dbo.tblPerson p
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on p.PeId = pe.Id
where 1=1
and p.StateId = 1097

-----------------

-----
--tblresident
------

select top 5 *
from ##Residents


select  top 10 *
from [source].tblResident

select top 5 *
from ArTrackServer.xTrack.dbo.tblResident
where IsPending = 1

IF OBJECT_ID('[source].tblResident') IS NOT NULL DROP TABLE [source].tblResident;
IF OBJECT_ID('[target].tblResident') IS NOT NULL DROP TABLE [target].tblResident;
IF OBJECT_ID('tempdb..##MedicareAEligibility') IS NOT NULL DROP TABLE ##MedicareAEligibility;
IF OBJECT_ID('tempdb..##MedicaidNumber') IS NOT NULL DROP TABLE ##MedicaidNumber;
IF OBJECT_ID('tempdb..##IsPending') IS NOT NULL DROP TABLE ##IsPending;
IF OBJECT_ID('tempdb..##ResStay') IS NOT NULL DROP TABLE ##ResStay;
IF OBJECT_ID('tempdb..##MaxDC') IS NOT NULL DROP TABLE ##MaxDC;
IF OBJECT_ID('tempdb..##ResStayStatus') IS NOT NULL DROP TABLE ##ResStayStatus;
IF OBJECT_ID('tempdb..##ResBed') IS NOT NULL DROP TABLE ##ResBed;


select Id, Id PersonId
, CompanyId PeId
, SystemNumber SystemNo
, IsInCollections InLegal
, 0 IsPending
, cast(null as char) StayStatus
, cast(null as varchar(50)) BedNumber
, cast(null as varchar(50)) McoNum, cast(null as varchar(50)) McaNum
, cast(null as date) AStart, cast(null as date) AEnd, cast(null as date) BStart, cast(null as date) BEnd
, Deleted
into [source].tblResident
from ##Residents


select ref.ResidentId, ref.ReferenceNumber, ref.StartDate, ref.EndDate
into ##MedicareAEligibility
from ##ResidentPayorReferenceNumbers ref
join ##BillableEntities p on ref.PayorId = p.Id
join ##BillingGroups pg on pg.Id = p.BillingGroupId
where pg.Name = 'Medicare'

update r
set 
AStart = StartDate
,AEnd = EndDate
,McaNum = ReferenceNumber
from [source].tblResident r
join ##MedicareAEligibility ref on r.Id = ref.ResidentId

select ref.ResidentId, ref.StartDate, ref.EndDate
into ##MedicareBEligibility
from ##ResidentPartBEligibilities ref

update r
set 
BStart = StartDate
,BEnd = EndDate
from [source].tblResident r
join ##MedicareBEligibility ref on r.Id = ref.ResidentId

select ref.ResidentId, ref.ReferenceNumber, pg.Name
into ##MedicaidNumber
from ##ResidentPayorReferenceNumbers ref
join ##BillableEntities p on ref.PayorId = p.Id
join ##BillingGroups pg on pg.Id = p.BillingGroupId
where pg.Name like '%Medicaid%'

update r
set 
McoNum = ReferenceNumber
from [source].tblResident r
join ##MedicaidNumber ref on r.Id = ref.ResidentId

/*
select * 
from [source].tblResident r
where Id = 909936
*/
/*
IsPending was a simple checkbox in legacy.
But in web the rules are driven by ResidentMedicaidPending as follows:
Any record that has approval date is not deemed pending, period!
Otherwise: if the current date falls between start and end date (if enddate is null it means open enddate) it is pending
*/
select ResidentId, 1 IsPending
into ##IsPending
from ##ResidentMedicaidPending pend
where ApprovalDate is null
and getdate() between StartDate and isnull(EndDate, (getdate()+1))

/*
select * 
from #IsPending pend
join [source].tblResident r on pend.ResidentId = r.Id
join [source].tblPerson p on  p.Id = r.PersonId
join [source].tblPhysicalEntity pe on pe.Id = r. 
*/

update r
set 
IsPending = pend.IsPending
from [source].tblResident r
join ##IsPending pend on r.Id = pend.ResidentId



select *, case when dischargedate is not null then 1 else 0 end IsDC, DischargeDate DischargeDateCalc
into ##ResStay
from ##ResidentStays

update ##ResStay
set DischargeDateCalc = getdate() + 1
where DischargeDateCalc is null


select ResidentId, max(DischargeDateCalc) maxDc
into ##MaxDC
from ##ResStay
group by ResidentId


select rs.ResidentId,
case  
		when r.IsExpired = 1 then 'E' 
		else 
		case when rs.IsDc =1 then 'D' 
		else 'I' 
		end 
	end StayStatus
, rs.Id StayId
into ##ResStayStatus
from ##ResStay rs
join ##MaxDC md on rs.ResidentId = md.ResidentId and rs.DischargeDateCalc = md.maxDc
join ##Resident r on rs.ResidentId = r.Id


update r
set 
	StayStatus = stayStatus.StayStatus
from [source].tblResident r
join ##ResStayStatus stayStatus on r.Id = stayStatus.ResidentId

select ResidentId, b.BedNumber
into ##ResBed
from ##ResStayStatus rs
join ##ResidentStayBeds rsb on rs.StayId = rsb.ResidentStayId
join ##Beds b on b.Id = rsb.BedId
order by ResidentId

update r
set 
	r.BedNumber = rb.BedNumber
from [source].tblResident r
join ##ResBed rb on rb.ResidentId = r.Id

select r.SyncId Id, p.SyncId PersonId, pe.SyncId PeId, SystemNo, InLegal, IsPending, StayStatus, BedNumber, McoNum, McaNum, AStart, AEnd, BStart, BEnd, 0 Deleted
into [target].tblResident
from ArTrackServer.xTrack.dbo.tblResident r
join ArTrackServer.xTrack.dbo.tblPerson p on p.Id = r.PersonId
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on pe.Id = r.PeId
where 1=1
and r.StateId = 1097

select *
from [source].tblResident r

select *
from [target].tblResident r

 
 select stay.Id, ResidentId, AdmitDate Admission, DischargeDate Discharge, case when rv.ShortDescription = 'H' then 1 else 0 end IsBh
 into [source].tblStay
 from ##ResidentStays stay
 join ##ResourceValues rv on stay.RecordTypeId = rv.Id
 where recordtypeId = 9


 select s.SyncId Id, r.SyncId ResidentId, Admission, Discharge, IsBh
 from ArTrackServer.xTrack.dbo.tblStay s
 join ArTrackServer.xTrack.dbo.tblResident r on r.Id = s.ResId



 select *
 from ##Companies


 select Id, ResidentStayId StayId, StartDate, EndDate, IncidentNumber IncidentNum, ExpendedDays
 , PayorId
 , cast(null as varchar(50)) RateCode
 , cast(null as varchar(50)) RefNum
 , cast(null as varchar(50)) AuthNum 
 , null CoPayorId, null CoPay, null CoInsRefNum
 into [source].tblStayPayors
 from ##ResidentStayPayors sp


SELECT
    s.ResidentPayorId StayPayorId,
    bestPayor.*
into ##StayCoPayor
FROM
(
    SELECT DISTINCT ResidentPayorId
    FROM ##ResidentPayorCoinsurers
) s
OUTER APPLY
(
    SELECT TOP 1 p.*
    FROM ##ResidentPayorCoinsurers p
    WHERE p.ResidentPayorId = s.ResidentPayorId
    ORDER BY
        CASE 
            WHEN GETDATE() BETWEEN p.StartDate AND ISNULL(p.EndDate, DATEADD(DAY, 1, GETDATE())) THEN 1
            WHEN p.EndDate < GETDATE() THEN 2
            ELSE 3
        END,
        CASE WHEN GETDATE() BETWEEN p.StartDate AND ISNULL(p.EndDate, DATEADD(DAY, 1, GETDATE())) THEN p.StartDate END DESC,
        CASE WHEN p.EndDate < GETDATE() THEN p.EndDate END DESC,
        CASE WHEN p.StartDate > GETDATE() THEN p.StartDate END ASC
) bestPayor;


update sp
set CoPayorId = scp.PayorId
, CoPay = scp.CoPay
from [source].tblStayPayors sp
join ##StayCoPayor scp on sp.Id = scp.StayPayorId




select *
from ##ResidentStayPayorRateCodes
group by ResidentStayPayorId
having count(*) > 1


select count(*)
from ##ResidentStayPayorRateCodes
group by ResidentStayPayorId
having count(*) > 1


select *
into ##ResidentStayPayorRateCodes
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].ResidentStayPayorRateCodes

 
SELECT
    s.ResidentStayPayorId StayPayorId,
    bestPayor.*
into ##BestRateCode
FROM
(
    SELECT DISTINCT ResidentStayPayorId
    FROM ##ResidentStayPayorRateCodes
) s
OUTER APPLY
(
    SELECT TOP 1 p.*
    FROM ##ResidentStayPayorRateCodes p
    WHERE p.ResidentStayPayorId = s.ResidentStayPayorId
    ORDER BY
        CASE 
            WHEN GETDATE() BETWEEN p.StartDate AND ISNULL(p.EndDate, DATEADD(DAY, 1, GETDATE())) THEN 1
            WHEN p.EndDate < GETDATE() THEN 2
            ELSE 3
        END,
        CASE WHEN GETDATE() BETWEEN p.StartDate AND ISNULL(p.EndDate, DATEADD(DAY, 1, GETDATE())) THEN p.StartDate END DESC,
        CASE WHEN p.EndDate < GETDATE() THEN p.EndDate END DESC,
        CASE WHEN p.StartDate > GETDATE() THEN p.StartDate END ASC
) bestPayor;


update sp
set RateCode = scp.PayorRateCode
from [source].tblStayPayors sp
join ##BestRateCode scp on sp.Id = scp.StayPayorId


update sp
set RefNum = scp.ReferenceNumber
--select *
from [source].tblStayPayors sp
join ##ResidentStays s on sp.StayId = s.Id
join ##ResidentPayorReferenceNumbers scp on (s.ResidentId = scp.ResidentId and sp.PayorId = scp.PayorId)
--where s.ResidentId = 21449

--still needs authnumbers


select top 1000 *
from ##ResidentPayorReferenceNumbers ref
join ##BillableEntities payor on ref.PayorId = payor.Id
where ResidentId = 21449

select *
from ##ResidentStays s 
join ##ResidentStayPayors sp on s.Id = sp.ResidentStayId
join ##StayCoPayor co on sp.Id = co.StayPayorId
where ResidentId = 21449

select * from ##StayCoPayor 

select *
from ##ResidentStays s
join ##ResidentStayPayors sp on s.Id = sp.ResidentStayId
join ##BillableEntities payor on sp.PayorId = payor.Id
where ResidentId = 21449


select top 100 *
from ##ResidentPayorReferenceNumbers

 select top 10 *
 from ##ResidentStayPayors




select * 
from [source].tblStayPayors
where RefNum = '7AK6QF8PK55'

select * 
from [source].tblStay s
join [source].tblStayPayors sp on s.Id = sp.StayId
where ResidentId = 21449



select * from [source].tblStayPayors sp

select *
 from ArTrackServer.xTrack.dbo.tblPayor p
 where LevelId = 7

select top 1000 *
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].BillableEntities






 select top 10 *
 from ArTrackServer.xTrack.dbo.tblStayPayor p
 join ArTrackServer.xTrack.dbo.tblStay s on p.StayId = s.Id
 join ArTrackServer.xTrack.dbo.tblResident r on r.Id = s.ResId
 join ArTrackServer.xTrack.dbo.tblPerson per on per.Id = r.PersonId
 join ArTrackServer.xTrack.dbo.tblphysicalEntity pe on r.PeId = pe.Id
 where isnull(CoInsRefNum, '') <> ''



--tested
--add new facilies
print 'adding new nursing homes'
insert ArTrackServer.xTrack.dbo.tblPhysicalEntity
(Name, LegacyName, LogicalName, DsId, ParentId, LocationId, LevelId)
select substring(cname, CHARINDEX('-', cname)+1,len(cname)-CHARINDEX(cname, '-')) name
, cname, fac.logicalname, fac.nid, isnull(peGroups.Id, @otherId) groupPeId, null
, (select childid from #fac_level) facLevelId
from Global_Facilities fac
left join #_tblPhysicalEntity_temp pe on pe.DsId = fac.nid 
left join Global_FacGroups g on fac.ngroupid = g.nid
left join #_tblPhysicalEntity_temp peGroups on g.nid = peGroups.DsId and peGroups.LevelId = (select childid from #group_level)
where pe.Id is null

select *
into ##client
from ArTrackServer.xTrack.dbo.tblClient
where Abbreviation = @ClientName

exec ArTrackServer.master.dbo.sp_executeSql
N'
select *
into #temp
from xTrack.dbo.vwPeTree

update pe
set 
pe.Depth = tree.Depth
,pe.PeHierarchyPath = tree.PeHierarchyPath
,pe.PeIdHierarchyPath = tree.PeIdHierarchyPath
,pe.CalculatedActiveness = tree.CalculatedActiveness
,pe.StateId = case when tree.CalculatedActiveness = 1 then 1097 else 1098 end
from xTrack.dbo.tblPhysicalEntity pe
join #temp tree on pe.Id = tree.Id

drop table #temp

'

drop table #_tblPhysicalEntity_temp

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
--bad
print 'updating nursing homes'
--tested
update pe
set Name = substring(cname, CHARINDEX('-', cname)+1,len(cname)-CHARINDEX(cname, '-'))
, LegacyName = cname
, LogicalName = fac.logicalname
--select *
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
join ArTrackServer.xTrack.dbo.tblClient client on pe.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
join Global_Facilities fac on pe.DsId = fac.nid
where pe.LevelId = (select ChildId from #fac_level)
and client.Abbreviation = @ClientName

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'


exec ArTrackServer.master.dbo.sp_executeSql
N'
select *
into #temp
from xTrack.dbo.vwPeTree

update pe
set 
pe.Depth = tree.Depth
,pe.PeHierarchyPath = tree.PeHierarchyPath
,pe.PeIdHierarchyPath = tree.PeIdHierarchyPath
,pe.CalculatedActiveness = tree.CalculatedActiveness
,pe.StateId = case when tree.CalculatedActiveness = 1 then 1097 else 1098 end
from xTrack.dbo.tblPhysicalEntity pe
join #temp tree on pe.Id = tree.Id

drop table #temp

'



--bad
print 'updating nursing homes groups'
update pe
set pe.ParentId = isnull(peParent.Id,other.Id)
--select *
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
join ArTrackServer.xTrack.dbo.tblClient client on  pe.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
join Global_Facilities fac on pe.DsId = fac.nid
left join Global_FacGroups groups on fac.ngroupid = groups.nid
left join ArTrackServer.xTrack.dbo.tblPhysicalEntity peParent on (peParent.DsId = groups.nid and peParent.LevelId = (select ChildId from #group_level))
,#other other
where pe.LevelId = (select ChildId from #fac_level)
and client.Abbreviation = @ClientName

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select *
into #temp
from xTrack.dbo.vwPeTree

update pe
set 
pe.Depth = tree.Depth
,pe.PeHierarchyPath = tree.PeHierarchyPath
,pe.PeIdHierarchyPath = tree.PeIdHierarchyPath
,pe.CalculatedActiveness = tree.CalculatedActiveness
,pe.StateId = case when tree.CalculatedActiveness = 1 then 1097 else 1098 end
from xTrack.dbo.tblPhysicalEntity pe
join #temp tree on pe.Id = tree.Id

drop table #temp

'


print 'updating groups parent'
update pe
set pe.ParentId = root.Id
--select *
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
join ArTrackServer.xTrack.dbo.tblClient client on  pe.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
,#root root
where pe.LevelId = (select ChildId from #group_level)
and pe.Name <> 'Root'
and pe.ParentId is null
and client.Abbreviation = @ClientName
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select *
into #temp
from xTrack.dbo.vwPeTree

update pe
set 
pe.Depth = tree.Depth
,pe.PeHierarchyPath = tree.PeHierarchyPath
,pe.PeIdHierarchyPath = tree.PeIdHierarchyPath
,pe.CalculatedActiveness = tree.CalculatedActiveness
,pe.StateId = case when tree.CalculatedActiveness = 1 then 1097 else 1098 end
from xTrack.dbo.tblPhysicalEntity pe
join #temp tree on pe.Id = tree.Id

drop table #temp

'

--bad
print 'updating nursing homes active status based on ds fac list as well as dead fac criteria'
update pe
set Active = 0
--select *
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
join ArTrackServer.xTrack.dbo.tblClient client on  pe.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
left join Global_Facilities gf on pe.DsId = gf.nid
left join facility fac on fac.FacId = gf.nid and lisclient =1
left join FacTableException exc on pe.DsId = exc.FacId
where pe.LevelId = 3 
and pe.Name not like 'Training%'
and (gf.nid is null or fac.cid is null) and exc.FacId is null
and client.Abbreviation = @ClientName

--bad
update pe
set Active = 1
--select *
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
join ArTrackServer.xTrack.dbo.tblClient client on  pe.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
left join Global_Facilities gf on pe.DsId = gf.nid
left join facility fac on fac.FacId = gf.nid and lisclient =1
where pe.LevelId = 3
and gf.nid is not null and fac.cid is not null
and client.Abbreviation = @ClientName

----adding bed count to active fac
print 'updating capacity'

select pe.Id, ncapacity Capacity
into #capacity
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
join ArTrackServer.xTrack.dbo.tblClient client on  pe.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
left join Global_Facilities gf on pe.DsId = gf.nid
left join facility fac on fac.FacId = gf.nid and lisclient =1
left join FacTableException exc on pe.DsId = exc.FacId
where pe.LevelId = 3
and pe.Name not like 'Training%'
and gf.nid is not null and fac.cid is not null
and client.Abbreviation = @ClientName

update pe
set Capacity = cap.Capacity
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
join #capacity cap on pe.Id = cap.Id

print 'de-activating empty groups'

update ArTrackServer.xTrack.dbo.tblPhysicalEntity
set Active =0
where Id in(
	select parent.Id
	from ArTrackServer.xTrack.dbo.tblPhysicalEntity parent
	join ArTrackServer.xTrack.dbo.tblClient client on  parent.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
	where parent.LevelId = 2
	and not exists (select 'x' from ArTrackServer.xTrack.dbo.tblPhysicalEntity child where ParentId = parent.Id and child.Active = 1)
	and parent.Name <> 'Root'
	and client.Abbreviation = @ClientName
)

print 'de-activating groups with no parents'
update ArTrackServer.xTrack.dbo.tblPhysicalEntity
set Active =0
where Id in(
	select parent.Id
	from ArTrackServer.xTrack.dbo.tblPhysicalEntity parent
	join ArTrackServer.xTrack.dbo.tblClient client on  parent.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
	where parent.LevelId = 2
	and parent.ParentId is null
	and parent.Name <> 'Root'
	and client.Abbreviation = @ClientName
)

print 'activating all other groups'
--bad
update ArTrackServer.xTrack.dbo.tblPhysicalEntity
set Active =1
where Id in(
	select parent.Id
	from ArTrackServer.xTrack.dbo.tblPhysicalEntity parent
	join ArTrackServer.xTrack.dbo.tblClient client on  parent.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
	where parent.LevelId = 2
	and exists (select 'x' from ArTrackServer.xTrack.dbo.tblPhysicalEntity child where ParentId = parent.Id and child.Active = 1)
	and parent.Name <> 'Root'
	and client.Abbreviation = @ClientName
)

--tested
----update fac locations
print 'updating nursing home locations'
update ArTrackServer.xTrack.dbo.tblPhysicalEntity
set LocationId = loc.Id
--select pe.name, adrs.*, post.*, cstate
--select *
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
join Global_Facilities gf on pe.DsId = gf.nid
join facility as fac on fac.FacId = gf.nid and lisclient =1
join [dbo].[address] adrs on (fac.cid collate Latin1_General_CS_AS= adrs.cownerfk collate Latin1_General_CS_AS and adrs.cownerfk = fac.cid and adrs.FacId = fac.FacId  and adrs.cownertable = 'ncs!facility')
join addrpost post on (adrs.cid collate Latin1_General_CS_AS= post.caddressid collate Latin1_General_CS_AS and adrs.FacId = post.FacId)
join ArTrackServer.xTrack.dbo.tblLocation loc on (post.cstate collate SQL_Latin1_General_CP1_CI_AS = loc.Abbreviation collate SQL_Latin1_General_CP1_CI_AS and loc.LevelId = 10)
join ArTrackServer.xTrack.dbo.tblClient client on  pe.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
where pe.LevelId = 3
and client.Abbreviation = @ClientName
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select *
into #temp
from xTrack.dbo.vwPeTree

update pe
set 
pe.Depth = tree.Depth
,pe.PeHierarchyPath = tree.PeHierarchyPath
,pe.PeIdHierarchyPath = tree.PeIdHierarchyPath
,pe.CalculatedActiveness = tree.CalculatedActiveness
,pe.StateId = case when tree.CalculatedActiveness = 1 then 1097 else 1098 end
from xTrack.dbo.tblPhysicalEntity pe
join #temp tree on pe.Id = tree.Id

drop table #temp

'

--get 3rd party fac
--tested
print 'adding 3rd party facilities'
insert ArTrackServer.xTrack.dbo.tblPhysicalEntity
(Name, LegacyName, LogicalName, DsNvcId, ParentId, LocationId, LevelId)
select 
  f.cname collate SQL_Latin1_General_CP1_CI_AS cname
, f.cname collate SQL_Latin1_General_CP1_CI_AS, f.cname collate SQL_Latin1_General_CP1_CI_AS
, f.cid dsid
, parent.Id, null, nvh.ChildId
from facility f
left join ArTrackServer.xTrack.dbo.tblPhysicalEntity parent on f.FacId = parent.DsId 
left join ArTrackServer.xTrack.dbo.tblPhysicalEntity child on 
					(f.cname collate SQL_Latin1_General_CP1_CI_AS  = child.Name collate SQL_Latin1_General_CP1_CI_AS and child.ParentId = parent.Id )															
join ArTrackServer.xTrack.dbo.tblClient client on  child.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
, ArTrackServer.xTrack.dbo.NameValueHierarchy nvh
where 1=1
and child.Id is null 
and lisclient = 0
and nvh.ParentName = 'PeLevel' and nvh.ChildName = '3rdPartyFacility'
and client.Abbreviation = @ClientName

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
exec ArTrackServer.master.dbo.sp_executeSql
N'
select *
into #temp
from xTrack.dbo.vwPeTree

update pe
set 
pe.Depth = tree.Depth
,pe.PeHierarchyPath = tree.PeHierarchyPath
,pe.PeIdHierarchyPath = tree.PeIdHierarchyPath
,pe.CalculatedActiveness = tree.CalculatedActiveness
,pe.StateId = case when tree.CalculatedActiveness = 1 then 1097 else 1098 end
from xTrack.dbo.tblPhysicalEntity pe
join #temp tree on pe.Id = tree.Id

drop table #temp

'

print 'creating #_tblPhysicalEntity'
select pe.*
into #_tblPhysicalEntity
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
left join FacTableException fte on pe.DsId = fte.FacId and pe.LevelId = 3
join ArTrackServer.xTrack.dbo.tblClient client on  pe.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
where fte.FacId is null 
and (pe.LevelId = 2 or pe.LevelId = 3)
and client.Abbreviation = @ClientName
order by LevelId, Id


---deactivate any zzz facility
update ArTrackServer.xTrack.dbo.tblPhysicalEntity
set InactiveOverride =1
where Id in(
	select pe.Id
	from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
	join ArTrackServer.xTrack.dbo.tblClient client on  pe.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
	where pe.LevelId < 5
	and pe.LegacyName like '%zzz%'
	and client.Abbreviation = @ClientName
)

exec ArTrackServer.master.dbo.sp_executeSql
N'

select *
into #temp
from xTrack.dbo.vwPeTree

update pe
set 
pe.Depth = tree.Depth
,pe.PeHierarchyPath = tree.PeHierarchyPath
,pe.PeIdHierarchyPath = tree.PeIdHierarchyPath
,pe.CalculatedActiveness = tree.CalculatedActiveness
,pe.StateId = case when tree.CalculatedActiveness = 1 then 1097 else 1098 end
from xTrack.dbo.tblPhysicalEntity pe
join #temp tree on pe.Id = tree.Id

drop table #temp

'

delete from #_tblPhysicalEntity

IF OBJECT_ID('tempdb..##insertPuUser') IS NOT NULL
begin
print 'dropping ##insertPuUser'
drop table ##insertPuUser
end

IF OBJECT_ID('tempdb..##deletePuUser') IS NOT NULL
begin
print 'dropping ##deletePuUser'
drop table ##deletePuUser
end

IF OBJECT_ID('tempdb..#_tblPeUserTree_raw') IS NOT NULL
begin
print 'dropping #_tblPeUserTree_raw'
drop table #_tblPeUserTree_raw
end
 
IF OBJECT_ID('tempdb..#_tblPeUserTree') IS NOT NULL
begin
print 'dropping #_tblPeUserTree'
drop table #_tblPeUserTree
end

IF OBJECT_ID('tempdb..#vwUserTree_raw') IS NOT NULL
begin
print 'dropping #vwUserTree_raw'
drop table #vwUserTree_raw
end

IF OBJECT_ID('tempdb..#vwUserTree') IS NOT NULL
begin
print 'dropping #vwUserTree'
drop table #vwUserTree
end

print 'creating #_tblPhysicalEntity'
insert into #_tblPhysicalEntity
select pe.*
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
left join FacTableException fte on pe.DsId = fte.FacId and pe.LevelId = 3
join ArTrackServer.xTrack.dbo.tblClient client on  pe.PeIdHierarchyPath like '%|' + convert(varchar(250),client.PeId) + '|%'
where fte.FacId is null 
and (pe.LevelId = 2 or pe.LevelId = 3)
and client.Abbreviation = @ClientName
order by LevelId, Id

select tree.*
into #_tblPeUserTree_raw 
from ArTrackServer.xTrack.dbo.tblPeUserTree tree

select tree.*
into #_tblPeUserTree
from #_tblPeUserTree_raw tree
join #_tblPhysicalEntity pe on tree.PeId = pe.Id

select *
into #vwUserTree_raw
from ArTrackServer.xTrack.dbo.vwUserAccess tree

select tree.*
into #vwUserTree
from #vwUserTree_raw tree
join #_tblPhysicalEntity pe on tree.PeId = pe.Id

select tree.*
into ##deletePuUser 
from #_tblPeUserTree tree
left join #vwUserTree newTree on tree.PeId = newTree.PeId and tree.UserId = newTree.UserId
where newTree.UserId is null

select u.*
into ##insertPuUser 
from #vwUserTree u
left join #_tblPeUserTree tree on tree.PeId = u.PeId and tree.UserId = u.UserId 
where tree.PeId is null

exec ArTrackServer.master.dbo.sp_executeSql
N'

select * 
into #deletePuUser
FROM OPENQUERY(ArTrackSyncServer,''select * from ##deletePuUser'')

select * 
into #insertPuUser
FROM OPENQUERY(ArTrackSyncServer,''select * from ##insertPuUser'')

delete from tree
from xTrack.dbo.tblPeUserTree tree
join #deletePuUser del on tree.PeId = del.PeId and tree.UserId = del.UserId

insert xTrack.dbo.tblPeUserTree
select distinct *
from #insertPuUser
'

--end new section-keeping tree info up to date


-------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------end update pe's----------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------

print 'adding payor groups'
--insert missing payor groups
--this should almost never inject any new data but just in case
--tested
insert ArTrackServer.xTrack.dbo.tblPayor
(Code, Name, FriendlyName, LevelId, ParentId)
select distinct cid, cdesc, cdesc, nvh.ChildId, roott.Id
from payorgroups g
left join ArTrackServer.xTrack.dbo.tblPayor p on (g.cid = p.Code collate Latin1_General_CI_AS and (g.cdesc collate Latin1_General_CI_AS = p.Name collate Latin1_General_CI_AS or g.cdesc collate Latin1_General_CI_AS = p.FriendlyName collate Latin1_General_CI_AS))
,  ArTrackServer.xTrack.dbo.NameValueHierarchy nvh
,  ArTrackServer.xTrack.dbo.tblPayor roott
where p.Id is null
and nvh.ParentName = 'PayorLevel' and nvh.ChildName = 'Category'
and roott.ParentId is null and roott.Name = 'Root'
and cdesc <> 'Private Pay'
and cdesc <> 'HMO/Private Insurance'
and cdesc <> 'Adult Day Care'
and cdesc <> 'Assisted Living Facility'
and cdesc not like '%Medicaid%'

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

IF OBJECT_ID('tempdb..#_tblNameValue') IS NOT NULL
begin
print 'dropping #_tblNameValue'
drop table #_tblNameValue
end

select *
into #_tblNameValue
from ArTrackServer.xTrack.dbo.tblNameValue

select nv.Id, nv.Name
into #facLevel
from #_tblNameValue nv
join #_tblNameValue nvParent on nv.ParentId = nvParent.Id
where nvParent.Name = 'PeLevel' and nv.Name ='fac'

select *
into #_tblPayor_PreProcess
from ArTrackServer.xTrack.dbo.tblPayor p


select p.*, pe.PeIdHierarchyPath
into #_tblPayorForInsertQuery
from #_tblPayor_PreProcess p
left join #_tblPhysicalEntity pe on p.PeId = pe.Id
where 1=1 and (p.PeId = pe.Id or p.PeId is null)
---end these should only need run once--------------
--tested
---put in all the payors 
--change in the design: payors are no longer attached to a fac, and do not repeate only one payor code/name 
print 'adding payors'
insert ArTrackServer.xTrack.dbo.tblPayor
(Code, Name, FriendlyName, ParentId, LocationId, LevelId, PeId, DsId)
select distinct cpayorcode collate Latin1_General_CI_AS, ps.cname collate Latin1_General_CI_AS, ps.cname collate Latin1_General_CI_AS, nhparent.Id, null, nvh.ChildId, pe.Id, ps.DsId
from payors ps
join Global_Facilities fac on ps.FacId = fac.nid
left join #_tblPayorForInsertQuery px on ps.DsId = px.DsId
left join #_tblPayorForInsertQuery nhparent on (ps.cpayorgrid collate Latin1_General_CI_AS = nhparent.Code collate Latin1_General_CI_AS and nhparent.LevelId < 7)
left join #_tblPhysicalEntity pe on ((fac.nid  =pe.DsId) and pe.LevelId = (select Id from #facLevel))
, ArTrackServer.xTrack.dbo.NameValueHierarchy nvh
where 1=1
and isnull(ps.cpayorcode, '') <> '' and isnull(ps.cname,'') <> '' and isnull(ps.cname,'')<> ''
and px.Id is null
and nvh.ParentName = 'PayorLevel' and nvh.ChildName = 'Payor'

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

drop table #facLevel
drop table #_tblPayor_PreProcess
drop table #_tblPayorForInsertQuery
------------------------------------------------------------

IF OBJECT_ID('tempdb..#_tblPayor') IS NOT NULL
begin
print 'dropping #_tblPayor'
drop table #_tblPayor
end

IF OBJECT_ID('tempdb..##payors_update') IS NOT NULL
begin
print 'dropping ##payors_update'
drop table ##payors_update
end

print 'creating #_tblPayor'

select payor.*
into #_tblPayor
from ArTrackServer.xTrack.dbo.tblPayor payor
left join #_tblPhysicalEntity pe on payor.PeId = pe.Id
where 1=1 and (payor.PeId = pe.Id or payor.PeId is null)

select cid, cname, px.Id
into ##payors_update
from payors p
join #_tblPayor px on p.DsId = px.DsId
where 1=1
and(
	p.cid collate Latin1_General_CI_AS <> px.code
or	p.cname collate Latin1_General_CI_AS <> px.name
)

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #payors_update
FROM OPENQUERY(ArTrackSyncServer,''select * from ##payors_update'')

update payor
set Code = cid
, Name = cname
, FriendlyName = cname
from xTrack.dbo.tblPayor payor
join #payors_update pu on payor.Id = pu.Id
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'refreshing #_tblPayor'

delete from #_tblPayor

insert #_tblPayor
select payor.*
from ArTrackServer.xTrack.dbo.tblPayor payor
left join #_tblPhysicalEntity pe on payor.PeId = pe.Id
where 1=1 and (payor.PeId = pe.Id or payor.PeId is null)


IF OBJECT_ID('tempdb..##_payorCat_update') IS NOT NULL
begin
print 'dropping ##_payorCat_update'
drop table ##_payorCat_update
end

select child.id payorId, newCat.id newParentId
into ##_payorCat_update
from #_tblPayor child
join #_tblPayor parent on child.ParentId = parent.Id
join payors p on child.DsId = p.DsId
join #_tblPayor newCat on (p.cpayorgrid collate Latin1_General_CS_AS = newCat.code collate Latin1_General_CS_AS and parent.LevelId < 7)
where parent.code collate Latin1_General_CS_AS <> p.cpayorgrid collate Latin1_General_CS_AS

	exec ArTrackServer.master.dbo.sp_executeSql
	N'
	select * 
	into #_payorCat_update
	FROM OPENQUERY(ArTrackSyncServer,''select * from ##_payorCat_update'')

	update payor
	set parentId = pu.newParentId
	from xTrack.dbo.tblPayor payor
	join #_payorCat_update pu on payor.Id = pu.payorId

	'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'refreshing #_tblPayor'
delete from #_tblPayor

insert #_tblPayor
select payor.*
from ArTrackServer.xTrack.dbo.tblPayor payor
left join #_tblPhysicalEntity pe on payor.PeId = pe.Id
where 1=1 and (payor.PeId = pe.Id or payor.PeId is null)

---end payors

declare @resultCount int = 0

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

IF OBJECT_ID('tempdb..#_NameValueHierarchy') IS NOT NULL
begin
print 'dropping #_NameValueHierarchy'
drop table #_NameValueHierarchy
end

print 'creating #_NameValueHierarchy'
select * 
into #_NameValueHierarchy
from ArTrackServer.xTrack.dbo.NameValueHierarchy
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

------------------------------------person-----------------------------------------------
IF OBJECT_ID('tempdb..#_tblPerson_raw') IS NOT NULL
begin
print 'dropping #_tblPerson_raw'
drop table #_tblPerson_raw
end


IF OBJECT_ID('tempdb..#_tblPerson') IS NOT NULL
begin
print 'dropping #_tblPerson'
drop table #_tblPerson
end

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'creating #_tblPerson_raw'
select person.*
into #_tblPerson_raw
from ArTrackServer.xTrack.dbo.tblPerson person

print 'creating #_tblPerson'
select person.*
into #_tblPerson
from #_tblPerson_raw person
join #_tblPhysicalEntity pe on person.PeId = pe.Id

IF OBJECT_ID('tempdb..#_people') IS NOT NULL
begin
print 'dropping #_people'
drop table #_people
end

print 'creating #_people'
select *
into #_people
from people
where 1=1
and isnull(cperstype, 'H') = 'R'


IF OBJECT_ID('tempdb..##_tblPerson_insert') IS NOT NULL
begin
print 'dropping ##_tblPerson_insert'
DROP TABLE ##_tblPerson_insert
end

print 'compiling #_tblPerson_insert'

select distinct pe.Id, p.DsId, cfirst, clast, isnull(cmiddle,'') cmiddle, p.cssn, p.dbirth, nvh.ChildId resTypeId, p.male
into ##_tblPerson_insert
from #_people p
join Global_Facilities fac on p.FacId = fac.nid
join #_tblPhysicalEntity pe on fac.nid = pe.DsId and pe.LevelId = 3
left join #_tblPerson person on p.DsId = person.DsId 
, #_NameValueHierarchy nvh
where 1=1
and nvh.ParentName = 'PersonType' and nvh.ChildName = 'Resident'
and clast is not null and clast <> '' and clast <> 'UnKnown' 
and not ISNUMERIC(clast) >0
and not ISNUMERIC(cfirst) >0
and clast not like '%not use%'
and lower(clast) not like '%zzzz%'
and (LEN(REPLACE(upper(clast), LEFT(upper(clast),1),'')) <> 0 or cfirst = 'Yeong')
and not(clast = cfirst and cssn = '')
and person.Id is null

select @resultCount = @@ROWCOUNT

print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
print 'using ##_tblPerson_insert to add new entries to live'

--persons
--tested
exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblPerson_insert
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblPerson_insert'')

insert xTrack.dbo.tblPerson
(PeId, DsId, First, Last, Middle, Social, BDate, PersonTypeId, Male)
select *
from #_tblPerson_insert
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
end
else
print '##_tblPerson_insert is empty'

delete from #_tblPerson_raw
delete from #_tblPerson

insert into #_tblPerson_raw
select person.*
from ArTrackServer.xTrack.dbo.tblPerson person

print 'creating #_tblPerson'
insert into #_tblPerson
select person.*
from #_tblPerson_raw person
join #_tblPhysicalEntity pe on person.PeId = pe.Id


print convert(varchar(50), @@ROWCOUNT) + ' rows affected'


IF OBJECT_ID('tempdb..##_tblPerson_update_main') IS NOT NULL
begin
print 'dropping ##_tblPerson_update_main'
DROP TABLE ##_tblPerson_update_main
end

set @resultCount = 0

print 'compiling #_tblPerson_update_main'
select p.DsId, p.cfirst, p.clast, isnull(p.cmiddle,'') cmiddle, p.dbirth, p.cssn, p.male
into ##_tblPerson_update_main
from #_tblPerson person
join #_people p on person.DsId = p.DsId
where 1=1
and (person.First collate Latin1_General_CS_AS <> p.cfirst
or person.Last collate Latin1_General_CS_AS <> p.clast
or isnull(person.Middle,'') collate Latin1_General_CS_AS <> isnull(p.cmiddle,'')
or person.BDate  <> p.dbirth
or person.Social collate Latin1_General_CS_AS <> p.cssn
or (person.Male <> p.male)
)

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
print 'using ##_tblPerson_update_main to update live'
--update all person data
--tested

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblPerson_update_main
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblPerson_update_main'')

update person
set 
 First = pupdate.cfirst
,Last = pupdate.clast
,Middle = pupdate.cmiddle
,BDate = pupdate.dbirth
,Social = pupdate.cssn
,Male = pupdate.male
from xTrack.dbo.tblPerson person
join #_tblPerson_update_main pupdate on person.DsId = pupdate.DsId
'
end
else
print '##_tblPerson_update_main is empty'


IF OBJECT_ID('tempdb..##_tblPerson_update_edate') IS NOT NULL
begin
print 'dropping ##_tblPerson_update_edate'
DROP TABLE ##_tblPerson_update_edate
end

print 'compiling #_tblPerson_update_edate'
select p.DsId, p.edate
into ##_tblPerson_update_edate
from #_tblPerson person
join #_people p on person.DsId = p.DsId
join resdents r on (r.cpeopleid = p.cid and r.FacId = p.FacId)
where isnull(person.EDate, '1/1/1000')<>isnull(p.edate, '1/1/1000')

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
print 'using ##_tblPerson_update_edate to update live'


exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblPerson_update_edate
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblPerson_update_edate'')

update person
set 
EDate = pupdate.edate
from xTrack.dbo.tblPerson person
join #_tblPerson_update_edate pupdate on person.DsId = pupdate.DsId
'
end
else
print '##_tblPerson_update_edate is empty'

print 'cleaning up #_tblPerson_update_edate'
drop table ##_tblPerson_update_edate

IF OBJECT_ID('tempdb..##_tblPerson_delete') IS NOT NULL
begin
print 'dropping ##_tblPerson_delete'
DROP TABLE ##_tblPerson_delete
end

delete from #_tblPerson_raw
delete from #_tblPerson

insert into #_tblPerson_raw
select person.*
from ArTrackServer.xTrack.dbo.tblPerson person

print 'creating #_tblPerson'
insert into #_tblPerson
select person.*
from #_tblPerson_raw person
join #_tblPhysicalEntity pe on person.PeId = pe.Id

print 'creating ##_tblPerson_delete to erase DsId from persons who no longer exist in NCS.'
select xp.*
into ##_tblPerson_delete
from #_tblPerson xp
join #_tblPhysicalEntity pe on xp.PeId = pe.Id
left join #_people p on xp.DsId = p.DsId 
where p.DsId is null
and xp.DsId is not null
and pe.CalculatedActiveness = 1

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'


exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblPerson_delete
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblPerson_delete'')

select * 
into #client
FROM OPENQUERY(ArTrackSyncServer,''select * from ##client'')

insert xTrack.dbo.tblSyncHistory (CodeBlockId,Comment,ClientId)
select nvh.ChildId, ''Person does not exist in NCS, we removed DsId from this person record. PersonId: '' + convert(varchar(MAX),per.Id) 
+ '', PersonDsId: '' + isnull(convert(varchar(MAX),per.DsId, 2),''NULL'') + '', PeId: '' + convert(varchar(MAX),per.PeId) + '', PeName: '' + pe.Name 
+ '', PersonName: '' + isnull(per.Last,''NULL'') + '', '' + isnull(per.First,''NULL'')
+ '', BDate: '' + isnull(convert(varchar(MAX),per.BDate),''NULL'') + '', Social: '' + isnull(per.Social,''NULL''), c.Id
from #_tblPerson_delete per
join xTrack.dbo.tblPhysicalEntity pe on per.PeId = pe.Id
join #client c on 1=1
, xTrack.dbo.NameValueHierarchy nvh
where nvh.ParentName = ''SyncComments.CodeBlock'' and nvh.ChildName = ''PersonMismatch''

update person
set 
DsId = NULL
from xTrack.dbo.tblPerson person
join #_tblPerson_delete pdelete on person.Id = pdelete.Id
'

set @resultCount =0
--res
--tested
delete from #_NameValueHierarchy

delete from #_tblPerson_raw
delete from #_tblPerson

IF OBJECT_ID('tempdb..#_tblResident_raw') IS NOT NULL
begin
print 'dropping #_tblResident_raw'
DROP TABLE #_tblResident_raw
end

IF OBJECT_ID('tempdb..#_tblResident') IS NOT NULL
begin
print 'dropping #_tblResident'
DROP TABLE #_tblResident
end

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
IF OBJECT_ID('tempdb..##_tblResident_insert') IS NOT NULL
begin
print 'dropping ##_tblResident_insert'
DROP TABLE ##_tblResident_insert
end

print 'creating #_NameValueHierarchy'
insert into #_NameValueHierarchy
select * 
from ArTrackServer.xTrack.dbo.NameValueHierarchy
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

insert into #_tblPerson_raw
select person.*
from ArTrackServer.xTrack.dbo.tblPerson person

print 'creating #_tblPerson'
insert into #_tblPerson
select person.*
from #_tblPerson_raw person
join #_tblPhysicalEntity pe on person.PeId = pe.Id

select res.*
into #_tblResident_raw
from ArTrackServer.xTrack.dbo.tblResident res

select res.*
into #_tblResident
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'compiling #_tblResident_insert'
select res.DsId DsId, person.Id personId, res.nsystemno, person.PeId peId, cmcaidno, cmcareno, lmedpending, nvh.ChildId, res.InLegal
into ##_tblResident_insert
from resdents res
join #_people p on (res.cpeopleid = p.cid and res.FacId = p.FacId)
join #_tblPerson person on person.DsId = p.DsId 
left join #_tblResident tblr on res.DsId = tblr.DsId
,#_NameValueHierarchy nvh
where 1=1
and tblr.DsId is null
and nvh.ChildName = 'Active' and nvh.ParentName = 'Global.App.Data.Record.State'

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin

print 'using ##_tblResident_insert to update tblResident in live'
--add the new residents
exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblResident_insert
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblResident_insert'')

insert xTrack.dbo.tblResident
(DsId, PersonId, SystemNo, PeId, McoNum, McaNum, IsPending, StateId, InLegal)
select *
from #_tblResident_insert

'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

end
else 
print'##_tblResident_insert is empty no need to use in live'


delete from #_tblResident_raw
delete from #_tblResident

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

IF OBJECT_ID('tempdb..##_tblResident_update') IS NOT NULL
begin
print 'dropping ##_tblResident_update'
DROP TABLE ##_tblResident_update
end

print 'creating #_tblResident'


insert into #_tblResident_raw
select res.*
from ArTrackServer.xTrack.dbo.tblResident res

insert into #_tblResident
select res.*
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id


print 'compiling #_tblResident_update to update tblResident in live'
select res.DsId, res.cmcareno medicareNo, cmcaidno medicaidNo, res.nsystemno, res.lmedpending, res.InLegal
into ##_tblResident_update
from #_tblResident resident
join resdents res on res.DsId = resident.DsId
where 1=1 and(
McaNum collate Latin1_General_CS_AS <> res.cmcareno
or McoNum collate Latin1_General_CS_AS <> res.cmcaidno
or SystemNo <> res.nsystemno
or isnull(IsPending,'') <> isnull(res.lmedpending,'')
or isnull(resident.InLegal,'') <> isnull(res.InLegal,'')
)
set @resultCount =0

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'
if @resultCount > 0
begin
print 'using ##_tblResident_update to update tblResident in live'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblResident_update
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblResident_update'')

update res
set 
  res.McaNum = resUpdate.medicareNo
, res.McoNum = resUpdate.medicaidNo
, res.SystemNo = resUpdate.nsystemno
, res.IsPending = resUpdate.lmedpending
, res.InLegal = resUpdate.InLegal
from xTrack.dbo.tblResident res
join #_tblResident_update resUpdate on res.DsId = resUpdate.DsId 
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
end
else
print '##_tblResident_update is empty no need to use'


print 'droping ##_tblResident_update'
drop table ##_tblResident_update

IF OBJECT_ID('tempdb..##_tblResident_updatePersonId') IS NOT NULL
begin
print 'dropping ##_tblResident_updatePersonId'
DROP TABLE ##_tblResident_updatePersonId
end

set @resultCount =0

select distinct xRes.Id ResidentId, xRes.DsId ResDsId, xRes.PeId ResPeId, isnull(xRes.McaNum,'NULL') MedicareNo, isnull(xRes.McoNum,'NULL') MedicaidNo
, correctPerson.Id PersonId, correctPerson.DsId PersonDsId, isnull(correctPerson.Last,'') + ', ' + isnull(correctPerson.First,'NULL') PersonName
, correctPerson.BDate PersonBDate, correctPerson.Social PersonSocial, wrongPerson.Id OriginalPersonId, wrongPerson.DsId OriginalPersonDsId
, isnull(wrongPerson.Last,'NULL') + ', ' + isnull(wrongPerson.First,'NULL') OriginalPersonName, wrongPerson.BDate OriginalPersonBDate, wrongPerson.Social OriginalPersonSocial
into ##_tblResident_updatePersonId
from #_tblResident xRes 
join resdents res on xRes.DsId = res.DsId 
join #_people p on (res.cpeopleid = p.cid and res.FacId = p.FacId)
join #_tblPerson wrongPerson on xRes.PersonId = wrongPerson.Id 
join #_tblPerson correctPerson on p.DsId = correctPerson.DsId
where 1=1
and p.DsId <> wrongPerson.DsId

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
print 'RED FLAG ALERT: Had wrong person for the resident - need to use ##_tblResident_updatePersonId to update person in tblResident in live'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblResident_updatePersonId
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblResident_updatePersonId'')

select * 
into #client
FROM OPENQUERY(ArTrackSyncServer,''select * from ##client'')

insert xTrack.dbo.tblSyncHistory (CodeBlockId,Comment,ClientId)
select nvh.ChildId, '' Res Table is pointing to wrong PersonId, we updated the PersonId in res table. ResId: '' + convert(varchar(MAX),res.ResidentId) 
+ '', ResDsId: '' + isnull(convert(varchar(MAX),res.ResDsId, 2),''NULL'') + '', ResPeId: '' + convert(varchar(MAX),res.ResPeId) + '', ResPeName: '' + pe.Name
+ '', MedicareNo: '' + res.MedicareNo + '', MedicaidNo: '' + res.MedicaidNo 
+ '', PersonId: '' + convert(varchar(MAX),res.PersonId) + '', PersonDsId: '' + isnull(convert(varchar(MAX),res.PersonDsId, 2),''NULL'') + '' PersonName: '' + isnull(res.PersonName,''NULL'')
+ '', PersonBDate: '' + isnull(convert(varchar(MAX),res.PersonBDate),''NULL'') + '', PersonSocial: '' + isnull(res.PersonSocial,''NULL'') 
+ '', OriginalPersonId: '' + convert(varchar(MAX),res.OriginalPersonId) + '', OriginalPersonDsId: '' + isnull(convert(varchar(MAX),res.OriginalPersonDsId, 2),''NULL'')
+ '', OriginalPersonName: '' + isnull(res.OriginalPersonName,''NULL'') + '', OriginalPersonBDate: '' + isnull(convert(varchar(MAX),res.OriginalPersonBDate),''NULL'')
+ '', OriginalPersonSocial: '' + isnull(res.OriginalPersonSocial,''NULL''), c.Id
from #_tblResident_updatePersonId res
join xTrack.dbo.tblPhysicalEntity pe on res.ResPeId = pe.Id
join #client c on 1=1
, xTrack.dbo.NameValueHierarchy nvh
where nvh.ParentName = ''SyncComments.CodeBlock'' and nvh.ChildName = ''ResPersonIdMismatch''

update res
set 
  res.PersonId = resUpdate.PersonId
from xTrack.dbo.tblResident res
join #_tblResident_updatePersonId resUpdate on res.Id = resUpdate.ResidentId 
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

end
else 
print'ALL residents have correct persons. ##_tblResident_updatePersonId is empty no need to use in live'

----this section needs optimization work takes a whole minute
-------------------------------------------update ab elig info--------------------------------------
delete from #_tblResident_raw
delete from #_tblResident

IF OBJECT_ID('tempdb..#_mcrElig_part1') IS NOT NULL
begin
print 'dropping #_mcrElig_part1'
DROP TABLE #_mcrElig_part1
end

IF OBJECT_ID('tempdb..#_mcrElig_part2') IS NOT NULL
begin
print 'dropping #_mcrElig_part2'
DROP TABLE #_mcrElig_part2
end

IF OBJECT_ID('tempdb..##_mcrElig_update') IS NOT NULL
begin
print 'dropping ##_mcrElig_update'
DROP TABLE ##_mcrElig_update
end

print 'creating #_tblResident_raw'
insert into #_tblResident_raw
select res.*
from ArTrackServer.xTrack.dbo.tblResident res

print 'creating #_tblResident'
insert into #_tblResident
select res.*
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'compiling #_mcrElig_part1'
select res.DsId
, max(case when cab = 'A' then dstart end) AStart
, max(case when cab = 'B' or pyr.cpayorgrid = 'HMO' then dstart end) BStart
into #_mcrElig_part1
from resdents res 
left join resmedab ab on (ab.cresdentsid = res.cid and ab.FacId = res.FacId)
left join payors pyr on (pyr.cpayorcode = ab.cab and pyr.FacId = ab.FacId)
where 1=1
and ((cab in ('A', 'B')
or pyr.cpayorgrid = 'HMO')
and (dend is null or dend >= getdate() )) 
group by res.DsId
order by res.DsId
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'compiling #_mcrElig_part2'
select * 
into #_mcrElig_part2
from #_mcrElig_part1
union
select res.DsId, null, null
from resdents res 
left join #_mcrElig_part1 elig on res.DsId = elig.DsId
where 1=1
and elig.DsId is null
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'compiling #_mcrElig_update'
select temp.*
into ##_mcrElig_update
from #_mcrElig_part2 temp
join #_tblResident res on temp.DsId = res.DsId
where 1=1
and 
(
	isnull(res.AStart, '') <> isnull(temp.AStart, '')
or	
	isnull(res.BStart, '') <> isnull(temp.BStart, '') 
)
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_mcrElig_update
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_mcrElig_update'')

update liveRes
set AStart = eligUpdate.AStart
,BStart = eligUpdate.BStart
from xTrack.dbo.tblResident liveRes
join #_mcrElig_update eligUpdate on liveRes.DsId = eligUpdate.DsId
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'


print 'dropping #_mcrElig_part1'
drop table #_mcrElig_part1
print 'dropping #_mcrElig_part2'
drop table #_mcrElig_part2
print 'dropping ##_mcrElig_update'
drop table ##_mcrElig_update



-------------------------------------------end update ab elig info--------------------------------------
set @resultCount = 0

delete from #_tblResident_raw
delete from #_tblResident

IF OBJECT_ID('tempdb..#_deadFac') IS NOT NULL
begin
print 'dropping #_deadFac'
DROP TABLE #_deadFac
end

IF OBJECT_ID('tempdb..#_dsDeletedFac') IS NOT NULL
begin
print 'dropping #_dsDeletedFac'
DROP TABLE #_dsDeletedFac
end

IF OBJECT_ID('tempdb..##_deletedRes') IS NOT NULL
begin
print 'dropping ##_deletedRes'
DROP TABLE ##_deletedRes
end

insert into #_tblResident_raw
select res.*
from ArTrackServer.xTrack.dbo.tblResident res

print 'creating #_tblResident'
insert into #_tblResident
select res.*
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'creating #_deadFac'
select nid
into #_deadFac
from Global_Facilities fac
left join (select distinct FacId from resdents) facRes on fac.nid = facRes.FacId 
where facRes.FacId is null
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'creating #_dsDeletedFac'
select pe.* 
into #_dsDeletedFac
from #_tblPhysicalEntity pe
left join Global_Facilities fac on pe.LegacyName collate Latin1_General_CS_AS  = fac.cname
where LevelId = (select ChildId from #_NameValueHierarchy nvh where nvh.ParentName = 'PeLevel' and ChildName = 'Fac')
and fac.nid is null
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'compiling ##_deletedRes to (logically) delete residents that were deleted from ds'
select liveRes.*
into ##_deletedRes
from #_tblResident liveRes
join #_tblPhysicalEntity pe on liveRes.PeId = pe.Id
left join #_deadFac deadfac on pe.DsId = deadfac.nid
left join #_dsDeletedFac deletedfac on pe.DsId = deletedfac.DsId
left join resdents res on liveRes.DsId = res.DsId
where 1=1 
and pe.CalculatedActiveness = 1
and (res.cid is null 
or deadfac.nid is not null
or deletedfac.DsId is not null)
and (liveRes.StateId <> (select ChildId from #_NameValueHierarchy nvh where nvh.ChildName = 'Deleted' and nvh.ParentName = 'Global.App.Data.Record.State' )
	or liveRes.DsId is not null)
	
select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
print 'using ##_deletedRes to (logically) delete residents that were deleted from ds'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_deletedRes
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_deletedRes'')

select * 
into #client
FROM OPENQUERY(ArTrackSyncServer,''select * from ##client'')

insert xTrack.dbo.tblSyncHistory (CodeBlockId,Comment,ClientId)
select nvh.ChildId, ''Resident does not exist in NCS, we removed DsId from this residents record. ResId: '' + convert(varchar(MAX),res.Id) 
+ '', ResDsId: '' + isnull(convert(varchar(MAX),res.DsId,2),''NULL'') + '', ResPeId: '' + convert(varchar(MAX),res.PeId) + '', ResPeName: '' + pe.Name 
+ '', MedicareNo: '' + isnull(res.McaNum,''NULL'') + '', MedicaidNo: '' + isnull(res.McoNum,''NULL'')
+ '', PersonId: '' + convert(varchar(MAX),res.PersonId) + '', PersonName: '' + isnull(p.First,''NULL'') + '', '' + isnull(p.Last,''NULL''), c.Id
from #_deletedRes res
join xTrack.dbo.tblPhysicalEntity pe on res.PeId = pe.Id
join xTrack.dbo.tblPerson p on res.PersonId = p.Id
join #client c on 1=1
, xTrack.dbo.NameValueHierarchy nvh
where nvh.ParentName = ''SyncComments.CodeBlock'' and nvh.ChildName = ''ResMismatch''

update liveRes
set StateId = (select ChildId from xTrack.dbo.NameValueHierarchy nvh where nvh.ChildName = ''Deleted'' and nvh.ParentName = ''Global.App.Data.Record.State'' )
, DsId = NULL
from xTrack.dbo.tblResident liveRes
join #_deletedRes deleted on liveRes.Id = deleted.Id
'

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
end
else
print '##_deletedRes is empty no need to use in live'

set @resultCount = 0

print 'dropping ##_deletedRes'
drop table ##_deletedRes


delete from #_tblPerson_raw
delete from #_tblPerson

delete from #_tblResident_raw
delete from #_tblResident

print 'creating #_tblPerson_raw'
insert into #_tblPerson_raw
select person.*
from ArTrackServer.xTrack.dbo.tblPerson person

print 'creating #_tblPerson'
insert into #_tblPerson
select person.*
from #_tblPerson_raw person
join #_tblPhysicalEntity pe on person.PeId = pe.Id

print 'creating #_tblResident_raw'
insert into #_tblResident_raw
select res.*
from ArTrackServer.xTrack.dbo.tblResident res

print 'creating #_tblResident'
insert into #_tblResident
select res.*
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id


--deleting people and residents not in NCS and their dependencies as long as it's not user input
IF OBJECT_ID('tempdb..#_tblCase_raw') IS NOT NULL
begin
print 'dropping #_tblCase_raw'
DROP TABLE #_tblCase_raw
end

IF OBJECT_ID('tempdb..#_tblCase') IS NOT NULL
begin
print 'dropping #_tblCase'
DROP TABLE #_tblCase
end

IF OBJECT_ID('tempdb..#_tblNote_raw') IS NOT NULL
begin
print 'dropping #_tblNote_raw'
DROP TABLE #_tblNote_raw
end

IF OBJECT_ID('tempdb..#_tblNote') IS NOT NULL
begin
print 'dropping #_tblNote'
DROP TABLE #_tblNote
end

IF OBJECT_ID('tempdb..#_tblAdr_raw') IS NOT NULL
begin
print 'dropping #_tblAdr_raw'
DROP TABLE #_tblAdr_raw
end

IF OBJECT_ID('tempdb..#_tblAdr') IS NOT NULL
begin
print 'dropping #_tblAdr'
DROP TABLE #_tblAdr
end

IF OBJECT_ID('tempdb..##deletedResNoDependencies') IS NOT NULL
begin
print 'dropping ##deletedResNoDependencies'
DROP TABLE ##deletedResNoDependencies
end


IF OBJECT_ID('tempdb..##deletedCases') IS NOT NULL
begin
print 'dropping ##deletedCases'
DROP TABLE ##deletedCases
end

IF OBJECT_ID('tempdb..##deletedAdrs') IS NOT NULL
begin
print 'dropping ##deletedAdrs'
DROP TABLE ##deletedAdrs
end

IF OBJECT_ID('tempdb..##deletedPersonNoDependencies') IS NOT NULL
begin
print 'dropping ##deletedPersonNoDependencies'
DROP TABLE ##deletedPersonNoDependencies
end

select c.*
into #_tblCase_raw
from ArTrackServer.xTrack.dbo.tblCase c

select c.*
into #_tblCase
from #_tblCase_raw c
join #_tblResident r on c.ResId = r.Id
,#_NameValueHierarchy nvh
where nvh.ParentName = 'Status' and nvh.ChildName <> 'Canceled'

select n.*
into #_tblNote_raw
from ArTrackServer.xTrack.dbo.tblNote n

select n.*
into #_tblNote
from #_tblNote_raw n
join #_tblCase c on n.CaseId = c.Id

select adr.*
into #_tblAdr_raw
from ArTrackServer.xTrack.dbo.tblAdr adr

select adr.*
into #_tblAdr
from #_tblAdr_raw adr
join #_tblCase c on adr.CaseId = c.Id

select liveRes.*
into ##deletedResNoDependencies
from #_tblResident liveRes
left join #_tblCase nonAutoNri on liveRes.Id = nonAutoNri.ResId 
						and (
								nonAutoNri.CreatedById <> (select Id from ##DsSyncUser) 
								or nonAutoNri.ScenarioId <> 
								(Select Id from #_tblNameValue where Name = 'NRIUnavailable' 
								 and ParentId = (select Id from #_tblNameValue where Name = 'Case.Scenario'))
							)
left join #_tblCase autoNri on liveRes.Id = autoNri.ResId 
						and (
							autoNri.CreatedById = (select Id from ##DsSyncUser) 
							and autoNri.ScenarioId = 
							(Select Id from #_tblNameValue where Name = 'NRIUnavailable' 
							and ParentId = (select Id from #_tblNameValue where Name = 'Case.Scenario'))
							)
left join #_tblNote notesForAutoNri on autoNri.Id = notesForAutoNri.CaseId
left join #_tblAdr adrForAutoNri on autoNri.Id = adrForAutoNri.CaseId
where liveRes.DsId is null
and nonAutoNri.Id is null
and notesForAutoNri.Id is null
and adrForAutoNri.Id is null

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
	
select c.*
into ##deletedCases
from #_tblCase_raw c
join ##deletedResNoDependencies r on c.ResId = r.Id

select adr.*
into ##deletedAdrs
from #_tblAdr_raw adr
join ##deletedCases c on adr.CaseId = c.Id

select deletePerson.*
into ##deletedPersonNoDependencies
from #_tblPerson deletePerson 
join ##deletedResNoDependencies deleteRes on deletePerson.Id = deleteRes.PersonId
left join #_people p on deletePerson.DsId = p.DsId
where p.DsId is null

print 'RED FLAG ALERT: Deleting people and residents not in NCS and their dependencies as long as it is not user input.'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #deletedResNoDependencies
FROM OPENQUERY(ArTrackSyncServer,''select * from ##deletedResNoDependencies'')

select * 
into #deletedPersonNoDependencies
FROM OPENQUERY(ArTrackSyncServer,''select * from ##deletedPersonNoDependencies'')

select * 
into #deletedCases
FROM OPENQUERY(ArTrackSyncServer,''select * from ##deletedCases'')

select * 
into #deletedAdrs
FROM OPENQUERY(ArTrackSyncServer,''select * from ##deletedAdrs'')

select * 
into #client
FROM OPENQUERY(ArTrackSyncServer,''select * from ##client'')

insert xTrack.dbo.tblSyncHistory (CodeBlockId,Comment,ClientId)
select nvh.ChildId, '' Deleting residents that do not exist in NCS and that do not have dependencies (cases,notes etc.) that are user created. ResId: '' + convert(varchar(MAX),res.Id) 
+ '', MedicareNo: '' + isnull(res.McaNum,''NULL'') + '', MedicaidNo: '' + isnull(res.McoNum,''NULL'')
+ '', ResPeId: '' + convert(varchar(MAX),res.PeId) + '', PeName: '' + pe.Name + '', PersonName: '' + isnull(p.First,''NULL'') + isnull(p.Last,''NULL'') 
+ '', PersonId: '' + convert(varchar(MAX),res.PersonId) + '', BDate: '' + isnull(convert(varchar(MAX),p.BDate),''NULL'') + '', Social: '' + isnull(p.Social,''NULL''), c.Id
from #deletedResNoDependencies res
join xTrack.dbo.tblPhysicalEntity pe on res.PeId = pe.Id
join xTrack.dbo.tblPerson p on res.PersonId = p.Id
join #client c on 1=1
, xTrack.dbo.NameValueHierarchy nvh
where nvh.ParentName = ''SyncComments.CodeBlock'' and nvh.ChildName = ''ResDelete''

insert xTrack.dbo.tblSyncHistory (CodeBlockId,Comment,ClientId)
select nvh.ChildId, '' Deleting persons that do not exist in NCS and have no residents attached to them. Person Id: '' + convert(varchar(MAX),per.Id) 
+ '', Name: '' + per.Last + '', '' + per.First + '', PeId: '' + convert(varchar(MAX),per.PeId) + '', PeName: '' + pe.Name + '', BDate: '' + isnull(convert(varchar(MAX),per.BDate),''NULL'')
+ '', Social: '' + isnull(per.Social,''NULL''), c.Id
from #deletedPersonNoDependencies per
join xTrack.dbo.tblPhysicalEntity pe on per.PeId = pe.Id
join #client c on 1=1
, xTrack.dbo.NameValueHierarchy nvh
where nvh.ParentName = ''SyncComments.CodeBlock'' and nvh.ChildName = ''PersonDelete''

delete from adrDetail
from xTrack.dbo.tblAdrDetail adrDetail
join xTrack.dbo.tblAdr adr on adrDetail.AdrId = adr.Id
join xTrack.dbo.tblCase c on adr.CaseId = c.Id
join #deletedResNoDependencies del on c.ResId = del.Id

delete from adrDetailHistory
from xTrack.dbo.tblAdrDetailHistory adrDetailHistory
join xTrack.dbo.tblAdr adr on adrDetailHistory.AdrId = adr.Id
join xTrack.dbo.tblCase c on adr.CaseId = c.Id
join #deletedResNoDependencies del on c.ResId = del.Id

delete from adr
from xTrack.dbo.tblAdr adr
join xTrack.dbo.tblCase c on adr.CaseId = c.Id
join #deletedResNoDependencies del on c.ResId = del.Id

delete from fileBag
from xTrack.dbo.tblFileBag fileBag 
join #deletedAdrs adr on fileBag.Id = adr.FileBagId

delete from n
from xTrack.dbo.tblNote n
join xTrack.dbo.tblCase c on n.CaseId = c.Id
join #deletedResNoDependencies del on c.ResId = del.Id

delete from c
from xTrack.dbo.tblCase c
join #deletedResNoDependencies del on c.ResId = del.Id

delete from f
from xTrack.dbo.tblFile f 
join #deletedCases c on f.Id = c.AttachmentId

delete from sp
from xTrack.dbo.tblStay s
join xTrack.dbo.tblStayPayor sp on s.Id = sp.StayId
join #deletedResNoDependencies del on s.ResId = del.Id

delete from s
from xTrack.dbo.tblStay s
join #deletedResNoDependencies del on s.ResId = del.Id

delete from bill
from xTrack.dbo.[tblAging.Bill] bill
join #deletedResNoDependencies del on bill.ResId = del.Id

delete from cr
from xTrack.dbo.[tblAging.Cr] cr
join #deletedResNoDependencies del on cr.ResId = del.Id

delete balCase
from xTrack.dbo.tblResident r 
join xTrack.dbo.[tblAging.BalCaseDetail] bct on r.Id = bct.ResId
join xTrack.dbo.[tblAging.BalCase] balCase on bct.Id = balCase.BalCaseDetailId
join #deletedResNoDependencies del on r.Id = del.Id

delete bct
from xTrack.dbo.tblResident r 
join xTrack.dbo.[tblAging.BalCaseDetail] bct on r.Id = bct.ResId
join #deletedResNoDependencies del on r.Id = del.Id

delete from bal
from xTrack.dbo.[tblAging.Bal] bal
join #deletedResNoDependencies del on bal.ResId = del.Id

delete from resappincome
from xTrack.dbo.tblResAppIncome resappincome
join #deletedResNoDependencies del on resappincome.ResId = del.Id

delete from r
from xTrack.dbo.tblResident r
join #deletedResNoDependencies del on r.Id = del.Id

delete from p
from xTrack.dbo.tblPerson p
join #deletedPersonNoDependencies del on p.Id = del.Id
'

end
else  
print 'No residents to delete.'

delete from #_tblPerson_raw
delete from #_tblPerson

delete from #_tblResident_raw
delete from #_tblResident

print 'creating #_tblPerson_raw'
insert into #_tblPerson_raw
select person.*
from ArTrackServer.xTrack.dbo.tblPerson person

print 'creating #_tblPerson'
insert into #_tblPerson
select person.*
from #_tblPerson_raw person
join #_tblPhysicalEntity pe on person.PeId = pe.Id

print 'creating #_tblResident_raw'
insert into #_tblResident_raw
select res.*
from ArTrackServer.xTrack.dbo.tblResident res

print 'creating #_tblResident'
insert into #_tblResident
select res.*
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id


---end third party fac
--asked yehuda the following: seems like there are ds third party fac that are duplicates and ds doesn't stop it. is that legit. he pretty
--much came out that it is legit because you can have the same hospitol with the same name different address (chain hospitols) 
--but then he added i don't even know why do you bother with admit from and admit to fields, like why would you need them
--well: good point. at this point i will not put them in the system. if we need to put them in, in the future, we'll have to deal with the dup hospitol names
--also if you put it back, there's an issue with the two commented lines below because the view is very expensive and when using it twice in the same
--query it slows it down by alot, the best thing is to just run the view into a temp table and work from there and then delete the temp table at the end
--stay
--tested

set @resultCount =0

delete from #_NameValueHierarchy
delete from #_tblResident_raw
delete from #_tblResident

IF OBJECT_ID('tempdb..#_tblStay') IS NOT NULL
begin
print 'dropping #_tblStay'
DROP TABLE #_tblStay
end

print 'creating #_NameValueHierarchy'
insert into #_NameValueHierarchy
select * 
from ArTrackServer.xTrack.dbo.NameValueHierarchy
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'creating #_tblResident_raw'
insert into #_tblResident_raw
select res.*
from ArTrackServer.xTrack.dbo.tblResident res

print 'creating #_tblResident'
insert into #_tblResident
select res.*
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'creating #_tblStay'
select stay.*
into #_tblStay
from ArTrackServer.xTrack.dbo.tblStay stay
join #_tblResident res on stay.ResId = res.Id

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

IF OBJECT_ID('tempdb..##_tblStay_insert') IS NOT NULL
begin
print 'dropping ##_tblStay_insert'
DROP TABLE ##_tblStay_insert
end

IF OBJECT_ID('tempdb..##_tblStay_delete') IS NOT NULL
begin
print 'dropping ##_tblStay_delete'
DROP TABLE ##_tblStay_delete
end

print 'updating resstay setting open dicharge date to null'
update resstay
set ddis = null
where ddis = '1899-12-30 00:00:00.000'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

--delete orphaned stay and stay payor
select  stay.id
into ##_tblStay_delete
from #_tblStay stay
left join resstay s on stay.DsId = s.DsId
where s.cid is null 

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblStay_delete
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblStay_delete'')

delete  from xTrack.dbo.tblStayPayor
where StayId in(
select Id from #_tblStay_delete
)

delete from xTrack.dbo.tblStay
where Id in(
select Id from #_tblStay_delete
)
'

IF OBJECT_ID('tempdb..#_resstay') IS NOT NULL
begin
print 'dropping #_resstay'
DROP TABLE #_resstay
end

select *, case when crecordcode = 'H' then 1 else 0 end IsBh
into #_resstay
from [dbo].resstay


print 'compiling ##_tblStay_insert to add new entries to tblStay in live'
select distinct s.DsId stayid, nhres.Id resId, s.dadm, s.ddis, s.cadmitdiag, s.cdischdiag, nvh.ChildId, s.IsBh
	   , case when s.IsBh = 0 then 1 else 0 end PendingAutoNriClarification
into ##_tblStay_insert
from #_resstay s
join resdents res on (s.cresdentid = res.cid and res.FacId = s.FacId)
join #_tblResident nhres on (nhres.DsId = res.DsId)
left join #_tblStay stay on stay.DsId = s.DsId
,#_NameValueHierarchy nvh
where stay.Id is null
and nvh.ChildName = 'Active' and nvh.ParentName = 'Global.App.Data.Record.State'

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
print 'using ##_tblStay_insert to add to tblStay'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblStay_insert
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblStay_insert'')

insert xTrack.dbo.tblStay
(DsId, ResId, Admission, Discharge, AdmitDiag, DischargeDiag, StateId, IsBh, PendingAutoNriClarification)
select *
from #_tblStay_insert
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
end
else
print '##_tblStay_insert is empty no need to insert to live'



set @resultCount =0

delete from #_tblStay

IF OBJECT_ID('tempdb..##_tblStay_update') IS NOT NULL
begin
print 'dropping ##_tblStay_update'
DROP TABLE ##_tblStay_update
end

print 'creating #_tblStay'
insert into #_tblStay
select stay.*
from ArTrackServer.xTrack.dbo.tblStay stay
join #_tblResident res on stay.ResId = res.Id

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'compiling #_tblStay_update to update changes to tblStay'
select s.DsId, s.dadm, s.ddis,s.cadmitdiag,s.cdischdiag, s.IsBh
into ##_tblStay_update
from #_tblStay stay
join #_resstay s on stay.DsId = s.DsId
where 1=1
and 
(
	isnull(stay.Admission, '') <> isnull(s.dadm,'')
or	isnull(stay.Discharge,'') <> isnull(s.ddis,'')
or	isnull(stay.AdmitDiag,'') collate Latin1_General_CS_AS <> isnull(s.cadmitdiag, '')
or	isnull(stay.DischargeDiag, '') collate Latin1_General_CS_AS <> isnull(s.cdischdiag, '')
or  isnull(stay.IsBh,'') <> isnull(s.IsBh,'')
)

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
print 'using #_tblStay_update to update tblStay'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblStay_update
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblStay_update'')

update stay
set Admission = stayUpdate.dadm
, Discharge = stayUpdate.ddis
,AdmitDiag = stayUpdate.cadmitdiag
,DischargeDiag = stayUpdate.cdischdiag
,IsBh = stayUpdate.IsBh
from xTrack.dbo.tblStay stay
join #_tblStay_update stayUpdate on stay.DsId = stayUpdate.DsId
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

end
else
print '#_tblStay_update is empty no need to update to live'

print 'dropping #_tblStay_update'
drop table ##_tblStay_update


delete from #_tblResident_raw
delete from #_tblResident

delete from #_tblStay

IF OBJECT_ID('tempdb..##_tblResident_UpdateLatestDischargeDate') IS NOT NULL
begin
print 'dropping ##_tblResident_UpdateLatestDischargeDate'
DROP TABLE ##_tblResident_UpdateLatestDischargeDate
end

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'creating #_tblResident_raw'
insert into #_tblResident_raw
select res.*
from ArTrackServer.xTrack.dbo.tblResident res

print 'creating #_tblResident'
insert into #_tblResident
select res.*
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id

print 'creating #_tblStay'
insert into #_tblStay 
select stay.*
from ArTrackServer.xTrack.dbo.tblStay stay
join #_tblResident res on stay.ResId = res.Id

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

select res.Id resId, stay.Admission LatestAdmitDate, stay.Discharge LatestDissDate
into ##_tblResident_UpdateLatestDischargeDate
from #_tblResident res
join #_tblStay stay on res.Id = stay.ResId
join 
(select res.Id, max(stay.Id) maxAdmitStayId
from #_tblResident res
join #_tblStay stay on res.Id = stay.ResId
where stay.StateId = 1097
group by res.Id) as resMaxAdmit on (res.Id = resMaxAdmit.Id and stay.Id = resMaxAdmit.maxAdmitStayId)
where 1=1
--and stay.IsBh = 0
and (isnull(res.LatestAdmitDate,'') <> stay.Admission
or isnull(res.LatestDissDate,'') <> stay.Discharge)

print 'updating latest admit/dc dates'


exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblResident_UpdateLatestDischargeDate
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblResident_UpdateLatestDischargeDate'')

update res
set 
LatestAdmitDate = updateLatestDc.LatestAdmitDate
,LatestDissDate = updateLatestDc.LatestDissDate
from xTrack.dbo.tblResident res
join #_tblResident_UpdateLatestDischargeDate updateLatestDc on res.Id = updateLatestDc.resId
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'



--todo:
/*
-incorporate this script into the tool
-what happens when a table is corrupt for a ds fac - the import will not pick it up and all items will show up as deleted - need to think about this
-create a log output in the c# code
*/

delete from #_tblResident_raw
delete from #_tblResident

delete from #_tblPayor


delete from #_tblStay

IF OBJECT_ID('tempdb..#_tblStayPayor') IS NOT NULL
begin
print 'dropping #_tblStayPayor'
DROP TABLE #_tblStayPayor
end

IF OBJECT_ID('tempdb..##_StayPayor_MinStartDate') IS NOT NULL
begin
print 'dropping ##_StayPayor_MinStartDate'
DROP TABLE ##_StayPayor_MinStartDate
end

IF OBJECT_ID('tempdb..##_tblStay_NonBh_insert') IS NOT NULL
begin
print 'dropping ##_tblStay_NonBh_insert'
DROP TABLE ##_tblStay_NonBh_insert
end

IF OBJECT_ID('tempdb..##_tblStay_LastStayForTheNewStays') IS NOT NULL
begin
print 'dropping ##_tblStay_LastStayForTheNewStays'
DROP TABLE ##_tblStay_LastStayForTheNewStays
end

IF OBJECT_ID('tempdb..##_newAdmissions') IS NOT NULL
begin
print 'dropping ##_newAdmissions'
DROP TABLE ##_newAdmissions
end

IF OBJECT_ID('tempdb..##_tblStay_WithPayor_insert') IS NOT NULL
begin
print 'dropping ##_tblStay_WithPayor_insert'
DROP TABLE ##_tblStay_WithPayor_insert
end

insert into #_tblResident_raw
select res.*
from ArTrackServer.xTrack.dbo.tblResident res

print 'creating #_tblResident'
insert into #_tblResident
select res.*
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id

print 'creating #_tblPayor'
insert into #_tblPayor
select payor.* 
from ArTrackServer.xTrack.dbo.tblPayor payor
left join #_tblPhysicalEntity pe on payor.PeId = pe.Id 
where 1=1 and (payor.PeId = pe.Id or payor.PeId is null)

print 'creating #_tblStay'
insert into #_tblStay 
select stay.*
from ArTrackServer.xTrack.dbo.tblStay stay
join #_tblResident res on stay.ResId = res.Id

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'creating #_tblStayPayor'

select sp.* 
into #_tblStayPayor
from ArTrackServer.xTrack.dbo.tblStayPayor sp
join #_tblPayor payor on sp.PayorId = payor.Id

IF OBJECT_ID('tempdb..##_tblStayPayor_insert') IS NOT NULL
begin
print 'dropping ##_tblStayPayor_insert'
DROP TABLE ##_tblStayPayor_insert
end

IF OBJECT_ID('tempdb..##_tblStayPayor_delete') IS NOT NULL
begin
print 'dropping ##_tblStayPayor_delete'
DROP TABLE ##_tblStayPayor_delete
end

print 'compiling ##_tblStayPayor_delete to delete stale tblStayPayor entries'
select sp.DsId
into ##_tblStayPayor_delete
from #_tblStayPayor sp
left join [dbo].[respay] ds_sp on sp.DsId = ds_sp.DsId
where ds_sp.DsId is null

print 'apply ##_tblStayPayor_delete in live'

print 'running select' + convert(varchar(50), @@rowcount)

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblStayPayor_delete
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblStayPayor_delete'')

delete from xTrack.dbo.tblStayPayor
where DsId in(
select DsId from #_tblStayPayor_delete
)
'

print 'compiling #_tblStayPayor_insert to add new tblStayPayor entries'
select rp.DsId, nhStay.Id StayId, nhP.Id PayorId, null CoPayorId, rp.dstart startDate, rp.dstop endDate, rp.cpayorratesid rateCode, rp.cpayorrefnum refNum, rp.cauthno authNum
, rp.ncopay coPay, rp.ccopayrefnum coInsRefNum, rp.cincidentno incidentNum, rp.iexpend expendedDays
into ##_tblStayPayor_insert
from [dbo].respay rp 
join payors p on (rp.cpayorid = p.cid and rp.FacId = p.FacId)
join #_tblPayor nhP on p.DsId = nhP.DsId
join [dbo].resstay stay on (rp.cresstayid = stay.cid and rp.FacId = stay.FacId) --we lose a couple of rows with this join because ds has respays that do not have res stay...???(why?? no idea)
join #_tblStay nhStay on stay.DsId = nhStay.DsId
left join #_tblStayPayor sp on rp.DsId = sp.DsId
where 1=1
and sp.Id is null
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'updating co-payorId in #_tblStayPayor_insert'
update sInsert
set CoPayorId = nhPayors.Id
from ##_tblStayPayor_insert sInsert
join [dbo].respay on sInsert.DsId = respay.DsId
join [dbo].payors on (respay.ccoinsurerid = payors.cpayorcode and respay.FacId = payors.FacId)
join #_tblPayor nhPayors on payors.DsId = nhPayors.DsId


print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

if exists (select 'x' from ##_tblStayPayor_insert)
begin
print 'using ##_tblStayPayor_insert to add new entries to tblStayPayor in live'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblStayPayor_insert
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblStayPayor_insert'')

insert xTrack.dbo.tblStayPayor
(DsId, StayId, PayorId, CoPayorId, StartDate, EndDate, RateCode, RefNum, AuthNum, CoPay, CoInsRefNum, IncidentNum, ExpendedDays)
select spInsert.DsID, spInsert.StayId, spInsert.PayorId, spInsert.CoPayorId, spInsert.startDate, spInsert.endDate, spInsert.rateCode, spInsert.refNum, spInsert.authNum, spInsert.coPay, spInsert.coInsRefNum
,spInsert.incidentNum, spInsert.ExpendedDays
from #_tblStayPayor_insert spInsert

'

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
end
else
print '##_tblStayPayor_insert is empty no new entries to add to tblStayPayor in live'

IF OBJECT_ID('tempdb..##_oldAdmissions') IS NOT NULL
begin
print 'dropping ##_oldAdmissions'
drop table ##_oldAdmissions
end

IF OBJECT_ID('tempdb..##AutoNriClarified') IS NOT NULL
begin
print 'dropping ##AutoNriClarified'
drop table ##AutoNriClarified
end

delete from #_tblStayPayor

print 'creating #_tblStayPayor'

insert into #_tblStayPayor
select sp.* 
from ArTrackServer.xTrack.dbo.tblStayPayor sp
join #_tblPayor payor on sp.PayorId = payor.Id


select *
into ##_StayPayor_MinStartDate
from #_tblStayPayor
where convert(varchar(20), StayId) + CONVERT(varchar(50), StartDate) in
(
select convert(varchar(20), StayId) + CONVERT(varchar(50), min(StartDate))
from #_tblStayPayor
group by StayId
)

------------------
--new section
select *
into ##_tblStay_NonBh_insert 
from #_tblStay stayins
where PendingAutoNriClarification = 1

--first get max stay for the resid's
select stay.ResId, stay.Admission, stay.Discharge
into ##_tblStay_LastStayForTheNewStays
from #_tblStay stay
where Id in(
select stay.Id 
from #_tblStay stay
join (
select ResId, MAX(Discharge) Discharge
from #_tblStay  
where ResId in(select resid from ##_tblStay_NonBh_insert)
and IsBh = 0
group by ResId
) as maxDis on stay.ResId = maxDis.ResId and stay.Discharge = maxDis.Discharge
)



------------some queries
/*
select *
from ##_tblStay_insert stayins
order by ResId
select s.*, pe.LegacyName, p.Last, p.First
from ##_tblStay_NonBh_insert s 
join ArTrackServer.xTrack.dbo.tblResident r on s.ResId = r.Id
join ArTrackServer.xTrack.dbo.tblPerson p on r.PersonId = p.Id
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on pe.Id = r.PeId
order by s.ResId


select s.*, pe.LegacyName, p.Last, p.First
from ##_tblStay_LastStayForTheNewStays s
join ArTrackServer.xTrack.dbo.tblResident r on s.ResId = r.Id
join ArTrackServer.xTrack.dbo.tblPerson p on r.PersonId = p.Id
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on pe.Id = r.PeId
order by ResId
*/
------------some queries


--new admissions of over 30 days
select stayins.*
into ##_newAdmissions
--fisrt get those entries that have previos stays but adhere to the 30 day rule
from ##_tblStay_NonBh_insert  stayins
join ##_tblStay_LastStayForTheNewStays lastStay on stayins.ResId = lastStay.ResId and datediff(dd, lastStay.Discharge, stayins.Admission) > 30
join resstay stay on stayins.DsId = stay.DsId and stay.loutpatient = 0
union
--then get those entries which are totally new admissions
select stayins.*
from ##_tblStay_NonBh_insert stayins
left join ##_tblStay_LastStayForTheNewStays lastStay on stayins.ResId = lastStay.ResId
join resstay stay on stayins.DsId = stay.DsId and stay.loutpatient = 0
where lastStay.ResId is null

--get the stays that do not need auto nri clarification
select stayins.*
into ##_oldAdmissions
--get those entries that have previous stays and do not adhere to the 30 day rule
from ##_tblStay_NonBh_insert  stayins 
join ##_tblStay_LastStayForTheNewStays lastStay on stayins.ResId = lastStay.ResId and datediff(dd, lastStay.Discharge, stayins.Admission) < 31
join resstay stay on stayins.DsId = stay.DsId and stay.loutpatient = 0
----------------------

select admitIns.*, sp.PayorId, payor.Name StayPayor
into ##_tblStay_WithPayor_insert
from ##_newAdmissions admitIns
join #_tblStay stay on stay.DsId = admitIns.DsId
join ##_StayPayor_MinStartDate sp on stay.Id = sp.StayId
join #_tblPayor payor on sp.PayorId = payor.Id


select stay.Id
into ##AutoNriClarified
from ##_tblStay_WithPayor_insert stay
union
select Id
from ##_oldAdmissions

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblStay_WithPayor_insert
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblStay_WithPayor_insert'')

select * 
into #DsSyncUser
FROM OPENQUERY(ArTrackSyncServer,''select * from ##DsSyncUser'')

select * 
into #AutoNriClarified
FROM OPENQUERY(ArTrackSyncServer,''select * from ##AutoNriClarified'')

insert xTrack.dbo.tblCase 
(StatusId, ResId, CaseTypeId, ScenarioId, StartDate, Mcr20Days, Mcr100Days, Comments, CreatedById, CreatedOn, LastModifiedById, LastModifiedOn) 
select 1123, ins.ResId, 1173, 57, ins.Admission, DateAdd(dd, 19, ins.Admission), DateAdd(dd, 99, ins.Admission)
, ''Auto NRI with Payor: '' + ins.StayPayor, dsSyncUser.Id, getdate(), dsSyncUser.Id, getdate()
from #_tblStay_WithPayor_insert ins
,#DsSyncUser dsSyncUser

update s
set PendingAutoNriClarification = 0
from xTrack.dbo.tblStay s
join #AutoNriClarified anc on s.Id = anc.Id
'

IF OBJECT_ID('tempdb..##_tblResident_insert') IS NOT NULL
begin
print 'dropping ##_tblResident_insert'
DROP TABLE ##_tblResident_insert
end

IF OBJECT_ID('tempdb..##_tblResident_WithPayor_insert') IS NOT NULL
begin
print 'dropping ##_tblResident_WithPayor_insert'
DROP TABLE ##_tblResident_WithPayor_insert
end



set @resultCount =0

IF OBJECT_ID('tempdb..##_tblStayPayor_update_nonFk') IS NOT NULL
begin
print 'dropping ##_tblStayPayor_update_nonFk'
DROP TABLE ##_tblStayPayor_update_nonFk
end

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

update ArTrackServer.xTrack.dbo.tblStayPayor
set EndDate = null
where EndDate = '1899-12-30'

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

print 'Compiling ##_tblStayPayor_update_nonFk'
select respay.DsId, respay.dstart startDate, respay.dstop endDate, respay.cpayorratesid rateCode, respay.cpayorrefnum refNum, respay.cauthno authNum
, respay.ncopay coPay, respay.ccopayrefnum coInsRefNum, respay.cincidentno incidentNum, respay.iexpend expendedDays
into ##_tblStayPayor_update_nonFk
from respay respay
join #_tblStayPayor sp on respay.DsId = sp.DsId
where 1=1
and 
(
isnull(respay.dstart, '1/1/1800') <> isnull(sp.StartDate,'1/1/1800')
or  isnull(respay.dstop, '1/1/1800') <> isnull(sp.EndDate, '1/1/1800')
or	respay.cpayorratesid collate SQL_Latin1_General_CP1_CS_AS <> sp.RateCode collate SQL_Latin1_General_CP1_CS_AS
or	respay.cpayorrefnum collate SQL_Latin1_General_CP1_CS_AS <> sp.RefNum collate SQL_Latin1_General_CP1_CS_AS
or	respay.ccopayrefnum collate SQL_Latin1_General_CP1_CS_AS <> sp.CoInsRefNum collate SQL_Latin1_General_CP1_CS_AS
or	respay.cauthno collate SQL_Latin1_General_CP1_CS_AS <> sp.AuthNum collate SQL_Latin1_General_CP1_CS_AS
or	respay.ncopay <> sp.CoPay 
or	isnull(respay.cincidentno,'') collate SQL_Latin1_General_CP1_CS_AS <> isnull(sp.IncidentNum,'') collate SQL_Latin1_General_CP1_CS_AS
or  isnull(respay.iexpend,0)  <> isnull(sp.ExpendedDays, 0) 
)

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
print 'using ##_tblStayPayor_update_nonFk to update all non fk columns in tblStayPayor'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblStayPayor_update_nonFk
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblStayPayor_update_nonFk'')

update stayPayor
set StartDate = spUpdate.startDate
, EndDate = spUpdate.endDate
, RateCode = spUpdate.rateCode
, AuthNum = spUpdate.authNum
, RefNum = spUpdate.refNum
, CoPay = spUpdate.coPay
, CoInsRefNum = spUpdate.coInsRefNum
, IncidentNum = spUpdate.incidentNum
, ExpendedDays = spUpdate.expendedDays
from #_tblStayPayor_update_nonFk spUpdate
join xTrack.dbo.tblStayPayor stayPayor on spUpdate.DsId = stayPayor.DsId
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
end
else
print '##_tblStayPayor_update_nonFk is empty no need to update live'

IF OBJECT_ID('tempdb..##_tblStayPayor_update_Stay') IS NOT NULL
begin
print 'dropping ##_tblStayPayor_update_Stay'
DROP TABLE ##_tblStayPayor_update_Stay
end


print 'Compliling ##_tblStayPayor_update_Stay'
select respay.DsId, nhStay.Id StayId
into ##_tblStayPayor_update_Stay
from respay respay
join #_tblStayPayor sp on respay.DsId = sp.DsId
join resstay stay on (respay.cresstayid = stay.cid and respay.FacId = stay.FacId) --we lose a couple of rows with this join because ds has respays that do not have res stay...???(why?? no idea)
join #_tblStay nhStay on stay.DsId = nhStay.DsId
where 1=1
and 
(
	sp.StayId <> nhStay.Id
)

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
print 'using ##_tblStayPayor_update_Stay to update stayid in tblStayPayor'


exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblStayPayor_update_Stay
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblStayPayor_update_Stay'')

update stayPayor
set StayId = spUpdate.StayId
from #_tblStayPayor_update_Stay spUpdate
join xTrack.dbo.tblStayPayor stayPayor on spUpdate.DsId = stayPayor.DsId
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
end
else
print '##_tblStayPayor_update_Stay is empty no need to update live'


IF OBJECT_ID('tempdb..##_tblStayPayor_update_Payor') IS NOT NULL
begin
print 'dropping ##_tblStayPayor_update_Payor'
DROP TABLE ##_tblStayPayor_update_Payor
end

print 'Compliling ##_tblStayPayor_update_Payor'
select respay.DsId, nhPayors.Id PayorId
into ##_tblStayPayor_update_Payor
from respay respay
join #_tblStayPayor sp on respay.DsId = sp.DsId
join payors on (respay.cpayorid = payors.cpayorcode and respay.FacId = payors.FacId)
join #_tblPayor nhPayors on nhPayors.DsId = payors.DsId
where 1=1
and 
(
	sp.PayorId <> nhPayors.Id
)

select @resultCount = @@ROWCOUNT
print convert(varchar(50), @resultCount) + ' rows affected'
if @resultCount > 0
begin
print 'using ##_tblStayPayor_update_Payor to update payors in tblStayPayor'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblStayPayor_update_Payor
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblStayPayor_update_Payor'')

update stayPayor
set PayorId = spUpdate.PayorId
from #_tblStayPayor_update_Payor spUpdate
join xTrack.dbo.tblStayPayor stayPayor on spUpdate.DsId = stayPayor.DsId
'
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

end
else
print '##_tblStayPayor_update_Payor is empty no need to update live'

IF OBJECT_ID('tempdb..##_tblStayPayor_update_CoPayor') IS NOT NULL
begin
print 'dropping ##_tblStayPayor_update_CoPayor'
DROP TABLE ##_tblStayPayor_update_CoPayor
end

print 'Compliling ##_tblStayPayor_update_CoPayor'
select respay.DsId, nhPayors.Id PayorId
into ##_tblStayPayor_update_CoPayor
from respay respay
join #_tblStayPayor sp on respay.DsId = sp.DsId
join payors on (respay.ccoinsurerid = payors.cpayorcode and respay.FacId = payors.FacId)
join #_tblPayor nhPayors on nhPayors.DsId = payors.DsId
where 1=1
and 
(
	isnull(sp.CoPayorId, 0) <> isnull(nhPayors.Id, 0)
)

select @resultCount = @@ROWCOUNT

print convert(varchar(50), @resultCount) + ' rows affected'

if @resultCount > 0
begin
print 'using ##_tblStayPayor_update_CoPayor to update co-payors in tblStayPayor'


exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblStayPayor_update_CoPayor
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblStayPayor_update_CoPayor'')

update stayPayor
set CoPayorId = spUpdate.PayorId
from #_tblStayPayor_update_CoPayor spUpdate
join xTrack.dbo.tblStayPayor stayPayor on spUpdate.DsId = stayPayor.DsId
'

print convert(varchar(50), @@ROWCOUNT) + ' rows affected'
end
else
print '##_tblStayPayor_update_CoPayor is empty no need to update live'

print 'Compliling #_tblRes_StayStatus'

IF OBJECT_ID('tempdb..#_tblPerson_EDate') IS NOT NULL
begin
print 'dropping #_tblPerson_EDate'
DROP TABLE #_tblPerson_EDate
end

IF OBJECT_ID('tempdb..#_tblRes_stayStatus') IS NOT NULL
begin
print 'dropping #_tblRes_stayStatus'
DROP TABLE #_tblRes_stayStatus
end

IF OBJECT_ID('tempdb..#_tblStay_stayStatus') IS NOT NULL
begin
print 'dropping #_tblStay_stayStatus'
DROP TABLE #_tblStay_stayStatus
end

IF OBJECT_ID('tempdb..##_tblRes_stayStatus_diff') IS NOT NULL
begin
print 'dropping ##_tblRes_stayStatus_diff'
DROP TABLE ##_tblRes_stayStatus_diff
end




select person.Id PersonId, person.EDate
into #_tblPerson_EDate
from #_tblPerson person
join #_tblPhysicalEntity pe on person.PeId = pe.Id


select res.Id ResId, res.PersonId, res.StayStatus
into #_tblRes_stayStatus
from #_tblResident res
join #_tblPhysicalEntity pe on res.PeId = pe.Id


--I used to do it by stayId and it was simple. But I was assuming that the latest stay will always be the max stay id, but that assomption is
--not valid, because if a user tempers with an existing row in DS (which is already mapped in the sync) and makes it into the latest it'll break that
--logic, therefore I now have to go purly by diss dates.
--I need to do a couple of layers here, because the first layer can return mulitiple rows because a res can have the same discharge multiple times in the same day
--but i need to get the latest status so i just need the top row based on the latest diss date and within that the latest admission date
select s.Id StayId, s.ResId, s.Admission, s.Discharge, s.DsId, s.IsBh
into #_tblStay_stayStatus
from(
select s.ResId, max(s.Admission) Admission, isnull(max(s.Discharge), getdate()) Discharge
from (
select ResId, max(isnull(Discharge, getdate())) MaxDis
from #_tblStay
group by ResId
) as maxDis
join #_tblStay s on maxDis.ResId = s.ResId and maxDis.MaxDis = isnull(s.Discharge, getdate())
group by s.ResId
) as maxStay
join #_tblStay s on maxStay.ResId = s.ResId and maxStay.Discharge = isnull(s.Discharge, getdate()) and maxStay.Admission = s.Admission

update #_tblRes_stayStatus
set StayStatus = case when p.EDate is not null then 'E' when s.Discharge is not null or s.IsBh = 1 then 'D' else 'A' end
from #_tblRes_stayStatus r
left join #_tblPerson_EDate p on r.PersonId = p.PersonId
left join #_tblStay_stayStatus s on r.ResId = s.ResId

select r.*
into ##_tblRes_stayStatus_diff
from #_tblRes_stayStatus r
join #_tblResident rLive on r.ResId = rLive.Id
where r.StayStatus <> isnull(rLive.StayStatus, 'L')

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblRes_stayStatus_diff
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblRes_stayStatus_diff'')

update rlive
set StayStatus = r.StayStatus,
StayStatusLastUpdated = getdate()
from #_tblRes_stayStatus_diff r
join xTrack.dbo.tblResident rlive on r.ResId = rlive.Id
'
print 'End #_tblRes_StayStatus'


delete from #_tblResident_raw
delete from #_tblResident

print 'Compliling #_tblRes_beds'

IF OBJECT_ID('tempdb..#_tblRes_resStay') IS NOT NULL
begin
print 'dropping #_tblRes_resStay'
DROP TABLE #_tblRes_resStay
end

IF OBJECT_ID('tempdb..#_resbeds') IS NOT NULL
begin
print 'dropping #_resbeds'
DROP TABLE #_resbeds
end

IF OBJECT_ID('tempdb..#_resdents_beds') IS NOT NULL
begin
print 'dropping #_resdents_beds'
DROP TABLE #_resdents_beds
end

IF OBJECT_ID('tempdb..##_tblRes_bed_diff') IS NOT NULL
begin
print 'dropping ##_tblRes_bed_diff'
DROP TABLE ##_tblRes_bed_diff
end

IF OBJECT_ID('tempdb..#currentlyActiveRes') IS NOT NULL
begin
print 'dropping #currentlyActiveRes'
DROP TABLE #currentlyActiveRes
end

insert into #_tblResident_raw
select res.*
from ArTrackServer.xTrack.dbo.tblResident res

print 'creating #_tblResident'
insert into #_tblResident
select res.*
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id

select res.*
into #currentlyActiveRes
from #_tblResident res
join #_tblPhysicalEntity pe on res.PeId = pe.Id
and StayStatus = 'A' 

select r.BedNumber, r.StayStatus, s.ResId, s.StayId, r.DsId, s.DsId stayDsId
into #_tblRes_resStay
from #currentlyActiveRes r
join #_tblStay_stayStatus s on s.ResId = r.Id

-- get the max res bed 
select rb.*, b.cbedno, ResBed.DsId stayDsId
into #_resbeds
from
(select  max(b.cid) resBedId, s.FacId, s.DsId
from resbed b
join resstay s on s.cid = b.cresstayid and s.FacId = b.FacId
group by s.cid, s.FacId, s.DsId)
as ResBed 
join resbed rb on ResBed.resBedId = rb.cid and ResBed.FacId = rb.FacId
left join beds b on (b.cid = rb.cbedid  and b.FacId = rb.FacId)

-- join the max stay with the resstay and max resbed to get the bed number for the max resbed of the maxstay
select b.cbedno bedNum, rs.*
into #_resdents_beds
from #_tblRes_resStay rs
left join #_resbeds b on rs.stayDsId = b.stayDsId

--update locally 
update #_tblRes_resStay
set BedNumber = rb.bedNum
from #_tblRes_resStay tblRes 
left join #_resdents_beds rb on tblRes.DsId = rb.DsId  

--put differences into #tblRes_bed_diff
select rs.*
into ##_tblRes_bed_diff
from  #_tblRes_resStay rs
join #_tblResident rLive on rs.ResId = rLive.Id
where rs.BedNumber <> isnull(rLive.BedNumber, '')

--select * from #_tblRes_bed_diff


exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblRes_bed_diff
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblRes_bed_diff'')

update rlive
set BedNumber = b.BedNumber
from #_tblRes_bed_diff b
join xTrack.dbo.tblResident rlive on b.ResId = rlive.Id
'

print 'End Res Beds'

print 'Refreshing Res Stay Status & Bed Info'

delete from #_tblResident_raw

delete from #_tblResident

print 'creating #_tblResident'
insert into #_tblResident_raw
select res.*
from ArTrackServer.xTrack.dbo.tblResident res

insert into #_tblResident
select res.*
from #_tblResident_raw res
join #_tblPhysicalEntity pe on res.PeId = pe.Id


print 'Compliling #distinctUnits'

IF OBJECT_ID('tempdb..#_tblNameValue_DistinctUnits') IS NOT NULL
begin
print 'dropping #_tblNameValue_DistinctUnits'
DROP TABLE #_tblNameValue_DistinctUnits
end

IF OBJECT_ID('tempdb..##_tblNameValueDistinctUnits_insert') IS NOT NULL
begin
print 'dropping ##_tblNameValueDistinctUnits_insert'
DROP TABLE ##_tblNameValueDistinctUnits_insert
end

IF OBJECT_ID('tempdb..#_tblFacDistinctUnit') IS NOT NULL
begin
print 'dropping #_tblFacDistinctUnit'
DROP TABLE #_tblFacDistinctUnit
end

IF OBJECT_ID('tempdb..##tblFacDistintUnit_insert') IS NOT NULL
begin
print 'dropping ##tblFacDistintUnit_insert'
DROP TABLE ##tblFacDistintUnit_insert
end

IF OBJECT_ID('tempdb..#_tblPe') IS NOT NULL
begin
print 'dropping #_tblPe'
DROP TABLE #_tblPe
end

IF OBJECT_ID('tempdb..##distinctUnitParentId') IS NOT NULL
begin
print 'dropping ##distinctUnitParentId'
DROP TABLE ##distinctUnitParentId 
end

IF OBJECT_ID('tempdb..#_tblNameValue_DistinctUnits1') IS NOT NULL
begin
print 'dropping #_tblNameValue_DistinctUnits1'
DROP TABLE #_tblNameValue_DistinctUnits1 
end

IF OBJECT_ID('tempdb..#_distinctUnits') IS NOT NULL
begin
print 'dropping #_distinctUnits'
DROP TABLE #_distinctUnits 
end

IF OBJECT_ID('tempdb..##_tbldistinctUnits_deleted') IS NOT NULL
begin
print 'dropping ##_tbldistinctUnits_deleted'
DROP TABLE ##_tbldistinctUnits_deleted
end

IF OBJECT_ID('tempdb..#_tlbFacDistinctUnitLive') IS NOT NULL
begin
print 'dropping #_tlbFacDistinctUnitLive'
DROP TABLE #_tlbFacDistinctUnitLive
end

IF OBJECT_ID('tempdb..##_tbldistinctUnits_deleted') IS NOT NULL
begin
print 'dropping ##_tbldistinctUnits_deleted'
DROP TABLE ##_tbldistinctUnits_deleted
end

IF OBJECT_ID('tempdb..##tblFacDistintUnit_updateDefaults') IS NOT NULL
begin
print 'dropping ##tblFacDistintUnit_updateDefaults'
DROP TABLE ##tblFacDistintUnit_updateDefaults
end

IF OBJECT_ID('tempdb..##tblFacDistintUnit_updateDeletes') IS NOT NULL
begin
print 'dropping ##tblFacDistintUnit_updateDeletes'
DROP TABLE ##tblFacDistintUnit_updateDeletes
end

select nv.Id parentId
into ##distinctUnitParentId 
from #_tblNameValue nv
where Name = 'Case.DistinctUnits'

select  nv.Id, nv.Name, nv.ParentId
into #_tblNameValue_DistinctUnits 
from #_tblNameValue nv 
join ##distinctUnitParentId du on nv.ParentId = du.parentId

select fdu.*
into #_tblFacDistinctUnit 
from ArTrackServer.xTrack.dbo.tblFacDistinctUnit fdu
join #_tblPhysicalEntity pe on fdu.PeId = pe.Id

select pe.Id, pe.DsId
into #_tblPe
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
join #_tblPhysicalEntity facWoHalfBakedData on pe.Id = facWoHalfBakedData.Id
where pe.LevelId =3 --we prob want to add this filter here, as we only need facilities


select distinct du.ccode
into ##_tblNameValueDistinctUnits_insert
from [dbo].[disunits] du
left join #_tblNameValue_DistinctUnits nv on du.ccode collate SQL_Latin1_General_CP1_CS_AS = nv.Name collate SQL_Latin1_General_CP1_CS_AS
where nv.Name is null

-- add the name values to the tblNameValue 

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tblNameValueDistinctUnits_insert
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tblNameValueDistinctUnits_insert'')

select * 
into #distinctUnitParentId
FROM OPENQUERY(ArTrackSyncServer,''select * from ##distinctUnitParentId'')

insert xTrack.dbo.tblNameValue 
(Name, FriendlyName, ParentId)
select du.ccode, du.ccode, (select parentId from #distinctUnitParentId)
from #_tblNameValueDistinctUnits_insert du
'

delete from #_tblNameValue

print 'Refreshing #_tblNameValue'
insert #_tblNameValue
select *
from ArTrackServer.xTrack.dbo.tblNameValue 

select  nv.Id, nv.Name, nv.ParentId
into #_tblNameValue_DistinctUnits1
from #_tblNameValue nv 
join ##distinctUnitParentId du on nv.ParentId = du.parentId

--next we need to add every fac and it's du to tblfacdu
select pe.Id peId, nv.Id duNvId, du.ldefault
into ##tblFacDistintUnit_insert
from [dbo].[disunits] du 
join [dbo].[Global_Facilities] dsFac on du.FacId = dsFac.nid
join #_tblPe pe on dsFac.nid = pe.DsId
join #_tblNameValue_DistinctUnits1 nv on nv.Name collate SQL_Latin1_General_CP1_CS_AS = du.ccode collate SQL_Latin1_General_CP1_CS_AS
left join #_tblFacDistinctUnit liveDu on pe.Id = liveDu.PeId and nv.Id = liveDu.DuNvId
where liveDu.Id is null 

--reinstating fac du's
select liveDu.Id
into ##tblFacDistintUnit_updateDeletes
from [dbo].[disunits] du 
join [dbo].[Global_Facilities] dsFac on du.FacId = dsFac.nid
join #_tblPe pe on dsFac.nid = pe.DsId
join #_tblNameValue_DistinctUnits1 nv on nv.Name collate SQL_Latin1_General_CP1_CS_AS = du.ccode collate SQL_Latin1_General_CP1_CS_AS
join #_tblFacDistinctUnit liveDu on pe.Id = liveDu.PeId and nv.Id = liveDu.DuNvId and liveDu.StateId = 1098

--updating fac du defaults
select liveDu.Id, du.ldefault
into ##tblFacDistintUnit_updateDefaults
from #_tblFacDistinctUnit liveDu 
join #_tblNameValue_DistinctUnits1 nv on nv.Id = liveDu.DuNvId 
join #_tblPe pe on pe.Id = liveDu.PeId
join [dbo].[disunits] du on nv.Name collate SQL_Latin1_General_CP1_CS_AS = du.ccode collate SQL_Latin1_General_CP1_CS_AS
join [dbo].[Global_Facilities] dsFac on du.FacId = dsFac.nid and dsFac.nid = pe.DsId
where 1=1
and(isnull(liveDu.IsDefault,0) <> du.ldefault)

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #tblFacDistintUnit_insert 
FROM OPENQUERY(ArTrackSyncServer,''select * from ##tblFacDistintUnit_insert'')

select * 
into #tblFacDistintUnit_updateDeletes 
FROM OPENQUERY(ArTrackSyncServer,''select * from ##tblFacDistintUnit_updateDeletes'')

select * 
into #tblFacDistintUnit_updateDefaults 
FROM OPENQUERY(ArTrackSyncServer,''select * from ##tblFacDistintUnit_updateDefaults'')

insert xTrack.dbo.tblFacDistinctUnit 
(PeId, DuNvId, isDefault) 
select peId, duNvId, ldefault
from #tblFacDistintUnit_insert

update facDu
set StateId = 1097
from #tblFacDistintUnit_updateDeletes updt
join xTrack.dbo.tblFacDistinctUnit facDu on updt.Id = facDu.Id

update facDu
set IsDefault = updt.ldefault
from #tblFacDistintUnit_updateDefaults updt
join xTrack.dbo.tblFacDistinctUnit facDu on updt.Id = facDu.Id

'

-----------------deletes---------------
select du.ccode, du.FacId
into #_distinctUnits
from [dbo].[disunits] du

select du.* 
into #_tlbFacDistinctUnitLive
from ArTrackServer.xTrack.dbo.tblFacDistinctUnit du
join #_tblPhysicalEntity pe on du.PeId = pe.Id
--where du.Deleted = 0 
where du.StateId = 1097

select fdu.*
into ##_tbldistinctUnits_deleted
from #_tlbFacDistinctUnitLive fdu
join #_tblPe pe on pe.Id = fdu.PeId 
join #_tblNameValue_DistinctUnits nv on nv.Id = fdu.DuNvId
left join #_distinctUnits du on du.FacId = pe.DsId and nv.Name collate SQL_Latin1_General_CP1_CS_AS = du.ccode collate SQL_Latin1_General_CP1_CS_AS
where du.FacId is null 

update duDeleted
set 
StateId = 1098
from ##_tbldistinctUnits_deleted duDeleted

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_tbldistinctUnits_deleted 
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_tbldistinctUnits_deleted'')

update liveDu
set
StateId = ddu.StateId
from xTrack.dbo.tblFacDistinctUnit liveDu
join #_tbldistinctUnits_deleted ddu on ddu.Id = liveDu.Id
'


----adding aging tables

print 'Compliling #tblAging'
--only run the next section if the sync ported over the aging tables 
--(which only happens a couple of times a day, because it's slows down the sync)
IF (EXISTS (select *
from INFORMATION_SCHEMA.TABLES
where TABLE_SCHEMA = 'dbo'
and TABLE_NAME = 'AR_billfinl'))
BEGIN

print 'this is an aging schedule, processing aging - it''ll take some time so sit back and relax'

IF OBJECT_ID('tempdb..#_tblFacDuWithDksInfo') IS NOT NULL
begin
print 'dropping #_tblFacDuWithDksInfo'
DROP TABLE #_tblFacDuWithDksInfo
end

IF OBJECT_ID('tempdb..[##aging.bill_insert]') IS NOT NULL
begin
print 'dropping [##aging.bill_insert]'
DROP TABLE [##aging.bill_insert]
end

IF OBJECT_ID('tempdb..[##aging.cr_insert]') IS NOT NULL
begin
print 'dropping [##aging.cr_insert]'
DROP TABLE [##aging.cr_insert]
end

IF OBJECT_ID('tempdb..[##aging.bill_delete]') IS NOT NULL
begin
print 'dropping [##aging.bill_delete]'
DROP TABLE [##aging.bill_delete]
end
IF OBJECT_ID('tempdb..[##aging.cr_delete]') IS NOT NULL
begin
print 'dropping [##aging.cr_delete]'
DROP TABLE [##aging.cr_delete]
end

IF OBJECT_ID('tempdb..[##aging.bill_update]') IS NOT NULL
begin
print 'dropping [##aging.bill_update]'
DROP TABLE [##aging.bill_update]
end

IF OBJECT_ID('tempdb..[##aging.cr_update]') IS NOT NULL
begin
print 'dropping [##aging.cr_update]'
DROP TABLE [##aging.cr_update]
end

IF OBJECT_ID('tempdb..[##vwAging]') IS NOT NULL
begin
print 'dropping [##vwAging]'
DROP TABLE [##vwAging]
end

IF OBJECT_ID('tempdb..[##vwPayorsAndGroups]') IS NOT NULL
begin
print 'dropping [##vwPayorsAndGroups]'
DROP TABLE [##vwPayorsAndGroups]
end

IF OBJECT_ID('tempdb..##vwAgingAllInfo') IS NOT NULL
begin
print 'dropping ##vwAgingAllInfo'
DROP TABLE ##vwAgingAllInfo
end

IF OBJECT_ID('tempdb..##newBal_insertJustBals') IS NOT NULL
begin
print 'dropping ##newBal_insertJustBals'
DROP TABLE ##newBal_insertJustBals
end

IF OBJECT_ID('tempdb..[#_tblAging.Bill]') IS NOT NULL
begin
print 'dropping [#_tblAging.Bill]'
DROP TABLE [#_tblAging.Bill]
end

IF OBJECT_ID('[tblAging.Bill]') IS NOT NULL
begin
print 'dropping [tblAging.Bill]'
DROP TABLE [tblAging.Bill]
end

IF OBJECT_ID('tempdb..[#_tblAging.Cr]') IS NOT NULL
begin
print 'dropping [#_tblAging.Cr]'
DROP TABLE [#_tblAging.Cr]
end

IF OBJECT_ID('[tblAging.Cr]') IS NOT NULL
begin
print 'dropping [tblAging.Cr]'
DROP TABLE [tblAging.Cr]
end

IF OBJECT_ID('tempdb..[#_tblAging.Bal_Old]') IS NOT NULL
begin
print 'dropping [#_tblAging.Bal_Old]'
DROP TABLE [#_tblAging.Bal_Old]
end

IF OBJECT_ID('[tblAging.Bal_Old]') IS NOT NULL
begin
print 'dropping [tblAging.Bal_Old]'
DROP TABLE [tblAging.Bal_Old]
end

delete from #_tblNameValue

IF OBJECT_ID('[tblAging.Bal_New]') IS NOT NULL
begin
print 'dropping [tblAging.Bal_New]'
DROP TABLE [tblAging.Bal_New]
end

IF OBJECT_ID('tempdb..##groupBillDuDisplay') IS NOT NULL
begin
print 'dropping ##groupBillDuDisplay'
DROP TABLE ##groupBillDuDisplay
end

IF OBJECT_ID('tempdb..##AR_payfinl_AdditionalStepForCrType') IS NOT NULL
begin
print 'dropping ##AR_payfinl_AdditionalStepForCrType'
DROP TABLE ##AR_payfinl_AdditionalStepForCrType
end

IF OBJECT_ID('tempdb..##AR_payfinl') IS NOT NULL
begin
print 'dropping ##AR_payfinl'
DROP TABLE ##AR_payfinl
end

print 'creating #_tblNameValue'
insert #_tblNameValue
select *
from ArTrackServer.xTrack.dbo.tblNameValue
print convert(varchar(50), @@ROWCOUNT) + ' rows affected'

--this block 1:39

ALTER TABLE #_tblNameValue 
ALTER COLUMN Abbreviation VARCHAR(10) COLLATE Latin1_General_CS_AS
ALTER TABLE #_tblPayor 
ALTER COLUMN Code VARCHAR(50) COLLATE Latin1_General_CS_AS
ALTER TABLE AR_billfinl
ALTER COLUMN csrvtypdsc VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS
ALTER TABLE AR_payfinl
ALTER COLUMN csrvtypdsc VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS
ALTER TABLE disunits
ALTER COLUMN ccode VARCHAR(5000) COLLATE SQL_Latin1_General_CP1_CI_AS
--2:20

CREATE TABLE [tblAging.Bill](
	[Id]				[int] IDENTITY(1,1) NOT NULL,
	[DsId]				[varbinary](900) NULL,
	[ResId]				[int] NOT NULL,
	[StartDate]			[date] NOT NULL,
	[EndDate]			[date] NULL,
	[BillingMonth]		[date] NULL,
	[TransactionDate]   [datetime] NULL,
	[PayorId]			[int] NULL,
	[ServiceTypeId]		[int] NULL,
	[PayTypeId]			[int] NULL,
	[TherapyType]		[varchar](500) NULL,
    [FacDuId] 			[int] NULL,
	[Balance]			[money] NOT NULL,
	[Identifier]		[varchar](500) NULL,
	[UniqueIdentifier]	[varchar](500) NULL,
	[TrackingIdentifier][varchar](500) NULL,
	[CreatedOn]			[datetime] NULL,
	[AllInclusive]		[bit] NULL,
	[Writeoff]			[bit] NULL
	)

select *
into [#_tblAging.Bill]
from ArTrackServer.xTrack.dbo.[tblAging.Bill] bill

--drop table [tblAging.Bill]
insert [tblAging.Bill]
(DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, UniqueIdentifier, TrackingIdentifier, AllInclusive, Writeoff, FacDuId)
select bill.DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, UniqueIdentifier, TrackingIdentifier, AllInclusive, Writeoff, FacDuId
from [#_tblAging.Bill] bill
join #_tblResident res on bill.ResId = res.Id
where Balance  <> 0

--drop table [tblAging.Cr]

CREATE TABLE  [tblAging.Cr](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DsId] [varbinary](900) NULL,
	[ResId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[BillingMonth] [date] NULL,
	[TransactionDate] [datetime] NULL,
	[PayorId] [int] NULL,
	[ServiceTypeId] [int] NULL,
	[PayTypeId] [int] NULL,
	[TherapyType] [varchar](500) NULL,
    [FacDuId] [int] NULL,
	[Balance] [money] NOT NULL,
	[CrTypeId] [int] NULL,
	[Identifier] [varchar](500) NULL,
	[UniqueIdentifier] [varchar](500) NULL,
	[TrackingIdentifier] [varchar](500) NULL,
	[CreatedOn] [datetime] NULL
)

select *
into [#_tblAging.Cr]
from ArTrackServer.xTrack.dbo.[tblAging.Cr] cr

--below took 2:01
insert [tblAging.Cr]
(DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, FacDuId, CrTypeId, UniqueIdentifier, TrackingIdentifier)
select cr.DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, FacDuId, CrTypeId, UniqueIdentifier, TrackingIdentifier
from [#_tblAging.Cr] cr
join #_tblResident res on cr.ResId = res.Id
where Balance  <> 0
--2 above 2m
------

Create Table #_tblFacDuWithDksInfo(
	Name [varchar] (5000) NULL,
    FacDuId [int] NULL,
	PeId [int] NULL,
	cid [varchar] (400) NOT NULL,
	FacId [int] NOT NULL,
	Unique CLUSTERED (cid,FacId)
)	 

--save facDu with du name and disunits info to optimize the next few queries
insert  #_tblFacDuWithDksInfo 
                  (Name, FacDuId, PeId, cid, FacId)
select du.Name, fdu.Id FacDuId, fdu.PeId, units.cid, units.FacId
from #_tlbFacDistinctUnitLive fdu
join  #_tblNameValue_DistinctUnits1 du on fdu.DuNvId = du.Id
join #_tblPhysicalEntity pe on fdu.PeId = pe.Id
join disunits units on du.Name = units.ccode collate SQL_Latin1_General_CP1_CI_AS and pe.DsId = units.FacId
order by FacId, cid

select PayorId, PayorName, PayorFriendlyName
, case when isnull(payorCat, 'Root') <> 'Root' then a.payorCatId else payorGroupId end PayorGroupId
, case when isnull(payorCat, 'Root') <> 'Root' then a.payorCat else payorGroup end PayorGroup
into ##vwPayorsAndGroups
from(
select payor.Id PayorId, payor.Name PayorName, payor.FriendlyName PayorFriendlyName
, payorGroup.Id payorGroupId, payorGroup.Name payorGroup, payorCat.Id payorCatId, payorCat.Name payorCat
from #_tblPayor payor
left join #_tblPayor payorGroup on payor.ParentId = payorGroup.Id
left join #_tblPayor payorCat on payorGroup.ParentId = payorCat.Id
) as a

print 'created ##vwPayorsAndGroups:' + convert(varchar(50), @@rowcount)

select bill.DsId DsId, xRes.Id ResId, bill.dstart StartDate, bill.dstop EndDate, xPayors.Id PayorId, serviceTypeNv.Id ServiceTypeId, payTypeNv.Id PayTypeId, bill.csrvtypdsc TherapyType, bill.nnetamt Balance
, '' Identifier
,((((((CONVERT([varchar](50),xRes.Id)+'-')+CONVERT([varchar](50),xPayors.Id))+'-')+bill.cpaytype+bill.cservictyp)+'-')+CONVERT([varchar](50),fdu.Name collate Latin1_General_CS_AS+'-')+CONVERT([varchar](50),dateadd(month,datediff(month,(0),bill.dstart),(0)),(23))) UniqueIdentifier
, CONVERT([varchar](50),xRes.Id)+'-'+CONVERT([varchar](50),xGroups.PayorGroupId) TrackingIdentifier
, DATEADD(MONTH, DATEDIFF(MONTH, 0, bill.dstart), 0) BillingMonth, bill.ddate TransactionDate
, bill.lallinclusive AllInclusive, bill.writeoff Writeoff, fdu.FacDuId
into [##aging.bill_insert] 
from AR_billfinl bill
left join [tblAging.Bill] xBill on xBill.DsId = bill.DsId
join resdents res on (bill.cresid = res.cid and bill.FacId = res.FacId)
join #_tblResident xRes on res.DsId = xRes.DsId
join payors payors on (bill.cpayor = payors.cid and bill.FacId = payors.FacId and bill.FacId = res.FacId)
join #_tblPayor xPayors on payors.DsId = xPayors.DsId
join ##vwPayorsAndGroups xGroups on xPayors.Id = xGroups.PayorId
left join #_tblNameValue serviceTypeNv on bill.cservictyp collate SQL_Latin1_General_CP1_CI_AS = serviceTypeNv.Abbreviation     --check to see if we actually need collate
left join #_tblNameValue payTypeNv on bill.cpaytype  collate SQL_Latin1_General_CP1_CI_AS = payTypeNv.Abbreviation		       --same
join #_tblFacDuWithDksInfo fdu on (bill.cdistinctunit collate SQL_Latin1_General_CP1_CI_AS = fdu.cid collate SQL_Latin1_General_CP1_CI_AS and bill.FacId = fdu.FacId)--same
where bill.writeoff = 0 
and bill.lallinclusive =0
and xBill.DsId is null	

print 'bill insert is:' + convert(varchar(50), @@rowcount)
--drop table [##aging.cr_insert]
--below took 5:29

select pay.*
, case when pay.writeoff = 1 then
        case when glMapper.cglnamesid is not null then 'BadDebt' else 'Writeoff' end 
  else 'CashReceipt' end CrType
into ##AR_payfinl_AdditionalStepForCrType
from AR_payfinl pay
left join AR_glnames gl on (pay.cothdeddes = gl.cid and pay.FacId = gl.FacId)
left join actgrpd glMapper on (glMapper.cglnamesid = gl.cid and glMapper.FacId = gl.FacId and glMapper.cactgrphid = '6')

select pay.*, nv.Id CrTypeId
into ##AR_payfinl
from ##AR_payfinl_AdditionalStepForCrType pay
left join #_tblNameValue nv on pay.CrType = nv.Name collate SQL_Latin1_General_CP1_CI_AS and ParentId = (Select Id from #_tblNameValue where Name = 'Aging.Cr.ReceiptType')

select bill.DsId DsId, xRes.Id ResId, bill.dstart StartDate, bill.dstop EndDate, xPayors.Id PayorId, serviceTypeNv.Id ServiceTypeId, payTypeNv.Id PayTypeId, bill.csrvtypdsc TherapyType, bill.nnetamt Balance
, bill.CrTypeId
, '' Identifier
,((((((CONVERT([varchar](50),xRes.Id)+'-')+CONVERT([varchar](50),xPayors.Id))+'-')+bill.cpaytype+bill.cservictyp)+'-')+CONVERT([varchar](50),fdu.Name collate Latin1_General_CS_AS+'-')+CONVERT([varchar](50),dateadd(month,datediff(month,(0),bill.dstart),(0)),(23))) UniqueIdentifier
, CONVERT([varchar](50),xRes.Id)+'-'+CONVERT([varchar](50),xGroups.PayorGroupId) TrackingIdentifier
, DATEADD(MONTH, DATEDIFF(MONTH, 0, bill.dstart), 0) BillingMonth, bill.ddate TransactionDate, fdu.FacDuId
into [##aging.cr_insert]
from ##AR_payfinl bill
left join [tblAging.Cr] xpay on xpay.DsId = bill.DsId
join resdents res on (bill.cresid = res.cid and bill.FacId = res.FacId)
join #_tblResident xRes on res.DsId = xRes.DsId
join payors payors on (bill.cpayor = payors.cid and bill.FacId = payors.FacId)
join #_tblPayor xPayors on payors.DsId = xPayors.DsId
join ##vwPayorsAndGroups xGroups on xPayors.Id = xGroups.PayorId
left join #_tblNameValue serviceTypeNv on bill.cservictyp collate SQL_Latin1_General_CP1_CI_AS = serviceTypeNv.Abbreviation      --check to see if we actually need collate
left join #_tblNameValue payTypeNv on bill.cpaytype  collate SQL_Latin1_General_CP1_CI_AS = payTypeNv.Abbreviation				--same
join #_tblFacDuWithDksInfo fdu on (bill.cdistinctunit collate SQL_Latin1_General_CP1_CI_AS = fdu.cid collate SQL_Latin1_General_CP1_CI_AS and bill.FacId = fdu.FacId)	--same
where 1=1
and xpay.DsId is null

print 'cr insert is:' + convert(varchar(50), @@rowcount)

select xBill.*
into [##aging.bill_delete]
from [tblAging.Bill] xBill 
left join AR_billfinl bill on xBill.DsId = bill.DsId
where bill.cid is null

print 'bill delete is:' + convert(varchar(50), @@rowcount)

select xcr.*
into [##aging.cr_delete]
from [tblAging.Cr] xcr 
left join AR_payfinl pay on xcr.DsId = pay.DsId
where pay.cid is null

print 'cr delete is:' + convert(varchar(50), @@rowcount)

select bill.DsId DsId, xResBackUp.Id ResId, bill.dstart StartDate, bill.dstop EndDate, xPayors.Id PayorId, dsServiceTypeNv.Id ServiceTypeId, dsPayTypeNv.Id PayTypeId
, bill.csrvtypdsc TherapyType, bill.nnetamt balance
, (CONVERT([varchar](50),xResBackUp.Id)+'-')+CONVERT([varchar](50),xPayors.Id)+'-'+dsPayTypeNv.Abbreviation+dsServiceTypeNv.Abbreviation+'-'+Convert([varchar](50), fdu.name collate Latin1_General_CS_AS) + '-' + Convert([varchar](50),dateadd(month,datediff(month,(0),bill.dstart),(0)),(23)) UniqueIdentifier
, UniqueIdentifier OldUniqueIdentifier
, DATEADD(MONTH, DATEDIFF(MONTH, 0, bill.dstart), 0) BillingMonth, bill.ddate TransactionDate
, bill.lallinclusive AllInclusive
, bill.writeoff Writeoff, fdu.FacDuId 
into [##aging.bill_update]
from AR_billfinl bill
join [tblAging.Bill] xBill on xBill.DsId = bill.DsId
join #_tblResident xRes on xBill.ResId = xRes.Id
join resdents res on xRes.DsId = res.DsId
join resdents resUp on (bill.cresid = resUp.cid and bill.FacId = resUp.FacId)
join #_tblResident xResBackUp on resUp.DsId = xResBackUp.DsId
left join #_tblNameValue xServiceTypeNv on xBill.ServiceTypeId = xServiceTypeNv.Id 
left join #_tblNameValue xPayTypeNv on xBill.PayTypeId = xPayTypeNv.Id 
left join #_tblNameValue dsServiceTypeNv on bill.cservictyp  collate SQL_Latin1_General_CP1_CI_AS = dsServiceTypeNv.Abbreviation --check to see if we actually need collate
left join #_tblNameValue dsPayTypeNv on bill.cpaytype  collate SQL_Latin1_General_CP1_CI_AS = dsPayTypeNv.Abbreviation			--same
left join payors payors on (bill.cpayor = payors.cid and bill.FacId = payors.FacId)
left join #_tblPayor xPayors on payors.DsId = xPayors.DsId
join #_tblFacDuWithDksInfo fdu on (bill.cdistinctunit collate SQL_Latin1_General_CP1_CI_AS = fdu.cid collate SQL_Latin1_General_CP1_CI_AS and bill.FacId = fdu.FacId) --same
where 1=1
and (
   bill.cresid <> res.cid
or bill.nnetamt <> xBill.Balance
or bill.cservictyp  collate SQL_Latin1_General_CP1_CI_AS <> xServiceTypeNv.Abbreviation --same
or bill.cpaytype  collate SQL_Latin1_General_CP1_CI_AS  <> xPayTypeNv.Abbreviation		--same
or bill.csrvtypdsc  <> xBill.TherapyType collate SQL_Latin1_General_CP1_CI_AS
or bill.dstart <> xBill.StartDate
or bill.dstop <> xBill.EndDate
or xPayors.Id <> xBill.PayorId
or bill.lallinclusive <> xBill.AllInclusive
or bill.writeoff <> xBill.Writeoff
or isnull(fdu.FacDuId,0) <> isnull(xBill.FacDuId,0)
or isnull(bill.ddate,'') <> isnull(xBill.TransactionDate, '')
)

print 'bill update is:' + convert(varchar(50), @@rowcount)

select bill.DsId DsId
, xResBackUp.Id ResId, bill.dstart StartDate, bill.dstop EndDate, xPayors.Id PayorId, dsServiceTypeNv.Id ServiceTypeId, dsPayTypeNv.Id PayTypeId
, bill.csrvtypdsc TherapyType, bill.nnetamt balance
, bill.CrTypeId
, CONVERT([varchar](50),xResBackUp.Id)+'-'+CONVERT([varchar](50),xPayors.Id)+'-'+dsPayTypeNv.Abbreviation+dsServiceTypeNv.Abbreviation+'-'+Convert([varchar](50), fdu.name collate Latin1_General_CS_AS) + '-' + Convert([varchar](50),dateadd(month,datediff(month,(0),bill.dstart),(0)),(23)) UniqueIdentifier
, UniqueIdentifier OldUniqueIdentifier
, DATEADD(MONTH, DATEDIFF(MONTH, 0, bill.dstart), 0) BillingMonth, bill.ddate TransactionDate, fdu.FacDuId
into [##aging.cr_update]
--select *
from ##AR_payfinl bill
join [tblAging.Cr] xBill on xBill.DsId = bill.DsId
join #_tblResident xRes on xBill.ResId = xRes.Id
join resdents res on xRes.DsId = res.DsId
join resdents resUp on (bill.cresid = resUp.cid and bill.FacId = resUp.FacId)
join #_tblResident xResBackUp on resUp.DsId = xResBackUp.DsId
left join #_tblNameValue xServiceTypeNv on xBill.ServiceTypeId = xServiceTypeNv.Id 
left join #_tblNameValue xPayTypeNv on xBill.PayTypeId = xPayTypeNv.Id 
left join #_tblNameValue dsServiceTypeNv on bill.cservictyp collate SQL_Latin1_General_CP1_CI_AS = dsServiceTypeNv.Abbreviation 
left join #_tblNameValue dsPayTypeNv on bill.cpaytype collate SQL_Latin1_General_CP1_CI_AS = dsPayTypeNv.Abbreviation 
left join payors payors on (bill.cpayor = payors.cid and bill.FacId = payors.FacId)
left join #_tblPayor xPayors on payors.DsId = xPayors.DsId
join #_tblFacDuWithDksInfo fdu on (bill.cdistinctunit collate SQL_Latin1_General_CP1_CI_AS = fdu.cid collate SQL_Latin1_General_CP1_CI_AS and bill.FacId = fdu.FacId) --check to see if we actually need collate
where 1=1
and (
   bill.cresid <> res.cid
or bill.nnetamt <> xBill.Balance
or bill.cservictyp collate SQL_Latin1_General_CP1_CI_AS <> xServiceTypeNv.Abbreviation 
or bill.cpaytype collate SQL_Latin1_General_CP1_CI_AS <> xPayTypeNv.Abbreviation 
or bill.csrvtypdsc  <> xBill.TherapyType collate SQL_Latin1_General_CP1_CI_AS 
or bill.dstart <> xBill.StartDate
or bill.dstop <> xBill.EndDate
or xPayors.Id <> xBill.PayorId
or isnull(fdu.FacDuId,0) <> isnull(xBill.FacDuId,0)
or bill.CrTypeId <> isnull(xBill.CrTypeId,0)
or isnull(bill.ddate,'') <> isnull(xBill.TransactionDate,'')
) 

------apply locally
insert [tblAging.Bill]
(DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, UniqueIdentifier, AllInclusive, Writeoff, FacDuId)
select DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, UniqueIdentifier, AllInclusive, Writeoff ,FacDuId
from [##aging.bill_insert]

insert [tblAging.Cr]
(DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, CrTypeId, FacDuId, UniqueIdentifier)
select DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, CrTypeId, FacDuId, UniqueIdentifier
from [##aging.cr_insert]

delete from bill
from [tblAging.Bill] bill
join [##aging.bill_delete] bill_del on bill.Id = bill_del.Id

delete from cr
from [tblAging.Cr] cr
join [##aging.cr_delete] cr_del on cr.Id = cr_del.Id

update bill
set
  bill.ResId = billUpdate.ResId
, bill.Balance = billUpdate.balance
, bill.ServiceTypeId = billUpdate.ServiceTypeId
, bill.PayTypeId = billUpdate.PayTypeId
, bill.TherapyType = billUpdate.TherapyType
, bill.StartDate = billUpdate.StartDate
, bill.EndDate = billUpdate.EndDate
, bill.BillingMonth = billUpdate.BillingMonth
, bill.TransactionDate = billUpdate.TransactionDate
, bill.PayorId = billUpdate.PayorId
, bill.UniqueIdentifier = billUpdate.UniqueIdentifier
, bill.AllInclusive = billUpdate.AllInclusive
, bill.Writeoff = billUpdate.Writeoff
, bill.FacDuId = billUpdate.FacDuId
from  [tblAging.Bill] bill
join [##aging.bill_update] billUpdate on bill.DsId = billUpdate.DsId

update bill
set   
  bill.ResId = billUpdate.ResId
, bill.Balance = billUpdate.balance
, bill.ServiceTypeId = billUpdate.ServiceTypeId
, bill.PayTypeId = billUpdate.PayTypeId
, bill.TherapyType = billUpdate.TherapyType
, bill.StartDate = billUpdate.StartDate
, bill.EndDate = billUpdate.EndDate
, bill.BillingMonth = billUpdate.BillingMonth
, bill.TransactionDate = billUpdate.TransactionDate
, bill.PayorId = billUpdate.PayorId
, bill.FacDuId = billUpdate.FacDuId
, bill.CrTypeId = billUpdate.CrTypeId
, bill.UniqueIdentifier = billUpdate.UniqueIdentifier
from [tblAging.Cr] bill
join [##aging.cr_update] billUpdate on bill.DsId = billUpdate.DsId

delete from [tblAging.Bill]
where AllInclusive = 1 or Writeoff = 1

print 'got current bal table:' + convert(varchar(50), @@rowcount)

select * 
into ##vwAging
from(
select distinct [UniqueIdentifier] AgingKeyWithDates, ResId, PayorId, ServiceTypeId, PayTypeId,BillingMonth, FacDuId
from(
select [UniqueIdentifier], ResId, PayorId, ServiceTypeId, PayTypeId, Balance bal, BillingMonth, FacDuId
from [dbo].[tblAging.Bill] bill

union all 
select [UniqueIdentifier], ResId , PayorId, ServiceTypeId, PayTypeId, Balance, BillingMonth, FacDuId
from [dbo].[tblAging.Cr] bill
) as a
) as b
join (
select UniqueIdentifier, sum(bal) bal
from(
select [UniqueIdentifier], sum(Balance) bal
 from [dbo].[tblAging.Bill] bill
 group by [UniqueIdentifier]
 
 union all

select [UniqueIdentifier], sum(Balance) bal
 from [dbo].[tblAging.Cr] bill
 where Balance <> 0
 group by [UniqueIdentifier]
) as bal
 group by UniqueIdentifier
 ) as outerbal on b.AgingKeyWithDates collate SQL_Latin1_General_CP1_CI_AS= outerbal.UniqueIdentifier
 
 print 'created ##vwAging:' + convert(varchar(50), @@rowcount)
-- select * from ##vwAging
--drop table ##vwAgingAllInfo
---first bring ##vwAging up to date with all the info
select
  aging.UniqueIdentifier
  , Convert([varchar](50), aging.ResId) +'-'+  Convert([varchar](50), aging.PayorId)+'-'+ payType.Abbreviation + serviceType.Abbreviation [AgingKey-RPPS] 
  , Convert([varchar](50), aging.ResId) +'-'+  Convert([varchar](50), aging.PayorId)+'-'+ payType.Abbreviation + serviceType.Abbreviation + '-' + CONVERT([varchar](50),fdu.Name collate Latin1_General_CS_AS) [AgingKey-RPPSD] 
  , aging.UniqueIdentifier [AgingKey-RPPSDM] 
  , Convert([varchar](50), aging.ResId) +'-'+  Convert([varchar](50), aging.PayorId)+'-'+ payType.Abbreviation + serviceType.Abbreviation + '-' + Convert([varchar](50), aging.BillingMonth)[AgingKey-RPPSM] 
  , res.PeId FacId, case when isnull(pe.FriendlyName,'') <> '' then pe.FriendlyName else pe.Name end Fac, aging.ResId, person.Last + ' ' + person.First + ' ' + person.Middle Res
  , case when pgroupMedicaid.Name = 'Root' then pgroup.Id else pgroupMedicaid.Id end PayorGroupId
  , case when pgroupMedicaid.Name = 'Root' then pgroup.Name else pgroupMedicaid.Name end PayorGroup
, aging.PayorId, pp.Name Payor, aging.PayTypeId, payType.Abbreviation PayType, aging.ServiceTypeId, serviceType.Abbreviation ServiceType
, aging.BillingMonth
, aging.bal Balance
, aging.bal [Balance-RPPSDM]
, cast(0.00  as money)[Balance-RPPSM]
, res.McaNum MedicareNum
, res.McoNum MedicaidNum
, res.IsPending
, person.Social Ssn
, person.BDate Dob
, res.SystemNo SystemNo
, case when person.Male = 1 then 'M' else 'F' end Gender
, res.StayStatus
, aging.FacDuId, fdu.Name Du
, res.InLegal
, Convert([varchar](50), aging.ResId)+'-'+convert([varchar](50), case when pgroupMedicaid.Name = 'Root' then pgroup.Id else pgroupMedicaid.Id end) TrackingIdentifier
, pgroup.BreakByDu
, cast(null as varchar(50)) [Du-Min]
, cast(null as varchar(50)) [Du-Display]
into ##vwAgingAllInfo
from ##vwAging aging
join #_tblResident res on aging.ResId = res.Id
join #_tblPhysicalEntity pe on res.PeId = pe.Id
join #_tblPerson person on res.PersonId = person.Id
join #_tblPayor pp on pp.Id = aging.PayorId
join #_tblPayor pgroup on pgroup.Id = pp.ParentId
join #_tblPayor pgroupMedicaid on pgroup.ParentId = pgroupMedicaid.Id
join #_tblNameValue payType on payType.Id = aging.PayTypeId
join #_tblNameValue serviceType on serviceType.Id = aging.ServiceTypeId
join  #_tblFacDuWithDksInfo fdu on aging.FacDuId = fdu.FacDuId
where aging.bal <> 0

--updating RPPSM level info besides for the DuDisplay  
update aging
set Balance = case when isnull(BreakByDu,0) = 0 then updt.Balance_RPPSM else aging.[Balance-RPPSDM] end,
	[Balance-RPPSM] = updt.Balance_RPPSM,
	[Du-Min] = updt.[Du-Min]
from ##vwAgingAllInfo aging
join (select [AgingKey-RPPSM], SUM(Balance) Balance_RPPSM, Min(Du) [Du-Min]
	  from  ##vwAgingAllInfo
	  group by [AgingKey-RPPSM]
	 ) updt on aging.[AgingKey-RPPSM] = updt.[AgingKey-RPPSM]

delete from aging
from ##vwAgingAllInfo aging
where 1=1
and Balance = 0	

--updating the RPPSM level for which Du to display depending if the billing table has only one distinct Du (that will end up in the balance table)
select bal.[AgingKey-RPPSM],case when max(bill.FacDuId) <> min(bill.FacDuId) then null else min(bal.Du) end DuDisplay
into ##groupBillDuDisplay
from [tblAging.Bill] bill
join (select distinct UniqueIdentifier 
	  from [tblAging.Bill] 
	  group by UniqueIdentifier
	  having Sum(Balance) <> 0) nonzerobill on bill.UniqueIdentifier = nonzerobill.UniqueIdentifier
join ##vwAgingAllInfo bal on bill.UniqueIdentifier = bal.UniqueIdentifier
group by bal.[AgingKey-RPPSM]

update bal
set [Du-Display] = bdu.DuDisplay
from ##vwAgingAllInfo bal
join ##groupBillDuDisplay bdu on bal.[AgingKey-RPPSM] = bdu.[AgingKey-RPPSM]
where isnull(BreakByDu,0) = 0

update bal
set [Du-Display] = Du
from ##vwAgingAllInfo bal
join (select [AgingKey-RPPSM]
	  from ##vwAgingAllInfo
	  where [Du-Display] is null and isnull(BreakByDu,0) = 0
	  group by [AgingKey-RPPSM]
	  having min(Du) = max(Du)) onlyOneDuForRPPSM on bal.[AgingKey-RPPSM] = onlyOneDuForRPPSM.[AgingKey-RPPSM]

update bal
set [Du-Display] = Du
from ##vwAgingAllInfo bal
where isnull(BreakByDu,0) = 1 

CREATE TABLE [dbo].[tblAging.Bal_New](
	[Id] [int] NULL,	
	[AgingKey-RPPS] [varchar](500) NULL,
	[AgingKey-RPPSD] [varchar](500) NULL,
	[AgingKey-RPPSDM] [varchar](500) NULL,
	[AgingKey-RPPSM] [varchar](500) NULL,
	[FacId] [int] NULL,
	[Fac] [varchar](500) NULL,
	[ResId] [int] NOT NULL,
	[Res] [varchar](500) NULL,
	[BillingMonth] [date] NOT NULL,
	[PayorGroupId] [int] NULL,
	[PayorGroup] [varchar](500) NULL,
	[PayorId] [int] NULL,
	[Payor] [varchar](500) NULL,
	[ServiceTypeId] [int] NULL,
	[ServiceType] [varchar](500) NULL,
	[PayTypeId] [int] NULL,
	[PayType] [varchar](500) NULL,
	[FacDuId] [int] NULL,
	[Du] [varchar](5000) NULL,
	[Balance-RPPSDM] [money] NULL,
	[Balance-RPPSM] [money] NULL,
	[Balance] [money] NOT NULL,
	[SubTotal] [money] NULL,
	[Identifier] [varchar](500) NULL,
	[UniqueIdentifier] [varchar](500) NULL,
	[TrackingIdentifier] [varchar](500) NULL,
	[MedicareNum]		[varchar](50)  NULL,	
	[MedicaidNum]		[varchar](50) NULL,
	[IsPending]		    [bit] Default(0) NOT NULL,
	[Ssn]				[varchar](9) NULL,
	[Dob]				[date] NULL,
	[Gender]			[varchar](50)  NULL,
	[StayStatus]		[varchar](50)  NULL,
	[InLegal]		    [bit] Default(0) NOT NULL,
	[CreatedOn]			[datetime] NULL,
	[Deleted]			[bit] NULL,
	[LastModifiedOn]	[datetime] NULL,
	[SyncRowGenOn] [datetime] NULL,
	[SyncLastMod] [datetime] NULL,
	[SyncIsReady] [bit] NULL,
	[TrackingCaseUserSelection] [bit] NULL,
	[SystemNo] [int] NULL,
	[BreakByDu] [bit] NULL,
	[Du-Min] [varchar](50) NULL,
	[Du-Display] [varchar](50) NULL)

---bring new local bal up to date
--truncate table [tblAging.Bal]
insert [tblAging.Bal_New]
(
UniqueIdentifier, TrackingIdentifier, FacId, Fac, ResId, Res, PayorGroupId, PayorGroup, PayorId , Payor, PayTypeId, PayType, ServiceTypeId, ServiceType, BillingMonth
, Balance, [AgingKey-RPPS], [AgingKey-RPPSD], [AgingKey-RPPSDM], [Balance-RPPSDM], [AgingKey-RPPSM], [Balance-RPPSM], MedicareNum, MedicaidNum, IsPending, Ssn, Dob, SystemNo, Gender,StayStatus, InLegal, BreakByDu, Du, FacDuId, [Du-Min], [Du-Display]
)
select ins.UniqueIdentifier, ins.TrackingIdentifier, ins.FacId, ins.Fac, ins.ResId, ins.Res, ins.PayorGroupId, ins.PayorGroup, ins.PayorId, ins.Payor
, ins.PayTypeId, ins.PayType, ins.ServiceTypeId, ins.ServiceType, ins.BillingMonth
, ins.Balance, ins.[AgingKey-RPPS], ins.[AgingKey-RPPSD], ins.[AgingKey-RPPSDM], ins.[Balance-RPPSDM], ins.[AgingKey-RPPSM], ins.[Balance-RPPSM] ,ins.MedicareNum, ins.MedicaidNum, ins.IsPending, ins.Ssn, ins.Dob, ins.SystemNo, ins.Gender
, ins.StayStatus, ins.InLegal, ins.BreakByDu, ins.Du, ins.FacDuId, ins.[Du-Min], ins.[Du-Display]
from ##vwAgingAllInfo ins

select bal.*
into [#_tblAging.Bal_Old]
from ArTrackServer.xTrack.dbo.[tblAging.Bal] bal

select bal.*
into [tblAging.Bal_Old]
from [#_tblAging.Bal_Old] bal
join #_tblPhysicalEntity pe on bal.FacId = pe.Id

--new plan: right here calc the inserts and run the inserts (of just bal info) in the live table
--than calc all the updates (bal info and notes info) in one shot and then update on the server only if eariler timestamp
select newBals.*
into ##newBal_insertJustBals
from [tblAging.Bal_New] newBals
left join [tblAging.Bal_Old] oldBals on newBals.UniqueIdentifier = oldBals.UniqueIdentifier collate SQL_Latin1_General_CP1_CI_AS
where oldBals.UniqueIdentifier is null

--select *
--from [##aging.bill_delete] del
--left join ArTrackServer.xTrack.dbo.[tblAging.Bill] bill on del.Id = bill.Id 
--where bill.Id is null

print 'about to update the server!!!'
--0:53
exec ArTrackServer.master.dbo.sp_executeSql
N'

select * 
into [#aging.bill_insert]
FROM OPENQUERY(ArTrackSyncServer,''select * from [##aging.bill_insert]'')

select * 
into [#aging.cr_insert]
FROM OPENQUERY(ArTrackSyncServer,''select * from [##aging.cr_insert]'')

select * 
into [#aging.bill_delete]
FROM OPENQUERY(ArTrackSyncServer,''select * from [##aging.bill_delete]'')

select * 
into [#aging.cr_delete]
FROM OPENQUERY(ArTrackSyncServer,''select * from [##aging.cr_delete]'')

select * 
into [#aging.bill_update]
FROM OPENQUERY(ArTrackSyncServer,''select * from [##aging.bill_update]'')

select * 
into [#aging.cr_update]
FROM OPENQUERY(ArTrackSyncServer,''select * from [##aging.cr_update]'')

select * 
into #newBal_insertJustBals
FROM OPENQUERY(ArTrackSyncServer,''select * from ##newBal_insertJustBals'')

insert xTrack.dbo.[tblAging.Bill]
	(DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, Identifier, UniqueIdentifier, AllInclusive, Writeoff, FacDuId)
	select DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, Identifier, UniqueIdentifier, AllInclusive, Writeoff, FacDuId
from [#aging.bill_insert]

insert xTrack.dbo.[tblAging.Cr]
	(DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, FacDuId, CrTypeId, Identifier, UniqueIdentifier)
	select DsId, ResId, StartDate, EndDate, BillingMonth, TransactionDate, PayorId, ServiceTypeId, PayTypeId, TherapyType, Balance, FacDuId, CrTypeId, Identifier, UniqueIdentifier
from [#aging.cr_insert]

delete from bill
from xTrack.dbo.[tblAging.Bill] bill
join [#aging.bill_delete] bill_del on bill.DsId = bill_del.DsId

delete from cr
from xTrack.dbo.[tblAging.Cr] cr
join [#aging.cr_delete] cr_del on cr.DsId = cr_del.DsId

update bill
set
  bill.ResId = billUpdate.ResId
, bill.Balance = billUpdate.Balance
, bill.ServiceTypeId = billUpdate.ServiceTypeId
, bill.PayTypeId = billUpdate.PayTypeId
, bill.TherapyType = billUpdate.TherapyType
, bill.StartDate = billUpdate.StartDate
, bill.EndDate = billUpdate.EndDate
, bill.BillingMonth = billUpdate.BillingMonth
, bill.TransactionDate = billUpdate.TransactionDate
, bill.PayorId = billUpdate.PayorId
, bill.UniqueIdentifier = billUpdate.UniqueIdentifier
, bill.AllInclusive = billUpdate.AllInclusive
, bill.Writeoff = billUpdate.Writeoff
, bill.FacDuId = billUpdate.FacDuId
from  xTrack.dbo.[tblAging.Bill] bill
join [#aging.bill_update] billUpdate on bill.DsId = billUpdate.DsId

update bill
set   
  bill.ResId = billUpdate.ResId
, bill.Balance = billUpdate.Balance
, bill.ServiceTypeId = billUpdate.ServiceTypeId
, bill.PayTypeId = billUpdate.PayTypeId
, bill.TherapyType = billUpdate.TherapyType
, bill.StartDate = billUpdate.StartDate
, bill.EndDate = billUpdate.EndDate
, bill.BillingMonth = billUpdate.BillingMonth
, bill.TransactionDate = billUpdate.TransactionDate
, bill.PayorId = billUpdate.PayorId
, bill.FacDuId = billUpdate.FacDuId
, bill.CrTypeId= billUpdate.CrTypeId
, bill.UniqueIdentifier = billUpdate.UniqueIdentifier
from  xTrack.dbo.[tblAging.Cr] bill
join [#aging.cr_update] billUpdate on bill.DsId = billUpdate.DsId

delete from xTrack.dbo.[tblAging.Bill]
where AllInclusive = 1 or Writeoff = 1

insert xTrack.dbo.[tblAging.Bal]
(
  FacId, Fac, ResId, Res, PayorGroupId, PayorGroup, PayorId, Payor, PayTypeId, PayType, ServiceTypeId, ServiceType, Balance, BillingMonth
, UniqueIdentifier, [AgingKey-RPPS], [AgingKey-RPPSD], [AgingKey-RPPSDM], [Balance-RPPSDM], [AgingKey-RPPSM], [Balance-RPPSM], TrackingIdentifier, CreatedOn
, MedicareNum, MedicaidNum, IsPending, Ssn, Dob, SystemNo, Gender,StayStatus, InLegal, BreakByDu, FacDuId, Du, [Du-Min], [Du-Display]
)
select ins.FacId, ins.Fac, ins.ResId, ins.Res, ins.PayorGroupId, ins.PayorGroup, ins.PayorId, ins.Payor, ins.PayTypeId, ins.PayType,ins.ServiceTypeId, ins.ServiceType, ins.Balance,ins.BillingMonth
, ins.UniqueIdentifier, ins.[AgingKey-RPPS], ins.[AgingKey-RPPSD], ins.[AgingKey-RPPSDM], ins.[Balance-RPPSDM], ins.[AgingKey-RPPSM], ins.[Balance-RPPSM], ins.TrackingIdentifier, GETDATE()
, ins.MedicareNum, ins.MedicaidNum, ins.IsPending, ins.Ssn, ins.Dob, ins.SystemNo, ins.Gender, ins.StayStatus, ins.InLegal, ins.BreakByDu, ins.FacDuId, ins.Du, ins.[Du-Min], ins.[Du-Display]
from #newBal_insertJustBals ins
'

print 'preparing to update aging & tracking cases!!!'

print 'you can start testing cases from this point'

IF OBJECT_ID('tempdb..[##newBal_delete]') IS NOT NULL
begin
print 'dropping [##newBal_delete]'
DROP TABLE [##newBal_delete]
end

IF OBJECT_ID('tempdb..[##newBal_update]') IS NOT NULL
begin
print 'dropping [##newBal_update]'
DROP TABLE [##newBal_update]
end

IF OBJECT_ID('tempdb..[##tblAgingSubTotal]') IS NOT NULL
begin
print 'dropping [##tblAgingSubTotal]'
DROP TABLE [##tblAgingSubTotal]
end

IF OBJECT_ID('tempdb..#_tblNameValueAssoc') IS NOT NULL
begin
print 'dropping #_tblNameValueAssoc'
DROP TABLE #_tblNameValueAssoc
end

IF OBJECT_ID('tempdb..##tracking_balCase') IS NOT NULL
begin
print 'dropping ##tracking_balCase'
DROP TABLE ##tracking_balCase
end

IF OBJECT_ID('tempdb..##vwAgingCases') IS NOT NULL
begin
print 'dropping ##vwAgingCases'
DROP TABLE ##vwAgingCases
end

IF OBJECT_ID('tempdb..##vwBalsAgingNotes') IS NOT NULL
begin
print 'dropping ##vwBalsAgingNotes'
DROP TABLE ##vwBalsAgingNotes
end

IF OBJECT_ID('tempdb..##aging_balCase_insert') IS NOT NULL
begin
print 'dropping ##aging_balCase_insert'
DROP TABLE ##aging_balCase_insert
end

IF OBJECT_ID('tempdb..##vwTrackingCases') IS NOT NULL
begin
print 'dropping ##vwTrackingCases'
DROP TABLE ##vwTrackingCases
end

IF OBJECT_ID('tempdb..##vwBalWithCases') IS NOT NULL
begin
print 'dropping ##vwBalWithCases'
DROP TABLE ##vwBalWithCases
end

IF OBJECT_ID('tempdb..##multipleRelatedTrackingCases') IS NOT NULL
begin
print 'dropping ##multipleRelatedTrackingCases'
DROP TABLE ##multipleRelatedTrackingCases
end

IF OBJECT_ID('tempdb..##trackingCase_insert') IS NOT NULL
begin
print 'dropping ##trackingCase_insert'
DROP TABLE ##trackingCase_insert
end

IF OBJECT_ID('tempdb..##balContext_delete') IS NOT NULL
begin
print 'dropping ##balContext_delete'
DROP TABLE ##balContext_delete
end

IF OBJECT_ID('tempdb..##updatedBalCase') IS NOT NULL
begin
print 'dropping ##updatedBalCase'
DROP TABLE ##updatedBalCase
end

IF OBJECT_ID('tempdb..##trackingCasesOrdinal') IS NOT NULL
begin
print 'dropping ##trackingCasesOrdinal'
DROP TABLE ##trackingCasesOrdinal
end

IF OBJECT_ID('tempdb..##newBal_facUpdate') IS NOT NULL
begin
print 'dropping ##newBal_facUpdate'
DROP TABLE ##newBal_facUpdate
end

select *
into #_tblNameValueAssoc 
from ArTrackServer.xTrack.dbo.tblNameValueAssoc

--drop table ##newBal_delete
select oldBals.UniqueIdentifier
into ##newBal_delete
from [tblAging.Bal_New] newBals
right join [tblAging.Bal_Old] oldBals on newBals.UniqueIdentifier = oldBals.UniqueIdentifier collate SQL_Latin1_General_CP1_CI_AS
where newBals.UniqueIdentifier is null

select newBals.*
into ##newBal_facUpdate
from [tblAging.Bal_New] newBals
join [tblAging.Bal_Old] oldBals on newBals.UniqueIdentifier = oldBals.UniqueIdentifier collate SQL_Latin1_General_CP1_CI_AS and newBals.FacId = oldBals.FacId
where 1=1
and oldBals.Fac <> newBals.Fac  collate SQL_Latin1_General_CP1_CI_AS 

print 'created ##newBal_delete:' + convert(varchar(50), @@rowcount)
--drop table ##newBal_update
select newBals.*
into ##newBal_update
from [tblAging.Bal_New] newBals
join [tblAging.Bal_Old] oldBals on newBals.UniqueIdentifier = oldBals.UniqueIdentifier collate SQL_Latin1_General_CP1_CI_AS
where 1=1
and (oldBals.Balance <> newBals.Balance
or isnull(oldBals.[Balance-RPPSM],0) <> isnull(newBals.[Balance-RPPSM],0)
or isnull(oldBals.[Balance-RPPSDM],0) <> isnull(newBals.[Balance-RPPSDM],0)
or oldBals.Res <> newBals.Res  collate SQL_Latin1_General_CP1_CI_AS
or oldBals.PayorGroup <> newBals.PayorGroup  collate SQL_Latin1_General_CP1_CI_AS
or oldBals.Payor <> newBals.Payor  collate SQL_Latin1_General_CP1_CI_AS
or oldBals.PayorGroupId <> newBals.PayorGroupId
or oldBals.TrackingIdentifier <> newBals.TrackingIdentifier collate SQL_Latin1_General_CP1_CI_AS
or oldBals.MedicareNum <> newBals.MedicareNum collate Latin1_General_CS_AS
or oldBals.MedicaidNum <> newBals.MedicaidNum collate Latin1_General_CS_AS
or oldBals.IsPending <> newBals.IsPending 
or isnull(oldBals.StayStatus,'') <> isnull(newBals.StayStatus,'') collate Latin1_General_CS_AS
or oldBals.InLegal <> newBals.InLegal 
or oldBals.Dob <> newBals.Dob
or isnull(oldBals.SystemNo,0) <> isnull(newBals.SystemNo,0)
or oldBals.Gender <> newBals.Gender collate Latin1_General_CS_AS
or oldBals.Ssn <> newBals.Ssn collate Latin1_General_CS_AS
or isnull(oldBals.BreakByDu,0) <> isnull(newBals.BreakByDu,0)
or isnull(oldBals.FacDuId,0) <> isnull(newBals.FacDuId,0)
or isnull(oldBals.Du,'') collate SQL_Latin1_General_CP1_CI_AS <> isnull(newBals.Du,'')
or isnull(oldBals.[Du-Min],'') <> isnull(newBals.[Du-Min],'') collate SQL_Latin1_General_CP1_CI_AS
or isnull(oldBals.[Du-Display],'') <> isnull(newBals.[Du-Display],'') collate SQL_Latin1_General_CP1_CI_AS
) 


--ALTER TABLE ArTrackServer.xTrack.dbo.[tblAging.BalCase]
--ALTER COLUMN AgingKey Varchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS

--attaching aging cases to balance by adding balCaseDetailId to AgingKey
select n.Id NoteId, c.ResId, c.StartDate, c.EndDate, c.PayTypeId, c.ServiceTypeId, payor.Id PayorId, payor.Name PayorName
into ##vwAgingCases
from ArTrackServer.xTrack.dbo.tblNote n
join ArTrackServer.xTrack.dbo.tblCase c on c.Id = n.CaseId
join #_tblPayor payor on c.PayorId = payor.Id
where c.CaseTypeId = 1174

select bal.UniqueIdentifier, max(c.NoteId) NoteId
into ##vwBalsAgingNotes
from [tblAging.Bal_New] bal
join (select Max(NoteId)NoteId, ResId, PayorId, StartDate, EndDate, PayTypeId, ServiceTypeId
		from ##vwAgingCases
		group by ResId, PayorId, StartDate, EndDate, PayTypeId, ServiceTypeId) c on 
			bal.ResId = c.ResId and bal.PayorGroupId = c.PayorId 
			and DATEADD(DAY, -DATEPART(DAY, c.StartDate) + 1, c.StartDate) <= bal.BillingMonth 
			and (c.PayTypeId = bal.PayTypeId or c.PayTypeId is null) and (c.ServiceTypeId = bal.ServiceTypeId or (c.ServiceTypeId is null))
			and EOMONTH(isnull(c.EndDate, dateadd(YEAR, 1, bal.BillingMonth)),0) > bal.BillingMonth 
group by bal.UniqueIdentifier

select distinct UniqueIdentifier, balCaseDtl.Id BalCaseDetailId, 'AgingCase' CaseType
into ##aging_balCase_insert
from ##vwBalsAgingNotes v
join ArTrackServer.xTrack.dbo.tblNote n on v.NoteId = n.Id
join ArTrackServer.xTrack.dbo.[tblAging.BalCaseDetail] balCaseDtl on n.CaseId = balCaseDtl.CaseId
left join ArTrackServer.xTrack.dbo.[tblAging.BalCase] oldBalCase on v.UniqueIdentifier collate Latin1_General_CS_AS = oldBalCase.AgingKey and oldBalCase.CaseType = 'AgingCase'
where oldBalCase.AgingKey is null

ALTER TABLE ##aging_balCase_insert
ALTER COLUMN UniqueIdentifier VARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS 
--all open tracking cases and their max noteid
select c.Id CaseId, c.ResId, caseType.Name CaseType, c.StartDate, c.EndDate, c.DistinctUnitId
, caseStatus.Name Status
, assoc.PayorId
, p.FriendlyName PayorName
, assoc.Ordinal
into ##vwTrackingCases
from ArTrackServer.xTrack.dbo.tblCase c
join #_tblNameValue caseType on c.CaseTypeId = caseType.Id
join #_tblNameValue caseStatus on c.StatusId = caseStatus.Id
join #_tblNameValue caseTitle on c.ScenarioId = caseTitle.Id
join #_tblNameValueAssoc assoc on c.ScenarioId = assoc.NameValueId
join #_tblPayor p on assoc.PayorId = p.Id
left join (select max(Id) NoteId, CaseId from ArTrackServer.xTrack.dbo.tblNote group by CaseId) as n on n.CaseId = c.Id
where assoc.PayorId is not null
	and assoc.AssociationAccessId = 1234
	and assoc.AssociationTypeId = 1209
and c.CaseTypeId = 1173
and c.StatusId=1123

select distinct v.*, c.CaseId, balCaseDetail.Id BalCaseDetailId, c.CaseType, c.StartDate, c.EndDate, c.DistinctUnitId
into ##vwBalWithCases
from [tblAging.Bal_New] v
join (select ResId, PayorId, CaseType, StartDate, EndDate, CaseId, DistinctUnitId
      from ##vwTrackingCases c
	  group by ResId, PayorId, CaseType, StartDate, EndDate, CaseId, DistinctUnitId) c on   
                     v.ResId = c.ResId and v.PayorGroupId = c.PayorId   
                     and v.FacDuId = isnull(c.DistinctUnitId, v.FacDuId)
                     and DATEADD(DAY, -DATEPART(DAY, c.StartDate) + 1, c.StartDate) <= v.BillingMonth   
                     and EOMONTH(isnull(c.EndDate, dateadd(YEAR, 1, v.BillingMonth)),0) > v.BillingMonth   
join ArTrackServer.xTrack.dbo.[tblAging.BalCaseDetail] balCaseDetail on c.CaseId = balCaseDetail.CaseId

---preparing tracking bal case insert
select ins.UniqueIdentifier AgingKey, ins.BalCaseDetailId, ins.CaseType, null Ordinal, null Selected
into ##tracking_balCase
from ##vwBalWithCases ins
left join ArTrackServer.xTrack.dbo.[tblAging.BalCase] balCase on ins.UniqueIdentifier collate Latin1_General_CS_AS = balCase.AgingKey and ins.BalCaseDetailId = balCase.BalCaseDetailId
where balCase.Id is null

--getting multiple related tracking cases for a balance
select AgingKey
into ##multipleRelatedTrackingCases
from ##tracking_balCase b
group by AgingKey
having count(*) > 1

--preparing ordinals for multiple related tracking cases
select tc.AgingKey, tc.BalCaseDetailId, ROW_NUMBER() OVER(partition by tc.AgingKey order by cd.NoteId desc, bwc.Ordinal, cd.CaseId desc) Ordinal
into ##trackingCasesOrdinal
from ##tracking_balCase tc
join ArTrackServer.xTrack.dbo.[tblAging.BalCaseDetail] cd on tc.BalCaseDetailId = cd.Id
join ##vwBalWithCases balWithCase on tc.AgingKey collate Latin1_General_CS_AS = balWithCase.UniqueIdentifier and cd.CaseId = balWithCase.CaseId
join ##vwTrackingCases bwc on balWithCase.CaseId = bwc.CaseId and balWithCase.PayorGroupId = bwc.PayorId
join ##multipleRelatedTrackingCases mrtc on tc.AgingKey  collate Latin1_General_CS_AS = mrtc.AgingKey

--updating ordinals in local table
update tc
set Ordinal = ord.Ordinal
from ##tracking_balCase tc
join ##trackingCasesOrdinal ord on tc.AgingKey collate Latin1_General_CS_AS= ord.AgingKey and tc.BalCaseDetailId = ord.BalCaseDetailId

--preparing query to mark all cases that are part of a group and selected is null, to false
update tc
set Selected = 0
from ##tracking_balCase tc
join ##multipleRelatedTrackingCases mrtc on tc.AgingKey collate Latin1_General_CS_AS = mrtc.AgingKey
where tc.Ordinal > 1

--preparing query to mark all cases that are part of a group and they're first in the list (ordinal is 1), they should be selected by default
update tc
set Selected = 1
from ##tracking_balCase tc
join ##multipleRelatedTrackingCases mrtc on tc.AgingKey collate Latin1_General_CS_AS = mrtc.AgingKey
where tc.Ordinal = 1

--preparing query for inserting tracking cases into bal case
select newBalCase.*
into ##trackingCase_insert
from ##tracking_balCase newBalCase
left join ArTrackServer.xTrack.dbo.[tblAging.BalCase] oldBalCase on newBalCase.AgingKey collate Latin1_General_CS_AS = oldBalCase.AgingKey and oldBalCase.CaseType = 'TrackingCase'
where oldBalCase.AgingKey is null

print 'about to update aging, tracking & multiple related tracking cases!!'

exec ArTrackServer.master.dbo.sp_executeSql
N'

select * 
into #newBal_delete
FROM OPENQUERY(ArTrackSyncServer,''select * from ##newBal_delete'')

select * 
into #newBal_update
FROM OPENQUERY(ArTrackSyncServer,''select * from ##newBal_update'')

select * 
into #newBal_facUpdate
FROM OPENQUERY(ArTrackSyncServer,''select * from ##newBal_facUpdate'')

select * 
into #aging_balCase_insert
FROM OPENQUERY(ArTrackSyncServer,''select * from ##aging_balCase_insert'')

select * 
into #trackingCase_insert
FROM OPENQUERY(ArTrackSyncServer,''select * from ##trackingCase_insert'')

update bal
set
 bal.Res = updt.Res collate SQL_Latin1_General_CP1_CI_AS
,bal.Balance = updt.Balance
,bal.[Balance-RPPSDM] = updt.[Balance-RPPSDM]
,bal.[Balance-RPPSM] = updt.[Balance-RPPSM]
,bal.MedicareNum = updt.MedicareNum  collate SQL_Latin1_General_CP1_CI_AS
,bal.MedicaidNum = updt.MedicaidNum  collate SQL_Latin1_General_CP1_CI_AS
,bal.IsPending = updt.IsPending  
,bal.Ssn = updt.Ssn  collate SQL_Latin1_General_CP1_CI_AS
,bal.Dob = updt.Dob
,bal.SystemNo = updt.SystemNo
,bal.Gender = updt.Gender  collate SQL_Latin1_General_CP1_CI_AS
,bal.StayStatus = updt.StayStatus  collate SQL_Latin1_General_CP1_CI_AS
,bal.InLegal = updt.InLegal  
,bal.Payor = updt.Payor collate SQL_Latin1_General_CP1_CI_AS
,bal.PayorGroup = updt.PayorGroup collate SQL_Latin1_General_CP1_CI_AS
,bal.PayorGroupId = updt.PayorGroupId
,bal.TrackingIdentifier = updt.TrackingIdentifier collate SQL_Latin1_General_CP1_CI_AS
,bal.BreakByDu = updt.BreakByDu
,bal.Du = updt.Du collate SQL_Latin1_General_CP1_CI_AS
,bal.FacDuId = updt.FacDuId
,bal.[Du-Min] = updt.[Du-Min] collate SQL_Latin1_General_CP1_CI_AS
,bal.[Du-Display] = updt.[Du-Display] collate SQL_Latin1_General_CP1_CI_AS
from xTrack.dbo.[tblAging.Bal] bal
join #newBal_update updt on bal.UniqueIdentifier = updt.UniqueIdentifier collate SQL_Latin1_General_CP1_CI_AS

update bal
set
 bal.Fac = updt.Fac collate SQL_Latin1_General_CP1_CI_AS
 from xTrack.dbo.[tblAging.Bal] bal
join #newBal_facUpdate updt on bal.UniqueIdentifier = updt.UniqueIdentifier collate SQL_Latin1_General_CP1_CI_AS and bal.FacId = updt.FacId

delete from xTrack.dbo.[tblAging.Bal]
where Balance = 0

delete from xTrack.dbo.[tblAging.Bal]
where UniqueIdentifier in( select UniqueIdentifier collate Latin1_General_CS_AS from #newBal_delete )

delete balCase
from xTrack.dbo.[tblAging.BalCase] balCase
left join xTrack.dbo.[tblAging.Bal] bal on balCase.AgingKey = bal.UniqueIdentifier 
where bal.UniqueIdentifier is null

insert xTrack.dbo.[tblAging.BalCase](AgingKey, BalCaseDetailId, CaseType)
select ins.UniqueIdentifier, ins.BalCaseDetailId, ins.CaseType
from #aging_balCase_insert ins
left join xTrack.dbo.[tblAging.BalCase] balCase on ins.UniqueIdentifier  collate Latin1_General_CS_AS = balCase.AgingKey and balCase.CaseType = ''AgingCase''
where balCase.AgingKey is null

insert  into xTrack.dbo.[tblAging.BalCase](AgingKey, CaseType, BalCaseDetailId, Ordinal, Selected)
select ins.AgingKey, ''TrackingCase'', ins.BalCaseDetailId, ins.Ordinal, ins.Selected
from #trackingCase_insert ins
left join xTrack.dbo.[tblAging.BalCase] balCase on ins.AgingKey collate Latin1_General_CS_AS = balCase.AgingKey and balCase.CaseType = ''TrackingCase''
where balCase.AgingKey is null

update balCase
set BalId = bal.Id
from xTrack.dbo.[tblAging.BalCase] balCase
join xTrack.dbo.[tblAging.Bal] bal on balCase.AgingKey = bal.UniqueIdentifier

'

print 'updated the server with aging, tracking & multiple related tracking cases!!!'
print 'you can stop testing cases'

IF OBJECT_ID('tempdb..[##tblAging.BalContext_raw]') IS NOT NULL
begin
print 'dropping [##tblAging.BalContext_raw]'
DROP TABLE [##tblAging.BalContext_raw]
end

IF OBJECT_ID('tempdb..[##tblAging.BalContext]') IS NOT NULL
begin
print 'dropping [##tblAging.BalContext]'
DROP TABLE [##tblAging.BalContext]
end

IF OBJECT_ID('tempdb..[##tblAging.BalForContext_raw]') IS NOT NULL
begin
print 'dropping [##tblAging.BalForContext_raw]'
DROP TABLE [##tblAging.BalForContext_raw]
end

IF OBJECT_ID('tempdb..[##tblAging.BalForContext]') IS NOT NULL
begin
print 'dropping [##tblAging.BalForContext]'
DROP TABLE [##tblAging.BalForContext]
end

select *
into [##tblAging.BalForContext_raw]
from ArTrackServer.xTrack.dbo.[tblAging.Bal] bal

select bal.*
into [##tblAging.BalForContext]
from [##tblAging.BalForContext_raw] bal
join #_tblPhysicalEntity pe on bal.FacId = pe.Id

select balContext.*
into [##tblAging.BalContext_raw]
from ArTrackServer.xTrack.dbo.[tblAging.BalContext] balContext

select balContext.*
into [##tblAging.BalContext]
from [##tblAging.BalContext_raw] balContext
join [##tblAging.BalForContext] bal on balContext.BalId = bal.Id

select newBals.Id
into ##balContext_delete
from [##tblAging.BalForContext] newBals
join [##tblAging.BalContext] balContext on newBals.Id = balContext.BalId
and (((newBals.Balance - isnull(balContext.Balance, newBals.Balance) > 500) or ((newBals.Balance - isnull(balContext.Balance, newBals.Balance)) < -500)))
where 1=1
and balContext.FollowUpDate is not null

print 'applying bal context assignment 500 rule'

exec ArTrackServer.master.dbo.sp_executeSql
N'

select * 
into #balContext_delete
FROM OPENQUERY(ArTrackSyncServer,''select * from ##balContext_delete'')

update balContext
set 
  FollowUpDate = null
, AssignedToId = null
, Comment = null
--, InternalComments = ''this assignment was wiped out by the 500 rule''
--, InternalOldBal = balContext.Balance
from xTrack.dbo.[tblAging.BalContext] balContext
join #balContext_delete context_delete on balContext.BalId = context_delete.Id

'

select TrackingIdentifier, sum([Balance-RPPSDM]) subtotal
into ##tblAgingSubTotal
from [tblAging.Bal_New]
group by TrackingIdentifier

print 'created ##tblAgingSubTotal table: ' + convert(varchar(50), @@rowcount)

print 'updating sub totals in live db'

exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #tblAgingSubTotal
FROM OPENQUERY(ArTrackSyncServer,''select * from ##tblAgingSubTotal'')

update bal
set subTotal = subtotal.subtotal
from xTrack.dbo.[tblAging.Bal] bal
join #tblAgingSubTotal subtotal on bal.TrackingIdentifier = subtotal.TrackingIdentifier collate SQL_Latin1_General_CP1_CI_AS

update xTrack.dbo.[tblAging.Bal]
set SyncIsReady =1
'
print 'updated sub totals in live db'

IF OBJECT_ID('tempdb..[##vwTrackingCases_ForSubTotals]') IS NOT NULL
begin
print 'dropping [##vwTrackingCases_ForSubTotals]'
DROP TABLE [##vwTrackingCases_ForSubTotals]
end

IF OBJECT_ID('tempdb..[#_vwCaseAgingBal_step1]') IS NOT NULL
begin
print 'dropping [#_vwCaseAgingBal_step1]'
DROP TABLE [#_vwCaseAgingBal_step1]
end

IF OBJECT_ID('tempdb..[#_vwCaseAgingBal]') IS NOT NULL
begin
print 'dropping [#_vwCaseAgingBal]'
DROP TABLE [#_vwCaseAgingBal]
end

IF OBJECT_ID('tempdb..[##_caseBal_update]') IS NOT NULL
begin
print 'dropping [##_caseBal_update]'
DROP TABLE [##_caseBal_update]
end

select c.Id CaseId, assoc.PayorId, c.ResId
into ##vwTrackingCases_ForSubTotals
from ArTrackServer.xTrack.dbo.tblCase c
join ArTrackServer.xTrack.dbo.tblNameValueAssoc assoc on c.ScenarioId = assoc.NameValueId
join #_tblResident res on c.ResId = res.Id
where assoc.PayorId is not null
	and assoc.AssociationAccessId = 1234
	and assoc.AssociationTypeId = 1209
and c.CaseTypeId = 1173

select c.CaseId, sum(bal.Balance) Balance
into #_vwCaseAgingBal_step1
from ##vwTrackingCases_ForSubTotals c
left join (select sum([Balance-RPPSDM]) Balance, PayorGroupId, ResId 
			from [tblAging.Bal_New] 
			group by ResId, PayorGroupId) as bal 
on (bal.PayorGroupId = c.PayorId and bal.ResId = c.ResId)
group by c.CaseId

select caseId, ISNULL(Balance, 0) Balance
into #_vwCaseAgingBal
from #_vwCaseAgingBal_step1

select cab.*
into ##_caseBal_update
from ArTrackServer.xTrack.dbo.tblcase c
join #_vwCaseAgingBal cab on c.Id = cab.CaseId
where isnull(c.AgingBalance, 0) <> isnull(cab.Balance,0)

print 'updating case balances in live db'

--0:53
exec ArTrackServer.master.dbo.sp_executeSql
N'
select * 
into #_caseBal_update
FROM OPENQUERY(ArTrackSyncServer,''select * from ##_caseBal_update'')

update c
set agingbalance = cab.balance
from  xTrack.dbo.tblCase c
join #_caseBal_update cab on c.id = cab.caseid

'
print 'updated case balances in live db'

print 'done aging!!'

end
else
print 'this is an not an aging schedule, we are done!!'

print 'ended sArTrackSync script at: ' + convert(varchar(100), cast(getdate() as Datetime2 (3)))
exec ArTrackServer.xTrack.dbo.spManageSyncPipeline 'Dequeue', 'NCS', @OK = @FreeSyncPipeline output

