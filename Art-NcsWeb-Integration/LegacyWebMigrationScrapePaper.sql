
select *
from tblPhysicalEntity pe
join tblResident r on r.PeId = pe.Id
join tblStay s on s.ResId = r.Id
join tblStayPayor sp on s.Id = sp.StayId
where 1=1
and pe.Id = 42541

select *
from tblPhysicalEntity pe
join tblResident r on pe.id = r.PeId
join tblStay s on s.ResId = r.Id
where pe.id =  42541

select *
from tblPhysicalEntity pe
join tblPerson r on pe.id = r.PeId
where pe.id =  42541


--/*
--prep
select *
from tblPhysicalEntity
where Id = 42541


select *
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].Companies
where Name like '%Omaha%'

select *
from DsReplica_new.dbo.Global_Facilities
where cname like '%Omaha%'
--where nid = 456

select *
from ##Companies
where name like '%Omaha%'

select *
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].Companies
where ShortName like '%Omaha%'

update a
set IsARTrackEnabled = 1
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].Companies a
where Id = 872

--4683
--old count 2354
--new count 2329
select count(*)
from tblResident r
join tblStay s on r.Id = s.ResId
join ##migratingFac pe on r.PeId = pe.Id
where s.SyncId is not null

/*
--get missing stays
--turns out,Yitzy does not migrate BH that the payor does not pay for them
select *
from (
select r.SystemNo, count(distinct s.Id) StayCount, count(sp.Id) StayPayorCount
from tblResident r
join tblStay s on r.Id = s.ResId
join tblStayPayor sp on s.Id = sp.StayId
join tblPerson p on r.PersonId = p.Id
join ##migratingFac pe on r.PeId = pe.Id
where s.SyncId is null 
group by r.SystemNo
) legacy
left join 
(
select r.SystemNo, count(distinct s.Id) StayCount, count(sp.Id) StayPayorCount
from tblResident r
join tblStay s on r.Id = s.ResId
join tblStayPayor sp on s.Id = sp.StayId
join tblPerson p on r.PersonId = p.Id
join ##migratingFac pe on r.PeId = pe.Id
where s.SyncId is not null 
group by r.SystemNo
) web on legacy.SystemNo = web.SystemNo and legacy.StayPayorCount = web.StayPayorCount
where web.StayPayorCount is null

--this query returns 0 rows, it shows that there no missing stay payors, just stays (bh as above)
;with legacy as
(
    select
        r.SystemNo,
        count(distinct s.Id) StayCount,
        count(sp.Id) StayPayorCount
    from tblResident r
    join tblStay s on r.Id = s.ResId
    left join tblStayPayor sp on s.Id = sp.StayId
    join tblPerson p on r.PersonId = p.Id
    join ##migratingFac pe on r.PeId = pe.Id
    where s.SyncId is null
    group by r.SystemNo
),
web as
(
    select
        r.SystemNo,
        count(distinct s.Id) StayCount,
        count(sp.Id) StayPayorCount
    from tblResident r
    join tblStay s on r.Id = s.ResId
    left join tblStayPayor sp on s.Id = sp.StayId
    join tblPerson p on r.PersonId = p.Id
    join ##migratingFac pe on r.PeId = pe.Id
    where s.SyncId is not null
    group by r.SystemNo
)
select
    legacy.SystemNo,
    legacy.StayCount,
    legacy.StayPayorCount LegacyStayPayorCount,
    web.StayPayorCount WebStayPayorCount,
    legacy.StayPayorCount - web.StayPayorCount MissingStayPayors
from legacy
join web on legacy.SystemNo = web.SystemNo
where legacy.StayCount = web.StayCount
  and legacy.StayPayorCount > web.StayPayorCount
order by MissingStayPayors desc, legacy.SystemNo;

*/

--2354
select count(*)
from DsReplica_new.dbo.resstay
where FacId = 456 --test omaha

--2361
select count(*)
from DsReplica_new.dbo.resstay
where FacId = 307 --omaha

--2329
select count(*) c
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].ResidentStays
where companyid = 872   --test omaha



--2329
select *
from ##residents r
join ##residentStays s on r.Id = s.ResidentId
join ##companies c on r.CompanyId = c.Id
join ##migratingFac pe on pe.LegacyName = c.ShortName


--*/

select *
into ##migratingFac
from tblPhysicalEntity pe
where pe.LegacyName in('Test Omaha')

--update pe syncid
update pe
set SyncId = c.Id
--select *
from tblPhysicalEntity pe
join ##migratingFac facList on pe.Id = facList.Id
join ##Companies c on facList.LegacyName = c.ShortName

select *
from tblPhysicalEntity
where LevelId = 3
and SyncId is not null

/*
select Id, firstname, lastname
from ##Residents
where companyid = 872
order by LastName, FirstName

select *
from ##companies
where Id = 872

select r.SyncId, p.First, p.Last, r.*
from tblResident r
join tblPerson p on p.Id = r.PersonId
where r.peid = 42541
Order by p.Last, p.First
*/

---------------------payors

select p.Code, p.Name
from tblPayor p
join ##migratingFac pe on p.PeId = pe.Id
order by Code
select p.Code, p.Name
from ##BillableEntities p
join ##companies c on p.CompanyId = c.Id
join ##migratingFac pe on pe.LegacyName = c.ShortName
order by Code


update pArt
set SyncId = p.ID
--select *
from tblPayor pArt
join ##migratingFac pe on pe.Id = pArt.PeId
join ##Companies c on pe.LegacyName = c.ShortName
join ##BillableEntities p on c.Id = p.CompanyId and p.Code = pArt.Code

------------------end payors



update r
set SyncId = rr.Id
--select r.ID
from tblResident r
join ##Residents rr on r.SystemNo = rr.systemnumber
join ##companies c on rr.CompanyId = c.Id
join ##migratingFac pe on r.PeId = pe.Id and pe.LegacyName = c.ShortName
--where r.id = 1362410

select *
from tblResident where id = 1362410
--order by r.Id


update p
set SyncId = rr.Id
--select p.*
from tblPerson p
join tblResident r on r.PersonId = p.Id
join ##Residents rr on r.SystemNo = rr.systemnumber
join ##companies c on rr.CompanyId = c.Id
join ##migratingFac pe on r.PeId = pe.Id and pe.LegacyName = c.ShortName

--2329
insert tblStay
(SyncId, ResId, Admission, Discharge, StateId, IsBh)
select s.Id, rArt.Id, s.AdmitDate, DischargeDate, 1097 StateId, case when rv.ShortDescription = 'H' then 1 else 0 end IsBH
from ##Residents r
join tblResident rArt on rArt.SyncId = r.Id
join ##ResidentStays s on r.Id = s.ResidentId
join ##resourcevalues rv on s.RecordTypeId = rv.Id
join ##companies c on r.CompanyId = c.Id
join ##migratingFac pe on rArt.PeId = pe.Id and pe.LegacyName = c.ShortName


/*
drop table ##tblStayPayor
drop table ##StayCoPayor
drop table ##BestRateCode
*/

--5283
select rp.Id SyncId, rsArt.SyncId StayId, rp.PayorId, rp.StartDate, rp.EndDate, rp.IncidentNumber IncidentNum, rp.ExpendedDays
 , cast(null as varchar(50)) RateCode
 , cast(null as varchar(50)) RefNum
 , cast(null as varchar(50)) AuthNum 
 , null CoPayorId
 , cast(0.00 as NUMERIC(38,10)) CoPay
into ##tblStayPayor
from ##ResidentStays rs
join tblStay rsArt on rs.Id = rsArt.SyncId
join ##ResidentStayPayors rp on rs.Id = rp.ResidentStayId
join ##companies c on rs.CompanyId = c.Id
join ##migratingFac pe on pe.LegacyName = c.ShortName
--join tblPayor payor on payor.SyncId = rp.PayorId

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
from ##tblStayPayor sp
join ##StayCoPayor scp on sp.SyncId = scp.StayPayorId

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
from ##tblStayPayor sp
join ##BestRateCode scp on sp.SyncId = scp.StayPayorId

update sp
set RefNum = scp.ReferenceNumber
--select *
from ##tblStayPayor sp
join ##ResidentStays s on sp.StayId = s.Id
join ##ResidentPayorReferenceNumbers scp on (s.ResidentId = scp.ResidentId and sp.PayorId = scp.PayorId)

update sp
set AuthNum = auth.AuthorizationNumber
--select *
from ##tblStayPayor sp
join ##ResidentPayorAuthorizationNumbers auth on sp.SyncId = auth.residentpayorid


--5283
insert tblStayPayor
(SyncId, StayId, PayorId, StartDate, EndDate, IncidentNum, ExpendedDays, RateCode, CoPayorId, CoPay, RefNum, AuthNum)
select sp.SyncId, s.Id, p.Id, StartDate, EndDate, IncidentNum, ExpendedDays, RateCode, cp.Id, CoPay, RefNum, AuthNum
from ##tblStayPayor sp
join tblStay s on s.SyncId = sp.StayId
join tblPayor p on sp.PayorId = p.SyncId
left join tblPayor cp on sp.CoPayorId = cp.SyncId

/*

--5283
delete 
--select *
from tblStayPayor
where syncId is null

*/

--delete legacy entries
delete from tblStayPayor 
--select *
from tblStayPayor sp
join tblStay s on sp.StayId = s.Id
join tblResident r on r.Id = s.ResId
join ##migratingFac pe on r.PeId = pe.Id
where sp.SyncId is  null

delete from tblStay 
--select *
from tblStay s 
join tblResident r on r.Id = s.ResId
join ##migratingFac pe on r.PeId = pe.Id
where s.SyncId is null




---in order to migrate the bill info, we need to use transaction no,
---the issue is that ART does not contain trans no, in order to get it we first havce to break
---down DsId into cid and FacId, join on it and bring over the trans no. 
---that will enable us to migrate the bill and cr data joining on trans no which 
----carried over in NCS migration and is unique per facility.

--drop table #omaha_Bill
---bill transno
select p.First, p.Last,cast(null as nvarchar) cid, null transNum, bill.*
into #omaha_Bill
from [tblAging.Bill] bill
join tblResident r on r.Id = bill.ResId
join tblPerson p on p.id = r.PersonId
where r.PeId = 42541
order by Last, First, Balance

update b
SET cid = RTRIM(CAST(SUBSTRING(DsId, 1, DATALENGTH(DsId) - 4) AS NVARCHAR(20)))
from #omaha_Bill b


select *
from #omaha_Bill bArt
join DsReplica_new.dbo.AR_billfinl bNCS on (bArt.cid COLLATE Latin1_General_CS_AS = bNCS.cid COLLATE Latin1_General_CS_AS and bNCS.FacId = 456)
order by Last, First, Balance


update bArt
set transNum = bNCS.ntransno
from #omaha_Bill bArt
join DsReplica_new.dbo.AR_billfinl bNCS on (bArt.cid COLLATE Latin1_General_CS_AS = bNCS.cid COLLATE Latin1_General_CS_AS and bNCS.FacId = 456)

select *
from #omaha_Bill bArt
order by Last, First, Balance

---cr transno

select p.First, p.Last,cast(null as nvarchar) cid, null transNum, bill.*
into #omaha_Cr
from [tblAging.Cr] bill
join tblResident r on r.Id = bill.ResId
join tblPerson p on p.id = r.PersonId
where r.PeId = 42541
order by Last, First, Balance

select *
from #omaha_Cr b

update b
SET cid = RTRIM(CAST(SUBSTRING(DsId, 1, DATALENGTH(DsId) - 4) AS NVARCHAR(20)))
from #omaha_Cr b


select *
from #omaha_Cr bArt
join DsReplica_new.dbo.AR_payfinl bNCS on (bArt.cid COLLATE Latin1_General_CS_AS = bNCS.cid COLLATE Latin1_General_CS_AS and bNCS.FacId = 456)
order by Last, First, Balance


update bArt
set transNum = bNCS.ntransno
from #omaha_Cr bArt
join DsReplica_new.dbo.AR_payfinl bNCS on (bArt.cid COLLATE Latin1_General_CS_AS = bNCS.cid COLLATE Latin1_General_CS_AS and bNCS.FacId = 456)

select *
from #omaha_Cr bArt
order by Last, First, Balance