--bill part 2

IF OBJECT_ID('[source].[tblAging.Bill]', 'U') IS NOT NULL
    DROP TABLE [source].[tblAging.Bill];

IF OBJECT_ID('[target].[tblAging.Bill]', 'U') IS NOT NULL
    DROP TABLE [target].[tblAging.Bill];

--Running SourceGenQuery for tblFacDistinctUnit
select du.Id SyncId, du.Code Name, c.Id PeId, du.Deleted
into [source].[tblAging.Bill]
from ##DistinctUnits du
join ##Companies c on du.CompanyId = c.Id

--Running TargetGenQuery for tblFacDistinctUnit
select du.SyncId, duNV.Name, pe.SyncId PeId
, case when statusNv.Name = 'Deleted' then 1 else 0 end Deleted
into [target].[tblFacDistinctUnit]
from ArTrackServer.xTrack.dbo.tblFacDistinctUnit du
join ArTrackServer.xTrack.dbo.tblPhysicalEntity pe on pe.Id = du.PeId
join ArTrackServer.xTrack.dbo.tblNameValue duNV on du.DuNvId = duNV.Id
join ArTrackServer.xTrack.dbo.tblNameValue statusNv on du.StateId = statusNv.Id
join [target].tblPhysicalEntity peInt on pe.SyncId = peInt.SyncId

--Running local GenerateMergeStatement for tblFacDistinctUnit
EXEC dbo.GenerateMergeStatement
    @SourceSchema = 'source',
    @SourceTable = '[tblAging.Bill]',
    @TargetSchema = 'target',
    @TargetTable = '[tblAging.Bill]',
    @PrimaryKeyColumns = 'SyncId',
    @SoftDeleteNotMatchedBySource = 1,
    @DeletedColumn = 'Deleted';

--Copying delta to live and running live GenerateMergeStatement for tblFacDistinctUnit
IF EXISTS(SELECT 1 FROM [target].[tblFacDistinctUnit] WHERE IntegrationAction IS NOT NULL)
BEGIN
    EXEC [ArTrackServer].master.dbo.sp_executesql N'
IF OBJECT_ID(''[xtrack].[source].[tblFacDistinctUnit]'', ''U'') IS NOT NULL
    DROP TABLE [xtrack].[source].[tblFacDistinctUnit];

SELECT mainTable.SyncId , duNV.Id DuNvId, Deleted, case when Deleted = 0 then 1097 else 1098 end StateId

INTO [xtrack].[source].[tblFacDistinctUnit]
FROM [ArTrackSyncServer].[DsReplica].[target].[tblFacDistinctUnit] mainTable
join [xtrack].[dbo].[tblPhysicalEntity] pe on mainTable.PeId = pe.SyncId
join xTrack.dbo.tblNameValue duNv on mainTable.Name = duNv.Name

WHERE mainTable.IntegrationAction IS NOT NULL;

EXEC [xtrack].dbo.GenerateMergeStatement
    @SourceSchema = ''source'',
    @SourceTable = ''tblFacDistinctUnit'',
    @TargetSchema = ''dbo'',
    @TargetTable = ''tblFacDistinctUnit'',
    @PrimaryKeyColumns = ''SyncId'',
    @DeltaMode = 1;';
END
ELSE
BEGIN
    PRINT 'No changes for tblFacDistinctUnit, skipping merge to live.'
END

--Completed: tblFacDistinctUnit