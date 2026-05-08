CREATE OR ALTER PROCEDURE int.IntRunner
    @PrintOnly bit = 0
AS
BEGIN
    -- Art Integration runner 

    SET NOCOUNT ON;

    DECLARE @Id INT;
    DECLARE @ArTable NVARCHAR(128);
    DECLARE @SourceGenQuery NVARCHAR(MAX);
    DECLARE @TargetGenQuery NVARCHAR(MAX);

    DECLARE @i INT = 1;
    DECLARE @max INT;

    DECLARE @MergeExec NVARCHAR(MAX);
    DECLARE @MergeStatement NVARCHAR(MAX);
    DECLARE @FullScript NVARCHAR(MAX) = N'';
    DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10);

    IF OBJECT_ID('tempdb..#IntegrationRows') IS NOT NULL
        DROP TABLE #IntegrationRows;

    SELECT
        ROW_NUMBER() OVER (ORDER BY Id) AS RowNum,
        Id,
        ArtTable,
        SourceGenQuery,
        ArtGenQuery
    INTO #IntegrationRows
    FROM int.ArtTable
    WHERE ISNULL(ArtTable, '') <> ''
    AND ArtGenQuery IS NOT NULL;

    SELECT @max = COUNT(*)
    FROM #IntegrationRows;

    -------------------------------------------------
    -- HEADER (converted from PRINT)
    -------------------------------------------------
    SET @FullScript = @FullScript +
        N'--============================================' + @CRLF +
        N'--Starting integration generator' + @CRLF +
        N'--Total rows: ' + CAST(ISNULL(@max, 0) AS NVARCHAR(20)) + @CRLF +
        N'--Print only: ' + CAST(@PrintOnly AS NVARCHAR(1)) + @CRLF +
        N'--============================================' + @CRLF;

    WHILE @i <= @max
    BEGIN
        SELECT
            @Id = Id,
            @ArTable = ArtTable,
            @SourceGenQuery = SourceGenQuery,
            @TargetGenQuery = ArtGenQuery
        FROM #IntegrationRows
        WHERE RowNum = @i;

        -------------------------------------------------
        -- ROW HEADER (converted from PRINT)
        -------------------------------------------------
        SET @FullScript = @FullScript +
            @CRLF +
            N'--------------------------------------------' + @CRLF +
            N'--Processing row ' + CAST(@i AS NVARCHAR(20)) + N' of ' + CAST(@max AS NVARCHAR(20)) + @CRLF +
            N'--Id: ' + CAST(@Id AS NVARCHAR(20)) + @CRLF +
            N'--Table: ' + ISNULL(@ArTable, N'(null)') + @CRLF +
            N'--------------------------------------------' + @CRLF;

        BEGIN TRY

            -------------------------------------------------
            -- Clean up
            -------------------------------------------------
            SET @MergeExec = '
IF OBJECT_ID(''[source].[' + @ArTable + ']'', ''U'') IS NOT NULL
    DROP TABLE [source].[' + @ArTable + '];

IF OBJECT_ID(''[target].[' + @ArTable + ']'', ''U'') IS NOT NULL
    DROP TABLE [target].[' + @ArTable + '];';

            SET @MergeStatement =
N'EXEC dbo.GenerateMergeStatement
    @SourceSchema = ''source'',
    @SourceTable = ''' + @ArTable + N''',
    @TargetSchema = ''target'',
    @TargetTable = ''' + @ArTable + N''',
    @PrimaryKeyColumns = ''Id'',
    @SoftDeleteNotMatchedBySource = 1,
    @DeletedColumn = ''Deleted'';';

            -------------------------------------------------
            -- MAIN BODY (converted prints preserved EXACTLY)
            -------------------------------------------------
            SET @FullScript = @FullScript +
                @MergeExec + @CRLF + @CRLF +

                N'--Running SourceGenQuery for ' + @ArTable + @CRLF +
                @SourceGenQuery + @CRLF + @CRLF +

                N'--Running TargetGenQuery for ' + @ArTable + @CRLF +
                @TargetGenQuery + @CRLF + @CRLF +

                N'--Running GenerateMergeStatement for ' + @ArTable + @CRLF +
                @MergeStatement + @CRLF + @CRLF;

            -------------------------------------------------
            -- EXECUTION (unchanged)
            -------------------------------------------------
            IF @PrintOnly = 0
                EXEC sp_executesql @MergeExec;

            IF @PrintOnly = 0
                EXEC sp_executesql @SourceGenQuery;

            IF @PrintOnly = 0
                EXEC sp_executesql @TargetGenQuery;

            IF @PrintOnly = 0
            BEGIN
                EXEC dbo.GenerateMergeStatement
                    @SourceSchema = 'source',
                    @SourceTable = @ArTable,
                    @TargetSchema = 'target',
                    @TargetTable = @ArTable,
                    @PrimaryKeyColumns = 'Id',
                    @SoftDeleteNotMatchedBySource = 1,
                    @DeletedColumn = 'Deleted';
            END

            -------------------------------------------------
            -- COMPLETED (converted from PRINT)
            -------------------------------------------------
            SET @FullScript = @FullScript +
                N'--Completed: ' + @ArTable + @CRLF;

        END TRY
        BEGIN CATCH
            SET @FullScript = @FullScript +
                N'ERROR on table: ' + ISNULL(@ArTable, N'(null)') + @CRLF +
                ERROR_MESSAGE() + @CRLF;
        END CATCH;

        SET @i = @i + 1;
    END

    -------------------------------------------------
    -- FOOTER (converted from PRINT)
    -------------------------------------------------
    SET @FullScript = @FullScript +
        @CRLF +
        N'============================================' + @CRLF +
        N'Integration generator complete' + @CRLF +
        N'============================================';

    SELECT @FullScript AS RunnableScript;
END;
GO