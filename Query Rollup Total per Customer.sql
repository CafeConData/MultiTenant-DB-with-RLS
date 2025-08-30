---------------------------------------------------------
--	Roll-up: Total per Customer
---------------------------------------------------------

---------------------------------------------------------
-- With Row Level Security (RLS) Enabled by default
-- If Disabled all tenants will be retrieved unless filtering by TenantId explicitly.
---------------------------------------------------------

exec dbo.ToggleAllSecurityPolicies 1  -- Set 0 to disable RLS. Use with caution ⚠️ in non-test scenarios.
EXEC sp_set_session_context @key = N'TenantId', @value = '00000000-0000-0000-0000-000000000001'; -- Set TenantId in session
DECLARE @CustomerId INT = NULL; -- set to NULL to retieve all customers

SELECT 
    c.TenantId,
    c.CustomerId,
    c.Name AS CustomerName,
    SUM(od.Quantity * od.UnitPrice) AS CustomerTotal
FROM dbo.Customers c
INNER JOIN dbo.Orders o
    ON c.TenantId = o.TenantId
   AND c.CustomerId = o.CustomerId
INNER JOIN dbo.OrderDetails od
    ON o.TenantId = od.TenantId
   AND o.OrderId = od.OrderId
WHERE (@CustomerId IS NULL OR c.CustomerId = @CustomerId)
GROUP BY c.TenantId, c.CustomerId, c.Name
ORDER BY CustomerTotal DESC;
