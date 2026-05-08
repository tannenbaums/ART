USE [DsReplica]
GO

DECLARE @RC int
DECLARE @IntegrationId int =1
DECLARE @Execute bit =0
declare @FilterByARTrackEnabled bit = 1


-- TODO: Set parameter values here.

EXECUTE @RC = [int].[GeneratePreLoadScript] 
   @IntegrationId
  ,@Execute
  ,@FilterByARTrackEnabled
GO

int.IntRunner @PrintOnly = 1
