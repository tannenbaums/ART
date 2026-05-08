CREATE OR ALTER PROCEDURE int.GeneratePreLoadScript
    @IntegrationId INT,
    @Execute bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------
    -- stage the table list
    -------------------------------------------------
    IF OBJECT_ID('tempdb..#Tables') IS NOT NULL DROP TABLE #Tables;

    SELECT 
        it.Id,
        it.SectionId,
        s.Name AS SectionName,
        it.TableSchema,
        it.TableName,
        it.TableFilter
    INTO #Tables
    FROM int.IntegrationTable it
    JOIN int.IntegrationSection s ON it.SectionId = s.Id
    JOIN int.IntegrationDetails d ON it.SectionId = d.SectionId
    WHERE d.IntId = @IntegrationId
    ORDER BY it.Id;

    -------------------------------------------------
    -- setup
    -------------------------------------------------
    DECLARE @MaxId INT = (SELECT MAX(Id) FROM #Tables);
    DECLARE @Id INT = (SELECT MIN(Id) FROM #Tables);

    DECLARE @TablePrefix NVARCHAR(500);
    DECLARE @TableName NVARCHAR(256);
    DECLARE @TableSchema NVARCHAR(256);
    DECLARE @TableFilter NVARCHAR(MAX);
    DECLARE @SectionName NVARCHAR(100);
    DECLARE @RawTableName NVARCHAR(300);

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ExecSQL NVARCHAR(MAX);
    DECLARE @FullScript NVARCHAR(MAX) = N'';
    DECLARE @StartTime DATETIME2(3);
    DECLARE @RowCount INT;
    DECLARE @ElapsedMs INT;
    DECLARE @SafeRowCount INT;
    DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10);

    SELECT @TablePrefix = s.TablePrefix
    FROM int.Integration i
    JOIN int.IntegratedSystem s ON i.SystemId = s.Id
    WHERE i.Id = @IntegrationId;

    IF @TablePrefix IS NULL
    BEGIN
        RAISERROR('IntegrationId not found or has no matching system in int.IntegratedSystem.', 16, 1);
        RETURN;
    END;

    -------------------------------------------------
    -- loop tables - create raw tables
    -------------------------------------------------
    WHILE @Id IS NOT NULL AND @Id <= @MaxId
    BEGIN
        SELECT 
            @SectionName = SectionName,
            @TableSchema = TableSchema,
            @TableName = TableName,
            @TableFilter = TableFilter
        FROM #Tables
        WHERE Id = @Id;

        SET @RawTableName = @TableName + N'Raw';

        SET @SQL =
            N'IF OBJECT_ID(''tempdb..##' + @RawTableName + N''') IS NOT NULL DROP TABLE ##' + @RawTableName + N';' + @CRLF +
            N'select t.* into ##' + @RawTableName + @CRLF +
            N'from ' + @TablePrefix + N'.[' + @TableSchema + N'].[' + @TableName + N'] t' + @CRLF +

            CASE 
                WHEN @SectionName = N'Generic' THEN N''
                ELSE N'join ' + @TablePrefix + N'.[dbo].[Companies] c on t.CompanyId = c.Id' + @CRLF
            END +

            CASE 
                WHEN @TableFilter IS NOT NULL AND LTRIM(RTRIM(@TableFilter)) <> ''
                    THEN N'where ' + @TableFilter
                ELSE N''
            END + N';';

        SET @FullScript = @FullScript +
            N'-------------------------------------------------' + @CRLF +
            N'-- ##' + @RawTableName + @CRLF +
            N'-------------------------------------------------' + @CRLF +
            @SQL + @CRLF + @CRLF;

        IF @Execute = 1
        BEGIN
            RAISERROR('Starting ##%s...', 0, 1, @RawTableName) WITH NOWAIT;
            SET @StartTime = SYSDATETIME();
            SET @RowCount = NULL;

            SET @ExecSQL = @SQL + @CRLF + N'SELECT @RowCountOUT = @@ROWCOUNT;';

            EXEC sp_executesql
                @ExecSQL,
                N'@RowCountOUT INT OUTPUT',
                @RowCountOUT = @RowCount OUTPUT;

            SET @ElapsedMs = DATEDIFF(MILLISECOND, @StartTime, SYSDATETIME());
            SET @SafeRowCount = ISNULL(@RowCount, 0);

            RAISERROR(
                'Finished ##%s in %d ms, %d rows',
                0, 1,
                @RawTableName,
                @ElapsedMs,
                @SafeRowCount
            ) WITH NOWAIT;
        END;

        SELECT @Id = MIN(Id) FROM #Tables WHERE Id > @Id;
    END;

    -------------------------------------------------
    -- create latest full NCS cycle table
    -------------------------------------------------
    SET @SQL =
        N'IF OBJECT_ID(''tempdb..##LatestFullNCSCycle'') IS NOT NULL DROP TABLE ##LatestFullNCSCycle;' + @CRLF +
        N'select max(ResponseTime) Timestamp' + @CRLF +
        N'into ##LatestFullNCSCycle' + @CRLF +
        N'from ' + @TablePrefix + N'.[dbo].[ApiRequestLogs]' + @CRLF +
        N'where Endpoint = ''openMonthDates'';';

    SET @FullScript = @FullScript +
        N'-------------------------------------------------' + @CRLF +
        N'-- ##LatestFullNCSCycle' + @CRLF +
        N'-------------------------------------------------' + @CRLF +
        @SQL + @CRLF + @CRLF;

    IF @Execute = 1
    BEGIN
        RAISERROR('Starting ##LatestFullNCSCycle...', 0, 1) WITH NOWAIT;
        SET @StartTime = SYSDATETIME();
        SET @RowCount = NULL;

        SET @ExecSQL = @SQL + @CRLF + N'SELECT @RowCountOUT = @@ROWCOUNT;';

        EXEC sp_executesql
            @ExecSQL,
            N'@RowCountOUT INT OUTPUT',
            @RowCountOUT = @RowCount OUTPUT;

        SET @ElapsedMs = DATEDIFF(MILLISECOND, @StartTime, SYSDATETIME());
        SET @SafeRowCount = ISNULL(@RowCount, 0);

        RAISERROR(
            'Finished ##LatestFullNCSCycle in %d ms, %d rows',
            0, 1,
            @ElapsedMs,
            @SafeRowCount
        ) WITH NOWAIT;
    END;

    -------------------------------------------------
    -- reset loop
    -------------------------------------------------
    SET @Id = (SELECT MIN(Id) FROM #Tables);

    -------------------------------------------------
    -- loop tables - create non-raw tables from raw tables
    -------------------------------------------------
    WHILE @Id IS NOT NULL AND @Id <= @MaxId
    BEGIN
        SELECT 
            @TableName = TableName
        FROM #Tables
        WHERE Id = @Id;

        SET @RawTableName = @TableName + N'Raw';

        SET @SQL =
            N'IF OBJECT_ID(''tempdb..##' + @TableName + N''') IS NOT NULL DROP TABLE ##' + @TableName + N';' + @CRLF +
            N'select t.* into ##' + @TableName + @CRLF +
            N'from ##' + @RawTableName + N' t' + @CRLF +
            N'join ##LatestFullNCSCycle latestCycle on isnull(t.LastUpdated, ''1/1/1980'') < latestCycle.Timestamp;' ;

        SET @FullScript = @FullScript +
            N'-------------------------------------------------' + @CRLF +
            N'-- ##' + @TableName + @CRLF +
            N'-------------------------------------------------' + @CRLF +
            @SQL + @CRLF + @CRLF;

        IF @Execute = 1
        BEGIN
            RAISERROR('Starting ##%s...', 0, 1, @TableName) WITH NOWAIT;
            SET @StartTime = SYSDATETIME();
            SET @RowCount = NULL;

            SET @ExecSQL = @SQL + @CRLF + N'SELECT @RowCountOUT = @@ROWCOUNT;';

            EXEC sp_executesql
                @ExecSQL,
                N'@RowCountOUT INT OUTPUT',
                @RowCountOUT = @RowCount OUTPUT;

            SET @ElapsedMs = DATEDIFF(MILLISECOND, @StartTime, SYSDATETIME());
            SET @SafeRowCount = ISNULL(@RowCount, 0);

            RAISERROR(
                'Finished ##%s in %d ms, %d rows',
                0, 1,
                @TableName,
                @ElapsedMs,
                @SafeRowCount
            ) WITH NOWAIT;
        END;

        SELECT @Id = MIN(Id) FROM #Tables WHERE Id > @Id;
    END;

    -------------------------------------------------
    -- output full generated script
    -------------------------------------------------
    SELECT @FullScript AS GeneratedScript;
END;
GO