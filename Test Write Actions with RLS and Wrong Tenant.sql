SET ROWCOUNT 0

-- DECLARE Variables ------------------------------------------------------------
declare @SessionTenant uniqueidentifier = '00000000-0000-0000-0000-000000000001'
declare @AnotherTenant uniqueidentifier = '00000000-0000-0000-0000-000000000002'
declare @NewCustomerId int = 100
declare @NewCustomerName nvarchar(50) = 'New Customer'
declare @NewCustomerEmail nvarchar(50) = 'NewCustomer@tenant.com'

-- SET Session Context with Current Tenant to Work -------------------------------
EXEC sp_set_session_context @key = N'TenantId', @value = @SessionTenant


/* 
Try to INSERT New customer with Tenant different from Session Tenant. 
It fails with following message:
	The attempted operation failed because the target object 'Coffee77.MultiTenantDB.dbo.Customers' has a block predicate that conflicts with this operation. 
    If the operation is performed on a view, the block predicate might be enforced on the underlying table. 
    Modify the operation to target only the rows that are allowed by the block predicate. 
*/

INSERT INTO [dbo].[Customers]([TenantId],[CustomerId],[Name],[Email],[CreatedAt])
VALUES (@AnotherTenant, @NewCustomerId, @NewCustomerName,@NewCustomerEmail, GETDATE())