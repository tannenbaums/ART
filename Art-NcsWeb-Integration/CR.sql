--trying it with cr
declare @resId int = 1008941
--helen abdouch 1009408
--Brenda Abraham 1009197
--Abrego Salvador 1009334
-- Acosta, Samuel 1008941

select   
  rb.Id SyncId
, rb.StartDate
, rb.EndDate
, d.TransactionDate
, rb.TransactionNumber
, rb.ResidentId ResId
, rb.BillableEntityId PayorId
, case when nvServiceType.ShortDescription = 'S' then 'I' else 'A' end ServiceType
, nvPayType.ShortDescription PayType
, rb.ServiceDescription TherapyType
, du.Code Du
, rb.Net Balance
from [dbo].Receipts rb
join Deposits d on d.id= rb.DepositId
left join ResourceValues nvServiceType on rb.ServiceTypeId = nvServiceType.Id
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
where rb.CompanyId = 872
and rb.ResidentId = @resId
and rb.Deleted = 0


select *
from [Receipts] rb
where rb.CompanyId = 872
and rb.ResidentId = @resId


/*
select *
from [Receipts] rb
where rb.CompanyId = 872
and rb.ResidentId = 1009408
and rb.ParentBillId is null
AND rb.VoidedDate IS NULL

select *
from ResourceValues
where id in(37, 38)


select Id
from [Receipts] rb
group by Id
having count(Id) > 1



select *
from [ResidentBills] rb
where rb.ResidentId = @resId
*/

