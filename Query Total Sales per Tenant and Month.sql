---------------------------------------------------------
--	Total sales per tenant, by month and year
---------------------------------------------------------

---------------------------------------------------------
-- With Row Level Security (RLS) Disabled by default in order to get all tenants
---------------------------------------------------------

exec dbo.ToggleAllSecurityPolicies 0  -- Disable RLS to get all tenants. Use with caution ⚠️ in non-test scenarios.
GO

SELECT 
    o.TenantId,
    YEAR(o.OrderDate) AS SalesYear,
    MONTH(o.OrderDate) AS SalesMonth,
    SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM dbo.Orders o
INNER JOIN dbo.OrderDetails od
    ON o.TenantId = od.TenantId
   AND o.OrderId = od.OrderId
GROUP BY o.TenantId, YEAR(o.OrderDate), MONTH(o.OrderDate)
ORDER BY o.TenantId, SalesYear, SalesMonth;
GO

exec dbo.ToggleAllSecurityPolicies 1 -- Enable RLS again
GO