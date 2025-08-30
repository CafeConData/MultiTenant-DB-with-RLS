---------------------------------------------------------
--	Year-over-year comparison by tenant and month excluding nulls
---------------------------------------------------------

---------------------------------------------------------
-- With Row Level Security (RLS) Enabled by default
-- If Disabled all tenants will be retrieved unless filtering by TenantId explicitly.
---------------------------------------------------------

exec dbo.ToggleAllSecurityPolicies 1  -- Set 0 to disable RLS. Use with caution ⚠️ in non-test scenarios.
EXEC sp_set_session_context @key = N'TenantId', @value = '00000000-0000-0000-0000-000000000001'; -- Set TenantId in session

;WITH MonthlySales AS (
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
)
SELECT 
    cur.TenantId,
    cur.SalesYear,
    cur.SalesMonth,
    cur.TotalSales AS CurrentYearSales,
    prev.TotalSales AS PrevYearSales,
    (cur.TotalSales - prev.TotalSales) AS SalesDelta,
    CASE 
        WHEN cur.TotalSales > prev.TotalSales THEN 'Increase'
        WHEN cur.TotalSales < prev.TotalSales THEN 'Decrease'
        ELSE 'No Change'
    END AS Trend,
    ROUND( ( (cur.TotalSales - prev.TotalSales) * 100.0 / prev.TotalSales ), 2) AS PercentChange
FROM MonthlySales cur
INNER JOIN MonthlySales prev
    ON cur.TenantId = prev.TenantId
   AND cur.SalesMonth = prev.SalesMonth
   AND cur.SalesYear = prev.SalesYear + 1
ORDER BY cur.TenantId, cur.SalesYear, cur.SalesMonth;
