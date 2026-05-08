--starting to put bill together 
declare @resId int = 1009408
--helen abdouch 1009408
--Brenda Abraham 1009197
--Abrego Salvador 1009334
-- Acosta, Samuel 1008941

select 
  rb.Id SyncId
, rb.StartDate
, rb.EndDate
, rb.TransactionDate
, rb.TransactionNumber
, rb.ResidentId ResId
, PayorId
, 'I' ServiceType
, nvPayType.ShortDescription PayType
, '' TherapyType
, du.Code Du
, b.Amt Balance
from [dbo].[ResidentBills] rb
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
join (
select Id, sum(Gross) Amt
from(
select rb.Id, Gross
from [dbo].[ResidentBills] rb
where rb.CompanyId = 872
and rb.ResidentId = @resId
and rb.ParentBillId is null
 and rb.Deleted = 0

union all

select rb.Id, -rb.Gross 
from [dbo].[ResidentBills] rb
where rb.CompanyId = 872
and rb.ResidentId = @resId
AND rb.VoidedDate IS NOT NULL
and rb.ParentBillId is null
and rb.Deleted = 0

union all

select rb.ParentBillId Id, rb.Gross 
from [dbo].[ResidentBills] rb
where rb.CompanyId = 872
and rb.ResidentId = @resId
and rb.ParentBillId is not null
AND rb.VoidedDate IS NULL
and rb.Deleted = 0
) a
group by Id) b on b.Id = rb.Id
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is null
and rb.Deleted = 0



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