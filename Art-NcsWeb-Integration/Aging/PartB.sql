--trying it with partb
declare @resId int = 1009197
--helen abdouch 1009408
--Brenda Abraham 1009197
--Abrego Salvador 1009334
-- Acosta, Samuel 1008941


select rb.Id SyncId, rb.ResidentId ResId, rb.TransactionDate, rb.StartDate, rb.EndDate, b.Amt
--, PayorId
, rb.TransactionNumber
, pay.Name Payor
, 'I' ServiceType
, nvPayType.ShortDescription PayType
, rb.ServiceDescription TherapyType
, du.Code Du
, rb.Gross
from [dbo].[ResidentAncillaryBills] rb
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
join (
select SyncId, sum(Gross) Amt
from(
select rb.Id SyncId, Gross
from [dbo].[ResidentAncillaryBills] rb
join ResourceValues rvServiceType on rvServiceType.Id = rb.PartABid
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is null
and rvServiceType.ShortDescription = 'PARTB'

union all

select rb.Id SyncId, -rb.Gross 
from [dbo].[ResidentAncillaryBills] rb
join ResourceValues rvServiceType on rvServiceType.Id = rb.PartABid
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = @resId
AND rb.VoidedDate IS NOT NULL
and rvServiceType.ShortDescription = 'PARTB'
and rb.ParentBillId is null

union all

select rb.ParentBillId SyncId, rb.Gross 
from [dbo].[ResidentAncillaryBills] rb
join ResourceValues rvServiceType on rvServiceType.Id = rb.PartABid
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is not null
and rvServiceType.ShortDescription = 'PARTB'
AND rb.VoidedDate IS NULL
) a
group by SyncId) b on b.SyncId = rb.Id
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is null


/*
select *
from [ResidentAncillaryBills] rb
where rb.CompanyId = 872
and rb.ResidentId = @resId
and rb.ParentBillId is null
AND rb.VoidedDate IS NULL



select *
from [ResidentBills] rb
where rb.ResidentId = @resId
*/