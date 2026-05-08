select *
from BillableEntities


select max(ResponseTime) Timestamp
into ##LatestFullNCSCycle
from ApiRequestLogs
where Endpoint = 'openMonthDates'

select top 100 *
from ApiRequestLogs
order by id desc


select *
from [dbo].[BillingGroups]
where CompanyId = 3
and name not like '%Medicaid%'
order by Name


select *
from [dbo].[BillingGroups] g
join BillableEntities p on g.id = p.BillingGroupId
where g.Name = 'Veterans'
--order by Name

select *
from [dbo].BillableEntities p
where PayorTypeId = 1299

select distinct description
from [dbo].[ResourceValues] rv
join BillableEntities p on rv.id = p.PayorTypeId
where rv.id > 1295
and [Description] not like '%Medicaid%'

select *
from BillingGroups

select *
from BillableEntities
where BillingGroupId = 115



select distinct endpoint
from ApiRequestLogs
order by Id desc

select *
from Residents r
where LastUpdated is null
and CreatedAt is not null

select * from [dbo].[VbpFactors]

select *
from ResidentContacts

order by CreatedAt desc

join ApiRequestLogs l on r.ApiRequestSlug = l.Slug


select * from [dbo].[GeneralLedgerGroups]

select * from [dbo].GlAccounts
where name like 'Bad%'

select top 100 *
from Facilities
select BedId
from ResidentStayBeds
group by BedId
having count(*) > 2

select * 
from Beds


select *
from DistinctUnits

select distinct [Name]
from BillingGroups
where [Name] not like '%Medicaid%'
order by Name


--https://censusweb-swa.nationalcaresystems.com/company/872/census/resident-detail/1009530/admits-discharges/resident-stays/2057686/entry


select *
from Residents 
where id = 910370

select top 10000 *
from [dbo].[ResidentPayorReferenceNumbers] rp
join BillableEntities be on rp.PayorId = be.Id
--join BillingGroups bg on be.BillingGroupId = bg.Id
left join ResourceValues pt on be.HmoTypeId = pt.Id
where ResidentId = 1009774

select payor.Name, cpayor.Name, sp.*

select *
from ResidentStays s
join ResidentStayPayors sp on s.id = sp.ResidentStayId
join ResidentStayPayorRateCodes rc on sp.id = rc.ResidentStayPayorId
--join BillableEntities payor on payor.id = sp.PayorId
--left join ResidentPayorCoinsurers pc on pc.ResidentPayorId = sp.Id
--left join BillableEntities cpayor on cpayor.id = pc.PayorId
where s.ResidentId = 1009504
order by StartDate

 SELECT *
    FROM ResidentPayorCoinsurers spc
    join ResidentStayPayors sp on spc.ResidentPayorId = sp.Id
    join ResidentStayPayorRateCodes rate on rate.ResidentStayPayorId = sp.Id
    where sp.ResidentStayId = 2057686

   -- https://censusweb-swa.nationalcaresystems.com/company/872/census/resident-detail/1009504/admits-discharges/resident-stays/2057622/entry

SELECT
    s.ResidentPayorId,
    bestPayor.*
FROM
(
    SELECT DISTINCT ResidentPayorId
    FROM ResidentPayorCoinsurers spc
    join ResidentStayPayors sp on spc.ResidentPayorId = sp.Id
    where sp.ResidentStayId = 2057686


) s
OUTER APPLY
(
    SELECT TOP 1 p.*
    FROM ResidentPayorCoinsurers p
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





select top 1000 * from ResidentPayorCoinsurers 

select top 100 * from [dbo].[ResidentPartBEligibilities]
where residentId = 909936

select top 100 * from [dbo].ResidentPartBPayors
where residentId = 909936

select top 1000 *
from [dbo].[ResidentMds]

select * from [dbo].[ResidentAncillaries]

select * from [dbo].[ResidentMedicaidPending]


select * from [dbo].[ResidentPartBPayors]


Select * 
from ResidentStays



select top 1000 *
from Residents
where IsInCollections = 1

select *
from ResourceValues
where Description like '%Compe%'

select *
from Companies
where Name like '%Omaha%'
or ShortName like '%Omaha%'

select top 100 *
from ResidentBills b
where DistinctUnitId is null

select top 100 v.Name, r.*, d.*, payor.*
from Receipts r
join Deposits d on d.id = r.DepositId
join Vendors v on r.VendorId = v.Id
join BillableEntities payor on payor.Id = r.BillableEntityId
where TypeId = 35
--and BillableEntityId is not null
and residentid is not null



select top 100 *
from Deposits


select *
from Vendors
where name like '%Blosso%'




select *
from ResourceValues
where id in(33, 34, 35, 36, 1308)


select *
from residents r
join Companies c on r.CompanyId = c.Id
where r.id = 21449
