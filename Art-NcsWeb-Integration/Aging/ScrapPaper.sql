select UniqueIdentifier
from [tblAging.Bal] 
group by UniqueIdentifier
having count(*) > 1

select *
from tblPhysicalEntity
where SyncId = 872


update tblPhysicalEntity
set FriendlyName = null
where Id = 42541

select count(*)
from [tblAging.Bal]


--there are 23,697 bills over all for 
--16,197 I
--7500 A
select count(*)
from [tblAging.Bill] b
join tblResident r on r.id = b.ResId
join tblPhysicalEntity pe on pe.Id = r.PeId
where pe.SyncId = 872 --test omaha
and b.SyncId is not null

select b.*
from [tblAging.Bill] b
join tblResident r on r.id = b.ResId
join tblPhysicalEntity pe on pe.Id = r.PeId
where pe.SyncId = 872 --test omaha
and b.SyncId is null

--update [tblAging.Bill]
--set Deleted = 0

--where pe.id = 39494    --omaha
and ServiceTypeId = 1602





select TransactionNumber
into ##FalloutsA
from ##omaha_Bill a
right join ##NCSTransNum b on a.transnum = b.TransactionNumber
where a.transnum is null

where b.TransactionNumber is null


select distinct TransactionNumber
into ##NCSTransNum
from(
select TransactionNumber from ##NCSTransNumI
union
select TransactionNumber from ##NCSTransNumA
) a

select * 
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Residents] t


select distinct TransactionNumber
into ##NCSTransNumA
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentAncillaryBills]
where CompanyId = 872


select *
--into ##NCSTransNumA
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentBills] b
join ##FalloutsA f on b.TransactionNumber = f.TransactionNumber
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Residents] r on r.Id = b.ResidentId
where b.CompanyId = 872
order by r.Id




order by TransactionNumber

select *
from tblPhysicalEntity
where name like '%Omaha%'
and LevelId = 3

select distinct trans
from [tblAging.Bill] b
join tblResident r on r.id = b.ResId
join tblPhysicalEntity pe on pe.Id = r.PeId
where pe.SyncId = 872
and ServiceTypeId = 1602




select *
from [tblAging.BalContext] bc
left join [tblAging.Bal] bal on bal.id = bc.BalId
where bal.Id is null

select top 1000 *
from [tblAging.Bal]
where Deleted = 1



