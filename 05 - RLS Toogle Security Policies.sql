------------------------------------------------------------
-- Stored procedure to enable or disable all RLS policies
-- Use this procedure with caution in non-test scenarios ⚠️ 
------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbo.ToggleAllSecurityPolicies
    @Enable BIT -- 1 = ON, 0 = OFF
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @state NVARCHAR(3) = CASE WHEN @Enable = 1 THEN 'ON' ELSE 'OFF' END;
    DECLARE @sql NVARCHAR(MAX) = N'';

    -- Build dynamic SQL for all security policies
    SELECT @sql = @sql + 
        'ALTER SECURITY POLICY ' + QUOTENAME(s.name) + '.' + QUOTENAME(sp.name) + 
        ' WITH (STATE = ' + @state + ');' + CHAR(13)
    FROM sys.security_policies sp
    JOIN sys.schemas s ON sp.schema_id = s.schema_id;

    -- Execute
    EXEC sp_executesql @sql;
END;
GO
