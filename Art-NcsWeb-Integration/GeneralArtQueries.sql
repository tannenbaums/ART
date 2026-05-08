--ART query window

select *
from tblPayor


select *  --, count(*)
from tblCase c
where StayId is not null

join tblStay s on s.id = c.StayId


--3288976 total cases


select * 
from tblResident
where Competent is not null

select *
from tblNameValue 
where id = 1444


select *
from NameValueHierarchy nvh
where nvh.ParentName = 'PayorLevel' and nvh.ChildName = 'Category'

select *
from tblClient


select * 
from tblPhysicalEntity
where LevelId =3
and Active =1
and isnull(StateId, 0) <> 1097


select *
from tblPerson p
join tblResident r on p.id = r.PersonId
join tblPhysicalEntity pe on pe.id = r.PeId
where r.IsPending = 1


select *
from tblResident
where BCoPayorId is not null
