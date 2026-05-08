-------------------------------------------------
-- ##CompaniesRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##CompaniesRaw') IS NOT NULL DROP TABLE ##CompaniesRaw;
select t.* into ##CompaniesRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] t
where IsARTrackEnabled = 1;

go
-------------------------------------------------
-- ##ResidentsRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentsRaw') IS NOT NULL DROP TABLE ##ResidentsRaw;
select t.* into ##ResidentsRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Residents] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;

go

-------------------------------------------------
-- ##ResidentPayorReferenceNumbersRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentPayorReferenceNumbersRaw') IS NOT NULL DROP TABLE ##ResidentPayorReferenceNumbersRaw;
select t.* into ##ResidentPayorReferenceNumbersRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentPayorReferenceNumbers] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;


go
-------------------------------------------------
-- ##BillingGroupsRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##BillingGroupsRaw') IS NOT NULL DROP TABLE ##BillingGroupsRaw;
select t.* into ##BillingGroupsRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[BillingGroups] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;

go
-------------------------------------------------
-- ##BillableEntitiesRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##BillableEntitiesRaw') IS NOT NULL DROP TABLE ##BillableEntitiesRaw;
select t.* into ##BillableEntitiesRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[BillableEntities] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;


go
-------------------------------------------------
-- ##ResidentPartBEligibilitiesRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentPartBEligibilitiesRaw') IS NOT NULL DROP TABLE ##ResidentPartBEligibilitiesRaw;
select t.* into ##ResidentPartBEligibilitiesRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentPartBEligibilities] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;


go
-------------------------------------------------
-- ##ResidentMedicaidPendingRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentMedicaidPendingRaw') IS NOT NULL DROP TABLE ##ResidentMedicaidPendingRaw;
select t.* into ##ResidentMedicaidPendingRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentMedicaidPending] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;


go
-------------------------------------------------
-- ##ResidentStaysRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentStaysRaw') IS NOT NULL DROP TABLE ##ResidentStaysRaw;
select t.* into ##ResidentStaysRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentStays] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;


go
-------------------------------------------------
-- ##ResidentStayPayorsRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentStayPayorsRaw') IS NOT NULL DROP TABLE ##ResidentStayPayorsRaw;
select t.* into ##ResidentStayPayorsRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentStayPayors] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;


go
-------------------------------------------------
-- ##BedsRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##BedsRaw') IS NOT NULL DROP TABLE ##BedsRaw;
select t.* into ##BedsRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Beds] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;


go
-------------------------------------------------
-- ##ResidentStayBedsRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentStayBedsRaw') IS NOT NULL DROP TABLE ##ResidentStayBedsRaw;
select t.* into ##ResidentStayBedsRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentStayBeds] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;
go

-------------------------------------------------
-- ##ResidentBillsRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentBillsRaw') IS NOT NULL DROP TABLE ##ResidentBillsRaw;
select t.* into ##ResidentBillsRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentBills] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;
go

-------------------------------------------------
-- ##ResidentAncillaryBillsRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentAncillaryBillsRaw') IS NOT NULL DROP TABLE ##ResidentAncillaryBillsRaw;
select t.* into ##ResidentAncillaryBillsRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentAncillaryBills] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;

go
-------------------------------------------------
-- ##ResourceValuesRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResourceValuesRaw') IS NOT NULL DROP TABLE ##ResourceValuesRaw;
select t.* into ##ResourceValuesRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResourceValues] t
;


go
-------------------------------------------------
-- ##ResidentPayorCoinsurersRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentPayorCoinsurersRaw') IS NOT NULL DROP TABLE ##ResidentPayorCoinsurersRaw;
select t.* into ##ResidentPayorCoinsurersRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentPayorCoinsurers] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;


go
-------------------------------------------------
-- ##ResidentStayPayorRateCodesRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentStayPayorRateCodesRaw') IS NOT NULL DROP TABLE ##ResidentStayPayorRateCodesRaw;
select t.* into ##ResidentStayPayorRateCodesRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentStayPayorRateCodes] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;


go
-------------------------------------------------
-- ##ResidentPayorAuthorizationNumbersRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentPayorAuthorizationNumbersRaw') IS NOT NULL DROP TABLE ##ResidentPayorAuthorizationNumbersRaw;
select t.* into ##ResidentPayorAuthorizationNumbersRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ResidentPayorAuthorizationNumbers] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;


go

-------------------------------------------------
-- ##DistinctUnitsRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##DistinctUnitsRaw') IS NOT NULL DROP TABLE ##DistinctUnitsRaw;
select t.* into ##DistinctUnitsRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[DistinctUnits] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;
go

-------------------------------------------------
-- ##DepositsRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##DepositsRaw') IS NOT NULL DROP TABLE ##DepositsRaw;
select t.* into ##DepositsRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Deposits] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;
go

-------------------------------------------------
-- ##ReceiptsRaw
-------------------------------------------------
IF OBJECT_ID('tempdb..##ReceiptsRaw') IS NOT NULL DROP TABLE ##ReceiptsRaw;
select t.* into ##ReceiptsRaw
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Receipts] t
join [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[Companies] c on t.CompanyId = c.Id
where c.IsARTrackEnabled = 1
;
go

-------------------------------------------------
-- ##LatestFullNCSCycle
-------------------------------------------------
IF OBJECT_ID('tempdb..##LatestFullNCSCycle') IS NOT NULL DROP TABLE ##LatestFullNCSCycle;
--select max(ResponseTime) Timestamp
select DATEADD(DAY, +1, max(ResponseTime)) [Timestamp]
into ##LatestFullNCSCycle
from [FABRIC_sqlFCC].[sqlFCC-0f24422b-85ae-405c-92fd-00379a41c946].[dbo].[ApiRequestLogs]
where Endpoint = 'openMonthDates';


go
-------------------------------------------------
-- ##Companies
-------------------------------------------------
IF OBJECT_ID('tempdb..##Companies') IS NOT NULL DROP TABLE ##Companies;
select t.* into ##Companies
from ##CompaniesRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;


go
-------------------------------------------------
-- ##Residents
-------------------------------------------------
IF OBJECT_ID('tempdb..##Residents') IS NOT NULL DROP TABLE ##Residents;
select t.* into ##Residents
from ##ResidentsRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;


go
-------------------------------------------------
-- ##ResidentPayorReferenceNumbers
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentPayorReferenceNumbers') IS NOT NULL DROP TABLE ##ResidentPayorReferenceNumbers;
select t.* into ##ResidentPayorReferenceNumbers
from ##ResidentPayorReferenceNumbersRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;


go
-------------------------------------------------
-- ##BillingGroups
-------------------------------------------------
IF OBJECT_ID('tempdb..##BillingGroups') IS NOT NULL DROP TABLE ##BillingGroups;
select t.* into ##BillingGroups
from ##BillingGroupsRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;


go
-------------------------------------------------
-- ##BillableEntities
-------------------------------------------------
IF OBJECT_ID('tempdb..##BillableEntities') IS NOT NULL DROP TABLE ##BillableEntities;
select t.* into ##BillableEntities
from ##BillableEntitiesRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;


go
-------------------------------------------------
-- ##ResidentPartBEligibilities
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentPartBEligibilities') IS NOT NULL DROP TABLE ##ResidentPartBEligibilities;
select t.* into ##ResidentPartBEligibilities
from ##ResidentPartBEligibilitiesRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;


go
-------------------------------------------------
-- ##ResidentMedicaidPending
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentMedicaidPending') IS NOT NULL DROP TABLE ##ResidentMedicaidPending;
select t.* into ##ResidentMedicaidPending
from ##ResidentMedicaidPendingRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;


go
-------------------------------------------------
-- ##ResidentStays
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentStays') IS NOT NULL DROP TABLE ##ResidentStays;
select t.* into ##ResidentStays
from ##ResidentStaysRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;


go
-------------------------------------------------
-- ##ResidentStayPayors
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentStayPayors') IS NOT NULL DROP TABLE ##ResidentStayPayors;
select t.* into ##ResidentStayPayors
from ##ResidentStayPayorsRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go
-------------------------------------------------
-- ##Beds
-------------------------------------------------
IF OBJECT_ID('tempdb..##Beds') IS NOT NULL DROP TABLE ##Beds;
select t.* into ##Beds
from ##BedsRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go
-------------------------------------------------
-- ##ResidentStayBeds
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentStayBeds') IS NOT NULL DROP TABLE ##ResidentStayBeds;
select t.* into ##ResidentStayBeds
from ##ResidentStayBedsRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go
-------------------------------------------------
-- ##ResidentBills
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentBills') IS NOT NULL DROP TABLE ##ResidentBills;
select t.* into ##ResidentBills
from ##ResidentBillsRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go

-------------------------------------------------
-- ##ResidentAncillaryBills
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentAncillaryBills') IS NOT NULL DROP TABLE ##ResidentAncillaryBills;
select t.* into ##ResidentAncillaryBills
from ##ResidentAncillaryBillsRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go
-------------------------------------------------
-- ##ResourceValues
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResourceValues') IS NOT NULL DROP TABLE ##ResourceValues;
select t.* into ##ResourceValues
from ##ResourceValuesRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;


go
-------------------------------------------------
-- ##ResidentPayorCoinsurers
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentPayorCoinsurers') IS NOT NULL DROP TABLE ##ResidentPayorCoinsurers;
select t.* into ##ResidentPayorCoinsurers
from ##ResidentPayorCoinsurersRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go
-------------------------------------------------
-- ##ResidentStayPayorRateCodes
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentStayPayorRateCodes') IS NOT NULL DROP TABLE ##ResidentStayPayorRateCodes;
select t.* into ##ResidentStayPayorRateCodes
from ##ResidentStayPayorRateCodesRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go
-------------------------------------------------
-- ##ResidentPayorAuthorizationNumbers
-------------------------------------------------
IF OBJECT_ID('tempdb..##ResidentPayorAuthorizationNumbers') IS NOT NULL DROP TABLE ##ResidentPayorAuthorizationNumbers;
select t.* into ##ResidentPayorAuthorizationNumbers
from ##ResidentPayorAuthorizationNumbersRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go

-------------------------------------------------
-- ##DistinctUnits
-------------------------------------------------
IF OBJECT_ID('tempdb..##DistinctUnits') IS NOT NULL DROP TABLE ##DistinctUnits;
select t.* into ##DistinctUnits
from ##DistinctUnitsRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go

-------------------------------------------------
-- ##ResidentAncillaryBills
-------------------------------------------------
-- ##Deposits
-------------------------------------------------
IF OBJECT_ID('tempdb..##Deposits') IS NOT NULL DROP TABLE ##Deposits;
select t.* into ##Deposits
from ##DepositsRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go

-------------------------------------------------
-- ##Receipts
-------------------------------------------------
IF OBJECT_ID('tempdb..##Receipts') IS NOT NULL DROP TABLE ##Receipts;
select t.* into ##Receipts
from ##ReceiptsRaw t
join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, '1/1/1980') < latestCycle.Timestamp;

go

-------------------------------------------------
-- ##tblPhysicalEntity
-------------------------------------------------
IF OBJECT_ID('[art].[tblPhysicalEntity]') IS NOT NULL DROP TABLE [art].[tblPhysicalEntity];
select t.*
into [art].[tblPhysicalEntity]
from [ArTrackServer].[xTrack].[dbo].[tblPhysicalEntity] t
join ##Companies c on t.SyncId = c.Id
;

-------------------------------------------------
-- ##tblPayor
-------------------------------------------------
IF OBJECT_ID('[art].[tblPayor]') IS NOT NULL DROP TABLE [art].[tblPayor];
select t.*
into [art].[tblPayor]
from [ArTrackServer].[xTrack].[dbo].[tblPayor] t
join [art].tblPhysicalEntity pe on t.PeId = pe.Id
join ##Companies c on pe.SyncId = c.Id
;

-------------------------------------------------
-- ##tblPerson
-------------------------------------------------
IF OBJECT_ID('[art].[tblPerson]') IS NOT NULL DROP TABLE [art].[tblPerson];
select t.*
into [art].[tblPerson]
from [ArTrackServer].[xTrack].[dbo].[tblPerson] t
join [art].tblPhysicalEntity pe on t.PeId = pe.Id
join ##Companies c on pe.SyncId = c.Id
;

-------------------------------------------------
-- ##tblResident
-------------------------------------------------
IF OBJECT_ID('[art].[tblResident]') IS NOT NULL DROP TABLE [art].[tblResident];
select t.*
into [art].[tblResident]
from [ArTrackServer].[xTrack].[dbo].[tblResident] t
join [art].tblPhysicalEntity pe on t.PeId = pe.Id
join ##Companies c on pe.SyncId = c.Id
;

-------------------------------------------------
-- ##tblStay
-------------------------------------------------
IF OBJECT_ID('[art].[tblStay]') IS NOT NULL DROP TABLE [art].[tblStay];
select mainTable.*
into [art].[tblStay]
from [ArTrackServer].[xTrack].[dbo].[tblStay] mainTable
join [art].tblResident t on t.Id = mainTable.ResId
join [art].tblPhysicalEntity pe on t.PeId = pe.Id
join ##Companies c on pe.SyncId = c.Id
;

-------------------------------------------------
-- ##tblStayPayor
-------------------------------------------------
IF OBJECT_ID('[art].[tblStayPayor]') IS NOT NULL DROP TABLE [art].[tblStayPayor];
select mainTable.*
into [art].[tblStayPayor]
from [ArTrackServer].[xTrack].[dbo].[tblStayPayor] mainTable
join [art].tblStay stay on stay.Id = mainTable.StayId 
join [art].tblResident t on t.Id = stay.ResId
join [art].tblPhysicalEntity pe on t.PeId = pe.Id
join ##Companies c on pe.SyncId = c.Id
;

-------------------------------------------------
-- ##tblNameValue
-------------------------------------------------
IF OBJECT_ID('[art].[tblNameValue]') IS NOT NULL DROP TABLE [art].[tblNameValue];
select t.*
into [art].[tblNameValue]
from [ArTrackServer].[xTrack].[dbo].[tblNameValue] t
;

-------------------------------------------------
-- ##tblFacDistinctUnit
-------------------------------------------------
IF OBJECT_ID('[art].[tblFacDistinctUnit]') IS NOT NULL DROP TABLE [art].[tblFacDistinctUnit];
select t.*
into [art].[tblFacDistinctUnit]
from [ArTrackServer].[xTrack].[dbo].[tblFacDistinctUnit] t
join [art].tblPhysicalEntity pe on t.PeId = pe.Id
join ##Companies c on pe.SyncId = c.Id
;

-------------------------------------------------
-- ##tblAging.Bill
-------------------------------------------------
IF OBJECT_ID('[art].[tblAging.Bill]') IS NOT NULL DROP TABLE [art].[tblAging.Bill];
select mainTable.*
into [art].[tblAging.Bill]
from [ArTrackServer].[xTrack].[dbo].[tblAging.Bill] mainTable
join [art].tblResident t on t.Id = mainTable.ResId
join [art].tblPhysicalEntity pe on t.PeId = pe.Id
join ##Companies c on pe.SyncId = c.Id
;

-------------------------------------------------
-- ##tblAging.Cr
-------------------------------------------------
IF OBJECT_ID('[art].[tblAging.Cr]') IS NOT NULL DROP TABLE [art].[tblAging.Cr];
select mainTable.*
into [art].[tblAging.Cr]
from [ArTrackServer].[xTrack].[dbo].[tblAging.Cr] mainTable
join ##ART_tblResident t on t.Id = mainTable.ResId
join [art].tblPhysicalEntity pe on t.PeId = pe.Id
join ##Companies c on pe.SyncId = c.Id
;

