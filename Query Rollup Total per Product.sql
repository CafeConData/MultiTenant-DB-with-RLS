---------------------------------------------------------
-- Roll-up: Total per Product
---------------------------------------------------------

---------------------------------------------------------
-- With Row Level Security (RLS) Enabled by default
-- If Disabled all tenants will be retrieved unless filtering by TenantId explicitly.
---------------------------------------------------------

exec dbo.ToggleAllSecurityPolicies 1  -- Set 0 to disable RLS. Use with caution ⚠️ in non-test scenarios.
EXEC sp_set_session_context @key = N'TenantId', @value = '00000000-0000-0000-0000-000000000001'; -- Set TenantId in session
DECLARE @CustomerId INT = NULL; -- set to NULL to retieve all customers

SELECT 
    p.TenantId,
    p.ProductId,
    p.Name AS ProductName,
    SUM(od.Quantity) AS TotalQuantitySold,
    SUM(od.Quantity * od.UnitPrice) AS ProductTotal
FROM dbo.Products p
INNER JOIN dbo.OrderDetails od
    ON p.TenantId = od.TenantId
   AND p.ProductId = od.ProductId
INNER JOIN dbo.Orders o
    ON od.TenantId = o.TenantId
   AND od.OrderId = o.OrderId
WHERE (@CustomerId IS NULL OR o.CustomerId = @CustomerId)
GROUP BY p.TenantId, p.ProductId, p.Name
ORDER BY TotalQuantitySold DESC;