--============================================
--Starting integration generator
--Total rows: 7
--Print only: 1
--============================================

--------------------------------------------
--Processing row 1 of 7
--Id: 1
--Table: tblPhysicalEntity
--------------------------------------------

IF OBJECT_ID('[source].[tblPhysicalEntity]', 'U') IS NOT NULL
    DROP TABLE [source].[tblPhysicalEntity];

IF OBJECT_ID('[target].[tblPhysicalEntity]', 'U') IS NOT NULL
    DROP TABLE [target].[tblPhysicalEntity];

--Running SourceGenQuery for tblPhysicalEntity
select Id, ShortName Name, Name FriendlyName, ShortName LegacyName, ShortName LogicalName, 3 LevelId, Deleted 
into [source].tblPhysicalEntity
from ##Companies

--Running TargetGenQuery for tblPhysicalEntity
select SyncId Id, pe.Name, pe.FriendlyName, pe.LegacyName, pe.LogicalName, pe.LevelId, ~Active Deleted
into [target].tblPhysicalEntity
from ArTrackServer.xTrack.dbo.tblPhysicalEntity pe
join [source].tblPhysicalEntity spe on spe.Id = pe.SyncId
where pe.LevelId = 3
and StateId = 1097

--Running local GenerateMergeStatement for tblPhysicalEntity
EXEC dbo.GenerateMergeStatement
    @SourceSchema = 'source',
    @SourceTable = 'tblPhysicalEntity',
    @TargetSchema = 'target',
    @TargetTable = 'tblPhysicalEntity',
    @PrimaryKeyColumns = 'Id',
    @SoftDeleteNotMatchedBySource = 1,
    @DeletedColumn = 'Deleted';

--Copying delta to live and running live GenerateMergeStatement for tblPhysicalEntity
IF EXISTS(SELECT 1 FROM [target].[tblPhysicalEntity] WHERE IntegrationAction IS NOT NULL)
BEGIN
    EXEC [ArTrackServer].master.dbo.sp_executesql N'
IF OBJECT_ID(''[xtrack].[source].[tblPhysicalEntity]'', ''U'') IS NOT NULL
    DROP TABLE [xtrack].[source].[tblPhysicalEntity];

select Id SyncId, Name, FriendlyName, LegacyName, LogicalName, LevelId, case when deleted = 0 then 1097 else 1098 end StateId

INTO [xtrack].[source].[tblPhysicalEntity]
FROM [ArTrackSyncServer].[DsReplica].[target].[tblPhysicalEntity] mainTable

WHERE mainTable.IntegrationAction IS NOT NULL;

EXEC [xtrack].dbo.GenerateMergeStatement
    @SourceSchema = ''source'',
    @SourceTable = ''tblPhysicalEntity'',
    @TargetSchema = ''dbo'',
    @TargetTable = ''tblPhysicalEntity'',
    @PrimaryKeyColumns = ''SyncId'',
    @DeltaMode = 1;';
END
ELSE
BEGIN
    PRINT 'No changes for tblPhysicalEntity, skipping merge to live.'
END

--Completed: tblPhysicalEntity

--------------------------------------------
--Processing row 2 of 7
--Id: 2
--Table: tblPayor
--------------------------------------------

IF OBJECT_ID('[source].[tblPayor]', 'U') IS NOT NULL
    DROP TABLE [source].[tblPayor];

IF OBJECT_ID('[target].[tblPayor]', 'U') IS NOT NULL
    DROP TABLE [target].[tblPayor];

--Running SourceGenQuery for tblPayor
select p.Id, p.Code, p.Name, p.Name FriendlyName, pg.Name PayorGroup, p.CompanyId PeId, p.Deleted
into [source].tblPayor
from ##BillableEntities p
join ##BillingGroups pg on pg.Id = p.BillingGroupId


--Running TargetGenQuery for tblPayor
select p.SyncId Id, p.Code, p.Name, p.Name FriendlyName, pg.Name PayorGroup, pe.SyncId PeId, case when p.StateId = 1097 then 0 else 1 end Deleted
into [target].tblPayor
from ArTrackServer.xTrack.dbo.tblPayor p
join ArTrackServer.xTrack.dbo.tblPayor pg on p.ParentId = pg.Id
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on pe.Id = p.PeId
join [target].tblPhysicalEntity peInt on pe.SyncId = peInt.Id


--Running local GenerateMergeStatement for tblPayor
EXEC dbo.GenerateMergeStatement
    @SourceSchema = 'source',
    @SourceTable = 'tblPayor',
    @TargetSchema = 'target',
    @TargetTable = 'tblPayor',
    @PrimaryKeyColumns = 'Id',
    @SoftDeleteNotMatchedBySource = 1,
    @DeletedColumn = 'Deleted';

--Copying delta to live and running live GenerateMergeStatement for tblPayor
IF EXISTS(SELECT 1 FROM [target].[tblPayor] WHERE IntegrationAction IS NOT NULL)
BEGIN
    EXEC [ArTrackServer].master.dbo.sp_executesql N'
IF OBJECT_ID(''[xtrack].[source].[tblPayor]'', ''U'') IS NOT NULL
    DROP TABLE [xtrack].[source].[tblPayor];

select mainTable.Id SyncId, mainTable.Code, mainTable.Name, mainTable.FriendlyName, pgroup.Id ParentId, pe.Id PeId, case when mainTable.Deleted = 0 then 1097 else 1098 end StateId

INTO [xtrack].[source].[tblPayor]
FROM [ArTrackSyncServer].[DsReplica].[target].[tblPayor] mainTable
join [xTrack].[dbo].[tblPayor] pgroup on (pgroup.Name = mainTable.PayorGroup and pgroup.LevelId in (5,6))
join [xTrack].[dbo].[tblPhysicalEntity] pe on pe.SyncId = mainTable.PeId

WHERE mainTable.IntegrationAction IS NOT NULL;

EXEC [xtrack].dbo.GenerateMergeStatement
    @SourceSchema = ''source'',
    @SourceTable = ''tblPayor'',
    @TargetSchema = ''dbo'',
    @TargetTable = ''tblPayor'',
    @PrimaryKeyColumns = ''SyncId'',
    @DeltaMode = 1;';
END
ELSE
BEGIN
    PRINT 'No changes for tblPayor, skipping merge to live.'
END

--Completed: tblPayor

--------------------------------------------
--Processing row 3 of 7
--Id: 3
--Table: tblPerson
--------------------------------------------

IF OBJECT_ID('[source].[tblPerson]', 'U') IS NOT NULL
    DROP TABLE [source].[tblPerson];

IF OBJECT_ID('[target].[tblPerson]', 'U') IS NOT NULL
    DROP TABLE [target].[tblPerson];

--Running SourceGenQuery for tblPerson
select Id, CompanyId PeId, FirstName First, isnull(MiddleName,'') Middle, LastName Last
, isnull(SocialSecurityNumber, '') Social, Case when Gender = 'Male' then 1 else 0 end Male
, DateOfBirth BDate, DateOfDeath EDate, 12 PersonTypeId, Deleted
into [source].tblPerson
from ##Residents p

--Running TargetGenQuery for tblPerson
select p.SyncId Id, pe.SyncId PeId, First, Middle, Last, Social, Male
, case when BDate = '1899-12-30' then null else BDate end BDate
, case when EDate = '1899-12-30' then null else EDate end EDate
, 12 PersonTypeId, 0 Deleted
into [target].tblPerson
from ArTrackServer.xTrack.dbo.tblPerson p
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on p.PeId = pe.Id
join [target].tblPhysicalEntity peInt on pe.SyncId = peInt.Id
where 1=1
and p.StateId = 1097

--Running local GenerateMergeStatement for tblPerson
EXEC dbo.GenerateMergeStatement
    @SourceSchema = 'source',
    @SourceTable = 'tblPerson',
    @TargetSchema = 'target',
    @TargetTable = 'tblPerson',
    @PrimaryKeyColumns = 'Id',
    @SoftDeleteNotMatchedBySource = 1,
    @DeletedColumn = 'Deleted';

--Copying delta to live and running live GenerateMergeStatement for tblPerson
IF EXISTS(SELECT 1 FROM [target].[tblPerson] WHERE IntegrationAction IS NOT NULL)
BEGIN
    EXEC [ArTrackServer].master.dbo.sp_executesql N'
IF OBJECT_ID(''[xtrack].[source].[tblPerson]'', ''U'') IS NOT NULL
    DROP TABLE [xtrack].[source].[tblPerson];

select mainTable.Id SyncId, pe.Id PeId, mainTable.First, mainTable.Middle, mainTable.Last
, mainTable.Social, mainTable.Male, mainTable.BDate, mainTable.EDate, mainTable.PersonTypeId
, case when mainTable.Deleted = 0 then 1097 else 1098 end StateId
INTO [xtrack].[source].[tblPerson]
FROM [ArTrackSyncServer].[DsReplica].[target].[tblPerson] mainTable
Join [xTrack].[dbo].[tblPhysicalEntity] pe on pe.SyncId = mainTable.PeId

WHERE mainTable.IntegrationAction IS NOT NULL;

EXEC [xtrack].dbo.GenerateMergeStatement
    @SourceSchema = ''source'',
    @SourceTable = ''tblPerson'',
    @TargetSchema = ''dbo'',
    @TargetTable = ''tblPerson'',
    @PrimaryKeyColumns = ''SyncId'',
    @DeltaMode = 1;';
END
ELSE
BEGIN
    PRINT 'No changes for tblPerson, skipping merge to live.'
END

--Completed: tblPerson

--------------------------------------------
--Processing row 4 of 7
--Id: 4
--Table: tblResident
--------------------------------------------

IF OBJECT_ID('[source].[tblResident]', 'U') IS NOT NULL
    DROP TABLE [source].[tblResident];

IF OBJECT_ID('[target].[tblResident]', 'U') IS NOT NULL
    DROP TABLE [target].[tblResident];

--Running SourceGenQuery for tblResident
IF OBJECT_ID('[source].tblResident') IS NOT NULL DROP TABLE [source].tblResident;
IF OBJECT_ID('[target].tblResident') IS NOT NULL DROP TABLE [target].tblResident;
IF OBJECT_ID('tempdb..##MedicareAEligibility') IS NOT NULL DROP TABLE ##MedicareAEligibility;
IF OBJECT_ID('tempdb..##MedicareBEligibility') IS NOT NULL DROP TABLE ##MedicareBEligibility;
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
, cast(null as char(1)) StayStatus
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
		when r.DateOfDeath is not null then 'E' 
		else 
		case when rs.IsDc =1 then 'D' 
		else 'A' 
		end 
	end StayStatus
, rs.Id StayId
into ##ResStayStatus
from ##ResStay rs
join ##MaxDC md on rs.ResidentId = md.ResidentId and rs.DischargeDateCalc = md.maxDc
join ##Residents r on rs.ResidentId = r.Id


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


--Running TargetGenQuery for tblResident
select r.SyncId Id, p.SyncId PersonId, pe.SyncId PeId, SystemNo, InLegal, IsPending, StayStatus, BedNumber, McoNum, McaNum, AStart, AEnd, BStart, BEnd, 0 Deleted
into [target].tblResident
from ArTrackServer.xTrack.dbo.tblResident r
join ArTrackServer.xTrack.dbo.tblPerson p on p.Id = r.PersonId
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on pe.Id = r.PeId
join [target].tblPhysicalEntity peInt on pe.SyncId = peInt.Id
where 1=1
and r.StateId = 1097


--Running local GenerateMergeStatement for tblResident
EXEC dbo.GenerateMergeStatement
    @SourceSchema = 'source',
    @SourceTable = 'tblResident',
    @TargetSchema = 'target',
    @TargetTable = 'tblResident',
    @PrimaryKeyColumns = 'Id',
    @SoftDeleteNotMatchedBySource = 1,
    @DeletedColumn = 'Deleted';

--Copying delta to live and running live GenerateMergeStatement for tblResident
IF EXISTS(SELECT 1 FROM [target].[tblResident] WHERE IntegrationAction IS NOT NULL)
BEGIN
    EXEC [ArTrackServer].master.dbo.sp_executesql N'
IF OBJECT_ID(''[xtrack].[source].[tblResident]'', ''U'') IS NOT NULL
    DROP TABLE [xtrack].[source].[tblResident];

select mainTable.Id SyncId, p.Id PersonId, pe.Id PeId, mainTable.SystemNo, mainTable.InLegal
, mainTable.IsPending, mainTable.StayStatus, mainTable.BedNumber, mainTable.McoNum, mainTable.McaNum
, mainTable.AStart, mainTable.AEnd, BStart, mainTable.BEnd, case when mainTable.deleted = 0 then 1097 else 1098 end StateId
INTO [xtrack].[source].[tblResident]
FROM [ArTrackSyncServer].[DsReplica].[target].[tblResident] mainTable
join [xtrack].[dbo].[tblPerson] p on mainTable.PersonId = p.SyncId
join [xtrack].[dbo].[tblPhysicalEntity] pe on mainTable.PeId = pe.SyncId 
WHERE mainTable.IntegrationAction IS NOT NULL;

EXEC [xtrack].dbo.GenerateMergeStatement
    @SourceSchema = ''source'',
    @SourceTable = ''tblResident'',
    @TargetSchema = ''dbo'',
    @TargetTable = ''tblResident'',
    @PrimaryKeyColumns = ''SyncId'',
    @DeltaMode = 1;';
END
ELSE
BEGIN
    PRINT 'No changes for tblResident, skipping merge to live.'
END

--Completed: tblResident

--------------------------------------------
--Processing row 5 of 7
--Id: 5
--Table: tblStay
--------------------------------------------

IF OBJECT_ID('[source].[tblStay]', 'U') IS NOT NULL
    DROP TABLE [source].[tblStay];

IF OBJECT_ID('[target].[tblStay]', 'U') IS NOT NULL
    DROP TABLE [target].[tblStay];

--Running SourceGenQuery for tblStay
select stay.Id, ResidentId, AdmitDate Admission, DischargeDate Discharge, case when rv.ShortDescription = 'H' then 1 else 0 end IsBh, stay.Deleted
into [source].tblStay
from ##ResidentStays stay
join ##ResourceValues rv on stay.RecordTypeId = rv.Id

--Running TargetGenQuery for tblStay
select s.SyncId Id, r.SyncId ResidentId, Admission, Discharge, isnull(IsBh,0) IsBh, 0 Deleted
into [target].tblStay
from ArTrackServer.xTrack.dbo.tblStay s
join ArTrackServer.xTrack.dbo.tblResident r on r.Id = s.ResId
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on pe.Id = r.PeId
join [target].tblPhysicalEntity peInt on pe.SyncId = peInt.Id


--Running local GenerateMergeStatement for tblStay
EXEC dbo.GenerateMergeStatement
    @SourceSchema = 'source',
    @SourceTable = 'tblStay',
    @TargetSchema = 'target',
    @TargetTable = 'tblStay',
    @PrimaryKeyColumns = 'Id',
    @SoftDeleteNotMatchedBySource = 1,
    @DeletedColumn = 'Deleted';

--Copying delta to live and running live GenerateMergeStatement for tblStay
IF EXISTS(SELECT 1 FROM [target].[tblStay] WHERE IntegrationAction IS NOT NULL)
BEGIN
    EXEC [ArTrackServer].master.dbo.sp_executesql N'
IF OBJECT_ID(''[xtrack].[source].[tblStay]'', ''U'') IS NOT NULL
    DROP TABLE [xtrack].[source].[tblStay];

select mainTable.Id SyncId, r.Id ResId, mainTable.Admission, mainTable.Discharge, mainTable.IsBh, case when mainTable.Deleted = 0 then 1097 else 1098 end StateId

INTO [xtrack].[source].[tblStay]
FROM [ArTrackSyncServer].[DsReplica].[target].[tblStay] mainTable
join [xtrack].[dbo].[tblResident] r on mainTable.ResidentId = r.SyncId
WHERE mainTable.IntegrationAction IS NOT NULL;

EXEC [xtrack].dbo.GenerateMergeStatement
    @SourceSchema = ''source'',
    @SourceTable = ''tblStay'',
    @TargetSchema = ''dbo'',
    @TargetTable = ''tblStay'',
    @PrimaryKeyColumns = ''SyncId'',
    @DeltaMode = 1;';
END
ELSE
BEGIN
    PRINT 'No changes for tblStay, skipping merge to live.'
END

--Completed: tblStay

--------------------------------------------
--Processing row 6 of 7
--Id: 6
--Table: tblStayPayor
--------------------------------------------

IF OBJECT_ID('[source].[tblStayPayor]', 'U') IS NOT NULL
    DROP TABLE [source].[tblStayPayor];

IF OBJECT_ID('[target].[tblStayPayor]', 'U') IS NOT NULL
    DROP TABLE [target].[tblStayPayor];

--Running SourceGenQuery for tblStayPayor
IF OBJECT_ID('tempdb..##StayCoPayor') IS NOT NULL DROP TABLE ##StayCoPayor;
IF OBJECT_ID('tempdb..##BestRateCode') IS NOT NULL DROP TABLE ##BestRateCode;

Select Id, ResidentStayId StayId, StartDate, EndDate, IncidentNumber IncidentNum, ExpendedDays
 , PayorId
 , cast(null as varchar(50)) RateCode
 , cast(null as varchar(50)) RefNum
 , cast(null as varchar(50)) AuthNum 
 , null CoPayorId
 , cast(0.00 as numeric(5,2)) CoPay
 , Deleted
 into [source].tblStayPayor
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
from [source].tblStayPayor sp
join ##StayCoPayor scp on sp.Id = scp.StayPayorId

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
from [source].tblStayPayor sp
join ##BestRateCode scp on sp.Id = scp.StayPayorId

update sp
set RefNum = scp.ReferenceNumber
from [source].tblStayPayor sp
join ##ResidentStays s on sp.StayId = s.Id
join ##ResidentPayorReferenceNumbers scp on (s.ResidentId = scp.ResidentId and sp.PayorId = scp.PayorId)

update sp
set AuthNum = auth.AuthorizationNumber
--select *
from [source].tblStayPayor sp
join ##ResidentPayorAuthorizationNumbers auth on sp.Id = auth.residentpayorid

--Running TargetGenQuery for tblStayPayor
select sp.SyncId Id, s.SyncId StayId, StartDate, EndDate, IncidentNum, ExpendedDays, p.SyncId PayorId, RateCode
, RefNum, AuthNum, cp.SyncId CoPayorId, CoPay, 0 Deleted
into [target].tblStayPayor 
from ArTrackServer.xTrack.dbo.tblStayPayor sp
join ArTrackServer.xTrack.dbo.tblStay s on s.Id = sp.StayId
join ArTrackServer.xTrack.dbo.tblResident r on r.Id = s.ResId
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on pe.Id = r.PeId
join [target].tblPhysicalEntity peInt on pe.SyncId = peInt.Id
left join ArTrackServer.xTrack.dbo.tblPayor p on p.Id = sp.PayorId
left join ArTrackServer.xTrack.dbo.tblPayor cp on cp.Id = sp.CoPayorId

--Running local GenerateMergeStatement for tblStayPayor
EXEC dbo.GenerateMergeStatement
    @SourceSchema = 'source',
    @SourceTable = 'tblStayPayor',
    @TargetSchema = 'target',
    @TargetTable = 'tblStayPayor',
    @PrimaryKeyColumns = 'Id',
    @SoftDeleteNotMatchedBySource = 1,
    @DeletedColumn = 'Deleted';

--Copying delta to live and running live GenerateMergeStatement for tblStayPayor
IF EXISTS(SELECT 1 FROM [target].[tblStayPayor] WHERE IntegrationAction IS NOT NULL)
BEGIN
    EXEC [ArTrackServer].master.dbo.sp_executesql N'
IF OBJECT_ID(''[xtrack].[source].[tblStayPayor]'', ''U'') IS NOT NULL
    DROP TABLE [xtrack].[source].[tblStayPayor];

Select mainTable.Id SyncId, s.Id StayId, mainTable.StartDate, mainTable.EndDate, mainTable.IncidentNum, mainTable.ExpendedDays
 , p.Id PayorId, mainTable.RateCode, mainTable.RefNum, mainTable.AuthNum, cp.Id CoPayorId, mainTable.CoPay
 , case when mainTable.Deleted = 0 then 1097 else 1098 end StateId

INTO [xtrack].[source].[tblStayPayor]
FROM [ArTrackSyncServer].[DsReplica].[target].[tblStayPayor] mainTable
join [xTrack].[dbo].[tblStay] s on s.SyncId = mainTable.StayId
join [xTrack].[dbo].[tblPayor] p on p.SyncId = mainTable.PayorId
left join [xTrack].[dbo].[tblPayor] cp on cp.SyncId = mainTable.CoPayorId
WHERE mainTable.IntegrationAction IS NOT NULL;

EXEC [xtrack].dbo.GenerateMergeStatement
    @SourceSchema = ''source'',
    @SourceTable = ''tblStayPayor'',
    @TargetSchema = ''dbo'',
    @TargetTable = ''tblStayPayor'',
    @PrimaryKeyColumns = ''SyncId'',
    @DeltaMode = 1;';
END
ELSE
BEGIN
    PRINT 'No changes for tblStayPayor, skipping merge to live.'
END

--Completed: tblStayPayor

--------------------------------------------
--Processing row 7 of 7
--Id: 7
--Table: tblNameValue
--------------------------------------------
IF OBJECT_ID('[source].[tblFacDistinctUnit]', 'U') IS NOT NULL
    DROP TABLE [source].[tblFacDistinctUnit];

IF OBJECT_ID('[target].[tblFacDistinctUnit]', 'U') IS NOT NULL
    DROP TABLE [target].[tblFacDistinctUnit];

--Running SourceGenQuery for tblNameValue
select du.Code Name, c.Id PeId, du.Deleted
into [source].[tblFacDistinctUnit]
from ##DistinctUnits du
join ##Companies c on du.CompanyId = c.Id

--Running TargetGenQuery for tblNameValue
select duNV.Name, pe.SyncId PeId
, case when statusNv.Name = 'Deleted' then 1 else 0 end Deleted
into [target].[tblFacDistinctUnit]
from ArTrackServer.xTrack.dbo.tblFacDistinctUnit du
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on pe.Id = du.PeId
join ArTrackServer.xTrack.dbo.tblNameValue duNV on du.DuNvId = duNV.Id
join ArTrackServer.xTrack.dbo.tblNameValue statusNv on du.StateId = statusNv.Id
join [target].tblPhysicalEntity peInt on pe.SyncId = peInt.Id

select *
from [source].[tblFacDistinctUnit]

select *
from [target].[tblFacDistinctUnit]

--Running local GenerateMergeStatement for tblNameValue
EXEC dbo.GenerateMergeStatement
    @SourceSchema = 'source',
    @SourceTable = 'tblFacDistinctUnit',
    @TargetSchema = 'target',
    @TargetTable = 'tblFacDistinctUnit',
    @PrimaryKeyColumns = 'Name',
    @SoftDeleteNotMatchedBySource = 1,
    @DeletedColumn = 'Deleted';

    select *
    from [target].[tblNameValue]

    update t
    set Name = 'SNF_TEST'
    , IntegrationAction = 'C'
    from [target].[tblNameValue] t

--Copying delta to live and running live GenerateMergeStatement for tblNameValue
IF EXISTS(SELECT 1 FROM [target].[tblNameValue] WHERE IntegrationAction IS NOT NULL)
BEGIN
    EXEC [ArTrackServer].master.dbo.sp_executesql N'
IF OBJECT_ID(''[xtrack].[source].[tblFacDistinctUnit'', ''U'') IS NOT NULL
    DROP TABLE [xtrack].[source].[tblFacDistinctUnit];

SELECT pe.Id, duNV.Id DuNvId
INTO [xtrack].[source].[tblFacDistinctUnit]
FROM [ArTrackSyncServer].[DsReplica].[target].[tblFacDistinctUnit] mainTable
join [xtrack].[dbo].[tblPhysicalEntity] pe on mainTable.PeId = pe.SyncId
join xTrack.dbo.tblNameValue duNv on mainTable.Name = duNv.Name
WHERE mainTable.IntegrationAction IS NOT NULL;

EXEC [xtrack].dbo.GenerateMergeStatement
    @SourceSchema = ''source'',
    @SourceTable = ''tblNameValue'',
    @TargetSchema = ''dbo'',
    @TargetTable = ''tblNameValue'',
    @PrimaryKeyColumns = ''Name'',
    @DeltaMode = 1;';
END
ELSE
BEGIN
    PRINT 'No changes for tblNameValue, skipping merge to live.'
END



