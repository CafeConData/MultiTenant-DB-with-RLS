SET NOCOUNT ON
BEGIN TRAN
BEGIN TRY

	---------------------------------------------------------
	-- Insert Tenants
	---------------------------------------------------------
	INSERT INTO dbo.Tenants (TenantId, Name)
	VALUES
		('00000000-0000-0000-0000-000000000001', 'Coffee & Data'),
		('00000000-0000-0000-0000-000000000002', 'Global Coffee Roasters'),
		('00000000-0000-0000-0000-000000000003', 'Coffee Cool Subscribers');


	---------------------------------------------------------
	-- Capture TenantIds for reuse
	---------------------------------------------------------
	-- Create a table variable to hold tenants
	DECLARE @Tenants TABLE (TenantId UNIQUEIDENTIFIER, RowNum INT);

	INSERT INTO @Tenants (TenantId, RowNum)
	SELECT TenantId, ROW_NUMBER() OVER (ORDER BY Name)
	FROM dbo.Tenants;

	---------------------------------------------------------
	-- Insert Customers (10 per tenant)
	---------------------------------------------------------
	DECLARE @tId UNIQUEIDENTIFIER, @i INT;

	DECLARE tenant_cursor CURSOR FOR SELECT TenantId FROM @Tenants;
	OPEN tenant_cursor;

	FETCH NEXT FROM tenant_cursor INTO @tId;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @i = 1;
		WHILE @i <= 10
		BEGIN
			INSERT INTO dbo.Customers (TenantId, CustomerId, Name, Email)
			VALUES (@tId, @i, CONCAT('Customer ', @i), CONCAT('customer', @i, '@tenant.com'));
			SET @i += 1;
		END
		FETCH NEXT FROM tenant_cursor INTO @tId;
	END
	CLOSE tenant_cursor;
	DEALLOCATE tenant_cursor;


	---------------------------------------------------------
	-- Insert Products (10 per tenant, coffee varieties)
	---------------------------------------------------------
	DECLARE @CoffeeProducts TABLE (Name NVARCHAR(200), Price DECIMAL(10,2));
	INSERT INTO @CoffeeProducts (Name, Price)
	VALUES
	 ('Espresso', 2.50),
	 ('Cappuccino', 3.20),
	 ('Latte', 3.50),
	 ('Americano', 2.00),
	 ('Flat White', 3.40),
	 ('Macchiato', 2.80),
	 ('Mocha', 3.80),
	 ('Turkish Coffee', 2.90),
	 ('Café au Lait', 3.10),
	 ('Cold Brew', 3.60);

	DECLARE tenant_cursor CURSOR FOR SELECT TenantId FROM @Tenants;
	OPEN tenant_cursor;

	FETCH NEXT FROM tenant_cursor INTO @tId;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @i = 1;
		INSERT INTO dbo.Products (TenantId, ProductId, Name, UnitPrice)
		SELECT @tId, ROW_NUMBER() OVER (ORDER BY Name), Name, Price
		FROM @CoffeeProducts;

		FETCH NEXT FROM tenant_cursor INTO @tId;
	END
	CLOSE tenant_cursor;
	DEALLOCATE tenant_cursor;


	---------------------------------------------------------
	-- Insert Orders + OrderDetails
	---------------------------------------------------------
	DECLARE @statuses TABLE (Status NVARCHAR(50));
	INSERT INTO @statuses VALUES ('Pending'), ('Shipped'), ('Completed'), ('Cancelled');

	DECLARE @status NVARCHAR(50);

	DECLARE tenant_cursor CURSOR FOR SELECT TenantId FROM @Tenants;
	OPEN tenant_cursor;

	FETCH NEXT FROM tenant_cursor INTO @tId;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- each customer places 10 orders
		DECLARE @cId INT = 1;
		WHILE @cId <= 10
		BEGIN
			DECLARE @order INT = 1;
			WHILE @order <= 10
			BEGIN
				-- pick random status
				SELECT TOP 1 @status = Status FROM @statuses ORDER BY NEWID();

				-- insert order
				INSERT INTO dbo.Orders (TenantId, OrderId, CustomerId, OrderDate, Status)
				VALUES (@tId, ((@cId-1)*10)+@order, @cId, DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % (365 + DATENAME(dayofyear , GetDate())), GETDATE()), @status);

				-- insert 2 products per order
				INSERT INTO dbo.OrderDetails (TenantId, OrderId, ProductId, Quantity, UnitPrice)
				SELECT TOP 2 @tId, ((@cId-1)*10)+@order, ProductId, (ABS(CHECKSUM(NEWID())) % 5) + 1, UnitPrice
				FROM dbo.Products WHERE TenantId = @tId ORDER BY NEWID();

				SET @order += 1;
			END
			SET @cId += 1;
		END

		FETCH NEXT FROM tenant_cursor INTO @tId;
	END
	CLOSE tenant_cursor;
	DEALLOCATE tenant_cursor;

	COMMIT TRAN
	PRINT ('Success - Commit Transaction')
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrorNumber, 
		ERROR_SEVERITY() AS ErrorSeverity, 
		ERROR_STATE() AS ErrorState, 
		ERROR_PROCEDURE() AS ErrorProcedure, 
		ERROR_LINE() AS ErrorLine, 
		ERROR_MESSAGE() AS ErrorMessage;
	ROLLBACK TRAN
	PRINT ('Error - Rollback Transaction')
END CATCH