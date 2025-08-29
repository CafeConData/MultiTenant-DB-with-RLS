
---------------------------------------------------------
-- Drop all Row-Level Security policies if they exist
---------------------------------------------------------
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql + 
    'DROP SECURITY POLICY ' + QUOTENAME(s.name) + '.' + QUOTENAME(sp.name) + ';' + CHAR(13)
FROM sys.security_policies sp
JOIN sys.schemas s ON sp.schema_id = s.schema_id;

IF LEN(@sql) > 0
    EXEC sp_executesql @sql;
ELSE
    PRINT 'No security policies found.';
GO


---------------------------------------------------------
-- Drop tables if they exist (clean start)
---------------------------------------------------------
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Tenants', 'U') IS NOT NULL DROP TABLE dbo.Tenants;
GO

---------------------------------------------------------
-- Tenants
---------------------------------------------------------
CREATE TABLE dbo.Tenants (
    TenantId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    Name NVARCHAR(200) NOT NULL,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Tenants PRIMARY KEY (TenantId)
);
GO

---------------------------------------------------------
-- Customers
---------------------------------------------------------
CREATE TABLE dbo.Customers (
    TenantId UNIQUEIDENTIFIER NOT NULL,
    CustomerId INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Email NVARCHAR(200) NOT NULL,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Customers PRIMARY KEY (TenantId, CustomerId),
    CONSTRAINT FK_Customers_Tenants FOREIGN KEY (TenantId)
        REFERENCES dbo.Tenants (TenantId) 
);
GO

---------------------------------------------------------
-- Products
---------------------------------------------------------
CREATE TABLE dbo.Products (
    TenantId UNIQUEIDENTIFIER NOT NULL,
    ProductId INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Products PRIMARY KEY (TenantId, ProductId),
    CONSTRAINT FK_Products_Tenants FOREIGN KEY (TenantId)
        REFERENCES dbo.Tenants (TenantId) 
);
GO

---------------------------------------------------------
-- Orders
---------------------------------------------------------
CREATE TABLE dbo.Orders (
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrderId INT NOT NULL,
    CustomerId INT NOT NULL,
    OrderDate DATE NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Orders PRIMARY KEY (TenantId, OrderId),
    CONSTRAINT FK_Orders_Tenants FOREIGN KEY (TenantId)
        REFERENCES dbo.Tenants (TenantId), 
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (TenantId, CustomerId)
        REFERENCES dbo.Customers (TenantId, CustomerId) 
);
GO

---------------------------------------------------------
-- OrderDetails
---------------------------------------------------------
CREATE TABLE dbo.OrderDetails (
    TenantId UNIQUEIDENTIFIER NOT NULL,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_OrderDetails PRIMARY KEY (TenantId, OrderId, ProductId),
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (TenantId, OrderId)
        REFERENCES dbo.Orders (TenantId, OrderId), 
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (TenantId, ProductId)
        REFERENCES dbo.Products (TenantId, ProductId) 
);
GO
