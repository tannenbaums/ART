--starting to put bill together 
declare @resId int = 1009239
--helen abdouch 1009408
--Brenda Abraham 1009197
--Abrego Salvador 1009334
-- Acosta, Samuel 1008941
--1009239

/*
select *
from [dbo].[ResidentBills]
where StartDate >= '4/1/2023' and EndDate <='4/30/2023'
*/

select rb.Id SyncId, rb.ResidentId ResId, rb.TransactionDate, rb.StartDate, rb.EndDate, b.Amt
--, PayorId
, rb.TransactionNumber
, pay.Name Payor
, 'I' ServiceType
, nvPayType.ShortDescription PayType
, rb.ServiceDescription TherapyType
, du.Code Du
, rb.Gross
from [dbo].[ResidentBills] rb
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
join (
select SyncId, sum(Gross) Amt
from(
select rb.Id SyncId, Gross
from [dbo].[ResidentBills] rb
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is null

union all

select rb.Id SyncId, -rb.Gross 
from [dbo].[ResidentBills] rb
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = @resId
AND rb.VoidedDate IS NOT NULL
and rb.ParentBillId is null

union all

select rb.ParentBillId SyncId, rb.Gross 
from [dbo].[ResidentBills] rb
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is not null
AND rb.VoidedDate IS NULL
) a
group by SyncId) b on b.SyncId = rb.Id
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is null
order by StartDate
--AND rb.VoidedDate IS NULL



/*
select *
from [ResidentBills] rb
where rb.CompanyId = 872
and rb.ResidentId = @resId
and rb.ParentBillId is null
AND rb.VoidedDate IS NULL



select *
from [ResidentBills] rb
where rb.ResidentId = @resId
*/