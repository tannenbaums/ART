--miss ncs queries

select distinct Code
from DistinctUnits
where Code not like '%[0-9]%'

select *
from DistinctUnits
where CompanyId = 872



select top 2 * from [dbo].[ResidentAncillaryBills]

select *
from ResourceValues
where Id between 30 and 50

select top 2 * from [dbo].[ResidentBills]
select top 2 * from [dbo].[Receipts]

select distinct ServiceDescription
from [ResidentBills]
order by 1

select *
from Companies
where ShortName like '%Test%'

select rb.Id SyncId, rb.ResidentId ResId, rb.TransactionDate, rb.StartDate, rb.EndDate
--, PayorId
, rb.TransactionNumber
, pay.Name Payor
, 'I' ServiceType
, nvPayType.ShortDescription PayType
, rb.ServiceDescription TherapyType
, du.Code Du
, rb.Gross rbGross, rbb.Gross rbbGross
from [dbo].[ResidentBills] rb
left join [dbo].[ResidentBills] rbb on rb.Id = rbb.ParentBillId
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = 1009408
--and nvPayType.ShortDescription <> 'D'
order by rb.StartDate, rb.TransactionDate


select *
from [dbo].billing_shmuel
where cresid =1009408
order by start_date, bill_date



select *
from [dbo].[ResidentBills] rb
where rb.CompanyId = 872
and rb.residentId = 1009408
and id in(31063449, 31043005)



select *
from [ResidentBills]
where ParentBillId = 31051025


select * from [dbo].[ResidentDepositTypes]

select *
from [dbo].[ResidentAncillaryBills] rb
--left join [dbo].[ResidentAncillaryBills] rbb on rb.Id = rbb.ParentBillId
where rb.CompanyId = 872
and rb.residentId = 1009408


select *
from [dbo].[Receipts] rb
left join [ReceiptNonArAmounts] rbr on rb.id = rbr.ReceiptId
where rb.CompanyId = 872
and rb.residentId = 1009408

select *
from [ResidentBills] b
where 1=1
--and id = 31045593
and residentid = 1009408


select * from [dbo].[ReceiptNonArAmounts]

select *
from [dbo].[ReceiptNonArAmounts] rb
where rb.CompanyId = 872
and Amount = -8847.18

and rb.residentId = 1009408


select *
from ResourceValues
where id  33

select r.Id, r.LastName, r.FirstName,  rb.Id SyncId, rb.ResidentId ResId, rb.TransactionDate, rb.StartDate, rb.EndDate
, rb.TransactionNumber
, pay.Name Payor
, case when nvServiceType.ShortDescription = 'PARTA' then 'I' else 'A' end ServiceType
, nvPayType.ShortDescription PayType
, rb.ServiceDescription TherapyType
, du.Code Du
, rb.Gross rbGross, rbb.Gross rbbGross
from [dbo].[ResidentAncillaryBills] rb
left join [dbo].[ResidentAncillaryBills] rbb on rb.Id = rbb.ParentBillId
left join ResourceValues nvServiceType on rb.PartABId = nvServiceType.Id
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = rb.PayorId
where rb.CompanyId = 872
and r.Id = 1009408
and nvServiceType.ShortDescription <> 'PARTA'
order by rb.StartDate, rb.TransactionDate, TherapyType

select rb.Id SyncId, ResidentId ResId, d.TransactionDate, StartDate, EndDate
, rb.TransactionNumber
, pay.Name Payor
, case when nvServiceType.ShortDescription = 'PARTA' then 'I' else 'A' end ServiceType
, nvPayType.ShortDescription PayType
, du.Code Du
, Net
from [dbo].[Receipts] rb
left join Deposits d on rb.DepositId = d.Id
left join ResourceValues nvServiceType on rb.PartABId = nvServiceType.Id
left join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
left join DistinctUnits du on du.Id = rb.DistinctUnitId
left join Residents r on rb.ResidentId = r.Id
left join BillableEntities pay on pay.Id = BillableEntityId
where rb.CompanyId = 872
and r.Id = 1009408
order by StartDate, TransactionDate




select *
from (
select Id, TransactionNumber
from [dbo].[ResidentAncillaryBills] rb
where CompanyId = 872
union 
select Id, TransactionNumber
from [dbo].[ResidentBills] rb
where CompanyId = 872
union 
select Id, TransactionNumber
from [dbo].[Receipts] rb
where CompanyId = 872
) a 
where a.TransactionNumber = 38438


select *
from (
select Id, gross amt
from [dbo].[ResidentAncillaryBills] rb
where CompanyId = 872
union 
select Id, gross amt
from [dbo].[ResidentBills] rb
where CompanyId = 872
union 
select Id, net amt
from [dbo].[Receipts] rb
where CompanyId = 872
) a 
where a.amt = -8847.18



select Id, gross amt
from [dbo].[ResidentAncillaryBills] rb
where 1=1
--and CompanyId = 872
and gross = 8847.18

union 


select Id, gross amt
from [dbo].[ResidentBills] rb
where 1=1
--and CompanyId = 872
and gross = -8847.18


union 

select Id, net amt
from [dbo].[Receipts] rb
where CompanyId = 872
and net = 8847.18


order by LastName, FirstName


select top 10 rb.Id SyncId, ResidentId ResId, StartDate, EndDate, d.TransactionDate, BillableEntityId PayorId
, case when nvServiceType.ShortDescription = 'PARTA' then 'I' else 'A' end ServiceType
, nvPayType.ShortDescription PayType
, du.Code Du
from [dbo].[Receipts] rb
join Deposits d on rb.DepositId = d.Id
join ResourceValues nvServiceType on rb.PartABId = nvServiceType.Id
join ResourceValues nvPayType on rb.TypeId = nvPayType.Id
join DistinctUnits du on du.Id = rb.DistinctUnitId
where rb.CompanyId = 872


--an old query

select
    parentBill.ResidentId,
    parentBill.StartDate,
    sum(parentBill.Gross) as Gross,
    sum(isnull(childBill.Gross, 0)) as Net
from ResidentBills parentBill
left join ResidentBills childBill
    on parentBill.Id = childBill.ParentBillId
   and childBill.Deleted = 0
where parentBill.ResidentId = 873802
  and parentBill.StartDate = '2025-03-07'
  and parentBill.Deleted = 0
group by
    parentBill.ResidentId,
    parentBill.StartDate;