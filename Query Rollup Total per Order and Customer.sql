---------------------------------------------------------
--	Roll-up: Total per Order and Customer
---------------------------------------------------------

---------------------------------------------------------
-- With Row Level Security (RLS) Enabled by default
-- If Disabled all tenants will be retrieved unless filtering by TenantId explicitly.
---------------------------------------------------------

exec dbo.ToggleAllSecurityPolicies 1  -- Set 0 to disable RLS. Use with caution ⚠️ in non-test scenarios.
EXEC sp_set_session_context @key = N'TenantId', @value = '00000000-0000-0000-0000-000000000001'; -- Set TenantId in session
DECLARE @CustomerId INT = NULL; -- set to NULL to retieve all customers

SELECT 
    o.TenantId,
    o.OrderId,
    o.OrderDate,
    o.Status,
    c.CustomerId,
    c.Name AS CustomerName,
    SUM(od.Quantity * od.UnitPrice) AS OrderTotal
FROM dbo.Orders o
INNER JOIN dbo.Customers c
    ON o.TenantId = c.TenantId
   AND o.CustomerId = c.CustomerId
INNER JOIN dbo.OrderDetails od
    ON o.TenantId = od.TenantId
   AND o.OrderId = od.OrderId
WHERE (@CustomerId IS NULL OR o.CustomerId = @CustomerId)
GROUP BY 
    o.TenantId, o.OrderId, o.OrderDate, o.Status,
    c.CustomerId, c.Name
ORDER BY o.OrderDate DESC, o.OrderId;
