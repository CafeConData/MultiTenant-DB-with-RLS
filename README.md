# MultiTenant-DB-with-RLS

👉 This repository contains basic script to create a **Multitenancy Database with Row Level Security (RLS)** over SQL Server

# Setup Tables and Seed Data

👉 Run the following scripts in this order over an existing SQL Server Database:

- **"01 - Drop and Create Tables.sql"**
    - Creates tables if not already present

- **"02 - Seed Tables.sql"**
    - Seed demo data for 3 tenants

As from here you can query tables as usual in other databases. Notice all tables contains a "TenantId" field with type uniqueidentifier as first field in composed primary key.

# Setup Row Level Security

👉 Run the following scripts in same SQL Server database:

- **"03 - RLS Tenant Predicate Function.sql"**
    - Table-valued function that SQL Server uses as a predicate (a condition) inside a Row-Level Security (RLS) policy.
    - It decides whether a row should be visible to the current user/session based on TenantId.

- **"04 - RLS Security Policies.sql"**
    - The tenant policies script is used to enforce multi-tenant isolation in SQL Server.
	- A tenant can only see its own rows in tables (Customers, Orders, etc.).
	- A tenant cannot insert, update, or delete rows belonging to another tenant.
	- This is done using Row-Level Security (RLS) with filter predicates and block predicates.

- **"05 - RLS Toogle Security Policies.sql"**
    - Stored procedure to enable or disable all RLS policies as an Optional Helper Tool.
    - Use this procedure with caution in non-test scenarios ⚠️ 

# Row Level Security Benefits

✅ Guarantees great solid tenant isolation across all CRUD operations.

✅ Centralized: security enforced at database levelm behaving equal irrespective of callers.

✅ No need to manually add WHERE TenantId = ... in queries.

✅ Works seamlessly with GUID-based TenantId and multi-tenant SaaS apps.

# Sample Queries

👉 Rest of files are provided as sample files.

👉 Queries are executed with Row Level Security enabled by default. Disable Row Level Security to display rows for all tenants if needed.

⚠️ Take special care to not disable Row Level Security policies in PROD scenarios if used🔥

# Scripts to Test Write Actions

👉 Added "Test Write Actions with RLS.sql" to test INSERT, UPDATE and DELETE actions with RLS enabled

👉 Added "Test Write Actions with RLS and Wrong Tenant.sql" to test INSERT with Tenant in Session Context different from Tenant to Insert. As expected, it fails due to BLOCK Security Policy.



