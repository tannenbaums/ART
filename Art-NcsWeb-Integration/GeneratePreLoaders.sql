--preloader with the new joins - seems to be taking way too long

DECLARE @SystemName NVARCHAR(100) = 'NCS-Web';
DECLARE @SQL NVARCHAR(MAX) = '';
DECLARE @CRLF NVARCHAR(10) = CHAR(13) + CHAR(10);
DECLARE @TablePrefix NVARCHAR(500);
DECLARE @LatestTimestampQuery NVARCHAR(MAX);

SELECT 
    @TablePrefix = TablePrefix,
    @LatestTimestampQuery = LatestTimestampQuery
FROM int.ExternalSystem
WHERE SystemName = @SystemName;

IF @TablePrefix IS NULL
BEGIN
    RAISERROR('SystemName not found in int.ExternalSystem.', 16, 1);
    RETURN;
END;

-------------------------------------------------
-- preload latest fully completed cycle timestamp
-------------------------------------------------
IF @LatestTimestampQuery IS NOT NULL AND LTRIM(RTRIM(@LatestTimestampQuery)) <> ''
BEGIN
    SET @SQL = @SQL +  'IF OBJECT_ID(''tempdb..##LatestFullNCSCycle'') IS NOT NULL DROP TABLE ##LatestFullNCSCycle;' + @CRLF +
    @LatestTimestampQuery + @CRLF 
END;

-------------------------------------------------
-- preload source tables
-------------------------------------------------
SELECT @SQL = @SQL + 
'IF OBJECT_ID(''tempdb..##' + etp.TableName + ''') IS NOT NULL DROP TABLE ##' + etp.TableName + ';' + @CRLF +
'select *' + @CRLF +
'into ##' + etp.TableName + @CRLF +
'from ' + @TablePrefix + '.[' + etp.TableSchema + '].[' + etp.TableName + '] t' + @CRLF +

CASE 
    WHEN @LatestTimestampQuery IS NOT NULL AND LTRIM(RTRIM(@LatestTimestampQuery)) <> ''
        THEN 'join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, ''1/1/1980'') < latestCycle.Timestamp' + @CRLF
    ELSE ''
END +

CASE 
    WHEN etp.TableFilter IS NOT NULL AND LTRIM(RTRIM(etp.TableFilter)) <> ''
        THEN 'where ' + etp.TableFilter + @CRLF
    ELSE ''
END 
--+

--@CRLF
FROM int.ExternalTablesPreLoader etp
ORDER BY etp.Id;

-------------------------------------------------
-- OUTPUT
-------------------------------------------------
PRINT @SQL;

-------------------------------------------------
-- EXECUTION OPTION (copy if needed)
-------------------------------------------------
EXEC sp_executesql @SQL;