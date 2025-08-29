/*
🛠 What it is

- Table-valued function that SQL Server uses as a predicate (a condition) inside a Row-Level Security (RLS) policy.
- It decides whether a row should be visible to the current user/session based on TenantId.

🔎 How it works step by step

- When attached to a table, SQL Server automatically supplies the value of the row’s TenantId column into @TenantId.
- The function returns a row (SELECT 1) only if the row’s TenantId matches the session’s TenantId.
	- Inside the function, we check the session variable: SESSION_CONTEXT(N'TenantId')
	- This is the TenantId value you set at login/session level using: EXEC sp_set_session_context @key = N'TenantId', @value = '8A1D4F3E-...';
- If they don’t match → it returns nothing → that row is filtered out.

📝 Key points

- The function is not called manually; SQL Server runs it behind the scenes for every row in queries, inserts, updates, deletes.
- It’s the “gatekeeper”: only lets rows through where row.TenantId = session.TenantId.
- Makes multi-tenant isolation automatic and centralized, no need to add WHERE TenantId = ... in every query.

*/
CREATE OR ALTER FUNCTION dbo.fnTenantPredicate(@TenantId uniqueidentifier)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_result
    WHERE @TenantId = CAST(SESSION_CONTEXT(N'TenantId') AS uniqueidentifier);
