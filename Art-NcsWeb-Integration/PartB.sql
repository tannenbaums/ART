--trying it with partb
declare @resId int = 1009334
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
, rb.ServiceDescription TherapyType
, du.Code Du
, b.Amt Balance
from [dbo].[ResidentAncillaryBills] rb
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
join (
select Id, sum(Gross) Amt
from(
select rb.Id, Gross
from [dbo].[ResidentAncillaryBills] rb
join ResourceValues rvServiceType on rvServiceType.Id = rb.PartABid
where rb.CompanyId = 872
and rb.ResidentId = @resId
and rb.ParentBillId is null
and rvServiceType.ShortDescription = 'PARTB'

union all

select rb.Id, -rb.Gross 
from [dbo].[ResidentAncillaryBills] rb
join ResourceValues rvServiceType on rvServiceType.Id = rb.PartABid
where rb.CompanyId = 872
and rb.ResidentId = @resId
AND rb.VoidedDate IS NOT NULL
and rvServiceType.ShortDescription = 'PARTB'
and rb.ParentBillId is null

union all

select rb.ParentBillId Id, rb.Gross 
from [dbo].[ResidentAncillaryBills] rb
join ResourceValues rvServiceType on rvServiceType.Id = rb.PartABid
where rb.CompanyId = 872
and rb.ResidentId = @resId
and rb.ParentBillId is not null
and rvServiceType.ShortDescription = 'PARTB'
AND rb.VoidedDate IS NULL
) a
group by Id) b on b.Id = rb.Id
where rb.CompanyId = 872
and r.Id = @resId
and rb.ParentBillId is null
and rb.WriteOff = 0
and rb.Deleted = 0


/*
select *
from [ResidentAncillaryBills] rb
where rb.CompanyId = 872
and rb.ResidentId = 1008941

and rb.ParentBillId is null
AND rb.VoidedDate IS NULL



select *
from [ResidentBills] rb
where rb.ResidentId = @resId
*/