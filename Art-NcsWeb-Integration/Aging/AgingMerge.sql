----working on aging merge
select p.First, p.Last
,RTRIM(CAST(SUBSTRING(bill.DsId, 1, DATALENGTH(bill.DsId) - 4) AS NVARCHAR(20))) cid
, null transNum, bill.*
into ##omaha_Bill
from [##ART_tblAging.Bill] bill
join ##ART_tblResident r on r.Id = bill.ResId
join ##ART_tblPerson p on p.id = r.PersonId
where r.PeId = 42541
order by Last, First, Balance

--23697
--select count(*)
--from ##omaha_Bill

update bArt
set transNum = bNCS.ntransno
from ##omaha_Bill bArt
join DsReplica_new.dbo.AR_billfinl bNCS on (bArt.cid COLLATE Latin1_General_CS_AS = bNCS.cid COLLATE Latin1_General_CS_AS and bNCS.FacId = 456)

--update all 'I' with sync id
--12867
update b
set SyncId = a.SyncId
--select *
from [tblAging.Bill] b
join ##omaha_Bill b1 on b.Id = b1.Id
join tblResident r on b.ResId = r.Id
join (select rb.Id SyncId, rb.ResidentId ResId
, rb.TransactionNumber
from [dbo].[##ResidentBillsRaw] rb
left join ##ResourceValuesRaw nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnitsRaw du on du.Id = rb.DistinctUnitId
left join ##ResidentsRaw r on rb.ResidentId = r.Id
left join ##BillableEntitiesRaw pay on pay.Id = rb.PayorId
join (
select SyncId, sum(Gross) Amt
from(
select rb.Id SyncId, Gross
from [dbo].[##ResidentBillsRaw] rb
left join ##ResourceValuesRaw nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnitsRaw du on du.Id = rb.DistinctUnitId
left join ##ResidentsRaw r on rb.ResidentId = r.Id
left join ##BillableEntitiesRaw pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
--and r.Id = @resId
and rb.ParentBillId is null

union all

select rb.Id SyncId, -rb.Gross 
from [dbo].[##ResidentBillsRaw] rb
left join ##ResourceValuesRaw nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnitsRaw du on du.Id = rb.DistinctUnitId
left join ##ResidentsRaw r on rb.ResidentId = r.Id
left join ##BillableEntitiesRaw pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
--and r.Id = @resId
AND rb.VoidedDate IS NOT NULL
and rb.ParentBillId is null

union all

select rb.ParentBillId SyncId, rb.Gross 
from [dbo].[##ResidentBillsRaw] rb
left join ##ResourceValuesRaw nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnitsRaw du on du.Id = rb.DistinctUnitId
left join ##ResidentsRaw r on rb.ResidentId = r.Id
left join ##BillableEntitiesRaw pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
--and r.Id = @resId
and rb.ParentBillId is not null
AND rb.VoidedDate IS NULL
) a
group by SyncId) b on b.SyncId = rb.Id
where rb.CompanyId = 872
--and r.Id = @resId
and rb.ParentBillId is null
--order by transactionnumber

) as a on a.ResId = r.SyncId and a.TransactionNumber = b1.transnum
--right join 
--(
--select b.Id, b.ServiceTypeId, b.Balance
--from [tblAging.Bill] b
--join ##omaha_Bill b1 on b.Id = b1.Id
--join tblResident r on b.ResId = r.Id
--where 1=1
----and b1.ResId = 1361744
--and b1.Servicetypeid = 1601

--) a1 on a1.Id = b.Id
where 1=1
--and b.Id is null
--and b1.ResId = 1361744
and b1.ServiceTypeId = 1601
--order by b1.transnum

--update all 'A' with sync id
--12867
update b
set SyncId = a.SyncId
--select *
from [tblAging.Bill] b
join ##omaha_Bill b1 on b.Id = b1.Id
join tblResident r on b.ResId = r.Id
join (select rb.Id SyncId, rb.ResidentId ResId
, rb.TransactionNumber
from [dbo].[##ResidentAncillaryBills] rb
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
join (

select SyncId, sum(Gross) Amt
from(
select rb.Id SyncId, Gross
from [dbo].[##ResidentAncillaryBills] rb
join ##ResourceValues rvServiceType on rvServiceType.Id = rb.PartABid
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
--and r.Id = @resId
and rb.ParentBillId is null
and rvServiceType.ShortDescription = 'PARTB'

union all

select rb.Id SyncId, -rb.Gross 
from [dbo].[##ResidentAncillaryBills] rb
join ##ResourceValues rvServiceType on rvServiceType.Id = rb.PartABid
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
--and r.Id = @resId
AND rb.VoidedDate IS NOT NULL
and rvServiceType.ShortDescription = 'PARTB'
and rb.ParentBillId is null

union all

select rb.ParentBillId SyncId, rb.Gross 
from [dbo].[##ResidentAncillaryBills] rb
join ##ResourceValues rvServiceType on rvServiceType.Id = rb.PartABid
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
--and r.Id = @resId
and rb.ParentBillId is not null
and rvServiceType.ShortDescription = 'PARTB'
AND rb.VoidedDate IS NULL
) a
group by SyncId) b on b.SyncId = rb.Id
where rb.CompanyId = 872
--and r.Id = @resId
and rb.ParentBillId is null
) as a on a.ResId = r.SyncId and a.TransactionNumber = b1.transnum
where 1=1
--and b.Id is null
--and b1.ResId = 1361744
and b1.ServiceTypeId = 1602



--cr
select p.First, p.Last
,RTRIM(CAST(SUBSTRING(bill.DsId, 1, DATALENGTH(bill.DsId) - 4) AS NVARCHAR(20))) cid
, null transNum, bill.*
into ##omaha_Cr
from [tblAging.cr] bill
join tblResident r on r.Id = bill.ResId
join tblPerson p on p.id = r.PersonId
where r.PeId = 42541
order by Last, First, Balance

--17416
select count(*)
from ##omaha_Cr

update bArt
set transNum = bNCS.ntransno
from ##omaha_Cr bArt
join DsReplica_new.dbo.AR_payfinl bNCS on (bArt.cid COLLATE Latin1_General_CS_AS = bNCS.cid COLLATE Latin1_General_CS_AS and bNCS.FacId = 456)


update b
set SyncId = a.SyncId
--select *
from [tblAging.Cr] b
join ##omaha_Cr b1 on b.Id = b1.Id
join tblResident r on b.ResId = r.Id
join (
select rb.Id SyncId, rb.ResidentId ResId, d.TransactionDate, rb.StartDate, rb.EndDate, b.Amt
--, PayorId
, rb.TransactionNumber
, pay.Name Payor
, 'I' ServiceType
, nvPayType.ShortDescription PayType
, rb.ServiceDescription TherapyType
, du.Code Du
, rb.Net
from ##ReceiptsRaw rb
join ##DepositsRaw d on d.id= rb.DepositId
left join ##ResourceValuesRaw nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnitsRaw du on du.Id = rb.DistinctUnitId
left join ##ResidentsRaw r on rb.ResidentId = r.Id
left join ##BillableEntitiesRaw pay on pay.Id = rb.BillableEntityId
join (
select SyncId, sum(Net) Amt
from(
select rb.Id SyncId, Net
from ##ReceiptsRaw rb
left join ##ResourceValuesRaw nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnitsRaw du on du.Id = rb.DistinctUnitId
left join ##ResidentsRaw r on rb.ResidentId = r.Id
left join ##BillableEntitiesRaw pay on pay.Id = rb.BillableEntityId
where rb.CompanyId = 872

) a
group by SyncId) b on b.SyncId = rb.Id
where rb.CompanyId = 872
) as a on a.ResId = r.SyncId and a.TransactionNumber = b1.transnum
where 1=1
and b1.ServiceTypeId = 1601





/*
declare @resId int = 1009408

select rb.Id SyncId, rb.ResidentId ResId, rb.TransactionDate, rb.StartDate, rb.EndDate
--, PayorId
, rb.TransactionNumber
, pay.Name Payor
, 'I' ServiceType
, nvPayType.ShortDescription PayType
, rb.ServiceDescription TherapyType
, du.Code Du
, b.Amt Balance
from [dbo].[##ResidentBills] rb
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
join (
select SyncId, sum(Gross) Amt
from(
select rb.Id SyncId, Gross
from [dbo].[##ResidentBills] rb
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is null

union all

select rb.Id SyncId, -rb.Gross 
from [dbo].[##ResidentBills] rb
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = @resId
AND rb.VoidedDate IS NOT NULL
and rb.ParentBillId is null

union all

select rb.ParentBillId SyncId, rb.Gross 
from [dbo].[##ResidentBills] rb
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is not null
AND rb.VoidedDate IS NULL
) a
group by SyncId) b on b.SyncId = rb.Id
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is null
order by transactionnumber

select *
from DsReplica_new.dbo.AR_billfinl bNCS on (bArt.cid COLLATE Latin1_General_CS_AS = bNCS.cid COLLATE Latin1_General_CS_AS and bNCS.FacId = 456)

select *
from [tblAging.Bill]
where syncid is not null

----------------



--12867
update b
set SyncId = a.SyncId
--select *
from [tblAging.Bill] b
join ##omaha_Bill b1 on b.Id = b1.Id
join tblResident r on b.ResId = r.Id
join (select rb.Id SyncId, rb.ResidentId ResId
, rb.TransactionNumber
from [dbo].[##ResidentBills] rb
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
join (
select SyncId, sum(Gross) Amt
from(
select rb.Id SyncId, Gross
from [dbo].[##ResidentBills] rb
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
--and r.Id = @resId
and rb.ParentBillId is null

union all

select rb.Id SyncId, -rb.Gross 
from [dbo].[##ResidentBills] rb
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
--and r.Id = @resId
AND rb.VoidedDate IS NOT NULL
and rb.ParentBillId is null

union all

select rb.ParentBillId SyncId, rb.Gross 
from [dbo].[##ResidentBills] rb
left join ##ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join ##DistinctUnits du on du.Id = rb.DistinctUnitId
left join ##Residents r on rb.ResidentId = r.Id
left join ##BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
--and r.Id = @resId
and rb.ParentBillId is not null
AND rb.VoidedDate IS NULL
) a
group by SyncId) b on b.SyncId = rb.Id
where rb.CompanyId = 872
--and r.Id = @resId
and rb.ParentBillId is null
--order by transactionnumber

) as a on a.ResId = r.SyncId and a.TransactionNumber = b1.transnum
--right join 
--(
--select b.Id, b.ServiceTypeId, b.Balance
--from [tblAging.Bill] b
--join ##omaha_Bill b1 on b.Id = b1.Id
--join tblResident r on b.ResId = r.Id
--where 1=1
----and b1.ResId = 1361744
--and b1.Servicetypeid = 1601

--) a1 on a1.Id = b.Id
where 1=1
--and b.Id is null
--and b1.ResId = 1361744
and b1.ServiceTypeId = 1601
--order by b1.transnum



-------------------






select bArt.*, ncsBills.*
from #omaha_Bill bArt
join [tblAging.Bill] bill on bArt.Id = bill.Id
join tblResident res on bill.ResId = res.Id
join tblPhysicalEntity pe on res.PeId = pe.Id
join ##NcsBills ncsBills on bArt.transNum =ncsBills.transactionNumber and ncsBills.CompanyId = pe.SyncId
order by Last, First, Balance

update bill
set SyncId = ncsBills.Id
from #omaha_Bill bArt
join [tblAging.Bill] bill on bArt.Id = bill.Id
join tblResident res on bill.ResId = res.Id
join tblPhysicalEntity pe on res.PeId = pe.Id
join ##NcsBills ncsBills on bArt.transNum =ncsBills.transactionNumber and ncsBills.CompanyId = pe.SyncId


--drop table ##NcsBills

select Id, TransactionNumber, companyId
into ##NcsBills
from ##ResidentAncillaryBills
union all
select Id, TransactionNumber, companyId
from ##ResidentBills


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





/*******************i might need this from the transfer from omaha to test omaha**************
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


*/
