/*
🛠 What a Tenant Policy Script Does

- The tenant policies script is used to enforce multi-tenant isolation in SQL Server. It ensures that:
	- A tenant can only see its own rows in tables (Customers, Orders, etc.).
	- A tenant cannot insert, update, or delete rows belonging to another tenant.
	- This is done using Row-Level Security (RLS) with filter predicates and block predicates.

🛠 What Predicates Are

- FILTER PREDICATE = applies to SELECT queries. 
	- Only rows where TenantId = session TenantId are returned.

- BLOCK PREDICATE = prevents data modification across tenants.
	- Insert: Tenant cannot insert a row with TenantId different from their session.
	- Update/Delete: Tenant cannot modify or delete rows that belong to another tenant.
*/

-- Customers table
IF EXISTS(select * FROM sys.security_policies WHERE name = 'TenantsPolicy')
	DROP SECURITY POLICY dbo.TenantsPolicy
CREATE SECURITY POLICY dbo.TenantsPolicy
ADD FILTER PREDICATE dbo.fnTenantPredicate(TenantId)
ON dbo.Tenants,
ADD BLOCK PREDICATE dbo.fnTenantPredicate(TenantId) 
ON dbo.Tenants
WITH (STATE = ON);
GO

-- Customers table
IF EXISTS(select * FROM sys.security_policies WHERE name = 'TenantCustomersPolicy')
	DROP SECURITY POLICY dbo.TenantCustomersPolicy
CREATE SECURITY POLICY dbo.TenantCustomersPolicy
ADD FILTER PREDICATE dbo.fnTenantPredicate(TenantId)
ON dbo.Customers,
ADD BLOCK PREDICATE dbo.fnTenantPredicate(TenantId) 
ON dbo.Customers
WITH (STATE = ON);
GO

-- Products table
IF EXISTS(select * FROM sys.security_policies WHERE name = 'TenantProductsPolicy')
	DROP SECURITY POLICY dbo.TenantProductsPolicy
CREATE SECURITY POLICY dbo.TenantProductsPolicy
ADD FILTER PREDICATE dbo.fnTenantPredicate(TenantId) 
ON dbo.Products,
ADD BLOCK PREDICATE dbo.fnTenantPredicate(TenantId) 
ON dbo.Products
WITH (STATE = ON);
GO

-- Orders table
IF EXISTS(select * FROM sys.security_policies WHERE name = 'TenantOrdersPolicy')
	DROP SECURITY POLICY dbo.TenantOrdersPolicy
CREATE SECURITY POLICY dbo.TenantOrdersPolicy
ADD FILTER PREDICATE dbo.fnTenantPredicate(TenantId)
ON dbo.Orders,
ADD BLOCK PREDICATE dbo.fnTenantPredicate(TenantId) 
ON dbo.Orders
WITH (STATE = ON);
GO

-- OrderDetails table
IF EXISTS(select * FROM sys.security_policies WHERE name = 'TenantOrderDetailsPolicy')
	DROP SECURITY POLICY dbo.TenantOrderDetailsPolicy
CREATE SECURITY POLICY dbo.TenantOrderDetailsPolicy
ADD FILTER PREDICATE dbo.fnTenantPredicate(TenantId)
ON dbo.OrderDetails,
ADD BLOCK PREDICATE dbo.fnTenantPredicate(TenantId) 
ON dbo.OrderDetails
WITH (STATE = ON);
GO

/*
ALTER SECURITY POLICY dbo.TenantCustomersPolicy WITH (STATE = OFF);
ALTER SECURITY POLICY dbo.TenantProductsPolicy WITH (STATE = OFF);
ALTER SECURITY POLICY dbo.TenantOrdersPolicy WITH (STATE = OFF);
ALTER SECURITY POLICY dbo.TenantOrderDetailsPolicy WITH (STATE = OFF);
GO
*/

