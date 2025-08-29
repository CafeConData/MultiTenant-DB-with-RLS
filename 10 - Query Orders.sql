---------------------------------------------------------
--	Sample query to retrieve order details with customers and products
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
    o.[Status],
    c.CustomerId,
    c.Name AS CustomerName,
    c.Email AS CustomerEmail,
    od.ProductId,
    p.Name AS ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice) AS LineTotal
FROM dbo.Orders o
INNER JOIN dbo.Customers c
    ON o.TenantId = c.TenantId
   AND o.CustomerId = c.CustomerId
INNER JOIN dbo.OrderDetails od
    ON o.TenantId = od.TenantId
   AND o.OrderId = od.OrderId
INNER JOIN dbo.Products p
    ON od.TenantId = p.TenantId
   AND od.ProductId = p.ProductId
WHERE (@CustomerId IS NULL OR o.CustomerId = @CustomerId)
ORDER BY o.OrderDate DESC, o.OrderId, p.Name;
