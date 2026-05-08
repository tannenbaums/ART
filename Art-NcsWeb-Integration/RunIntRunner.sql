USE [DsReplica]
GO

DECLARE @RC int
DECLARE @PrintOnly bit
DECLARE @IntegrationLinkedServer nvarchar(128)
DECLARE @LiveLinkedServer nvarchar(128)
DECLARE @IntegrationDb nvarchar(128)
DECLARE @LiveDb nvarchar(128)

-- TODO: Set parameter values here.

EXECUTE @RC = [int].[IntRunner] 1
   @PrintOnly =1
  ,@IntegrationLinkedServer
  ,@LiveLinkedServer
  ,@IntegrationDb
  ,@LiveDb
GO


exec [int].[GeneratePreLoadScript] 2, 0, 1




