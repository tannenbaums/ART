--trying it with cr
declare @resId int = 1008941
--helen abdouch 1009408
--Brenda Abraham 1009197
--Abrego Salvador 1009334
-- Acosta, Samuel 1008941

select rb.Id SyncId, rb.ResidentId ResId, d.TransactionDate, rb.StartDate, rb.EndDate, b.Amt
--, PayorId
, rb.TransactionNumber
, pay.Name Payor
, 'I' ServiceType
, nvPayType.ShortDescription PayType
, rb.ServiceDescription TherapyType
, du.Code Du
, rb.Net
from [dbo].Receipts rb
join Deposits d on d.id= rb.DepositId
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.BillableEntityId
join (
select SyncId, sum(Net) Amt
from(
select rb.Id SyncId, Net
from [dbo].Receipts rb
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.BillableEntityId
where rb.CompanyId = 872
and r.Id = @resId


) a
group by SyncId) b on b.SyncId = rb.Id
where rb.CompanyId = 872
and r.Id = @resId
--AND rb.VoidedDate IS NULL



/*
select *
from [Receipts] rb
where rb.CompanyId = 872
and rb.ResidentId = 1009408
and rb.ParentBillId is null
AND rb.VoidedDate IS NULL



select *
from [ResidentBills] rb
where rb.ResidentId = @resId
*/