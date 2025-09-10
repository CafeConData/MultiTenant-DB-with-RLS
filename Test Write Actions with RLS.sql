SET ROWCOUNT 0

-- DECLARE Variables ------------------------------------------------------------
declare @SessionTenant uniqueidentifier = '00000000-0000-0000-0000-000000000001'
declare @NewCustomerId int = 100
declare @NewCustomerName nvarchar(50) = 'New Customer'
declare @NewCustomerEmail nvarchar(50) = 'NewCustomer@tenant.com'

-- SET Session Context with Current Tenant to Work -------------------------------
EXEC sp_set_session_context @key = N'TenantId', @value = @SessionTenant
SELECT * FROM Customers -- Query to get initial customers

-- INSERT New customer ------------------------------------------------------------
INSERT INTO [dbo].[Customers]([TenantId],[CustomerId],[Name],[Email],[CreatedAt])
VALUES (@SessionTenant, @NewCustomerId, @NewCustomerName,@NewCustomerEmail, GETDATE())

-- Query to check new customer is inserted. 
-- Notice there is no TenantId field in WHERE clause. 
-- TenantId is retrieved from Session Context and injected in WHERE clause in actual Execution Plan.
select * from Customers
WHERE CustomerId = @NewCustomerId 

-- UPDATE New Customer ------------------------------------------------------------
-- Notice there is no TenantId field in WHERE clause. 
-- TenantId is retrieved from Session Context and injected in WHERE clause in actual Execution Plan.
UPDATE Customers SET Name = @NewCustomerName + ' Updated'
WHERE CustomerId = @NewCustomerId
select * from Customers
WHERE CustomerId = @NewCustomerId -- Query to check new customer is updated

-- DELETE New Customer ------------------------------------------------------------
-- Notice there is no TenantId field in WHERE clause. 
-- TenantId is retrieved from Session Context and injected in WHERE clause in actual Execution Plan.
DELETE FROM Customers 
WHERE CustomerId = @NewCustomerId
select * from Customers
WHERE CustomerId = @NewCustomerId -- Query to check new customer is deleted


GO


