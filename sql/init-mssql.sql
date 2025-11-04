USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TestDB')
BEGIN
    CREATE DATABASE TestDB;
END
GO

USE TestDB;
GO

EXEC sys.sp_cdc_enable_db;
GO

IF OBJECT_ID('dbo.Audit', 'U') IS NOT NULL
    DROP TABLE dbo.Audit;
GO

CREATE TABLE dbo.Audit (
    AuditID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Username NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Action NVARCHAR(50) NOT NULL,
    EntityType NVARCHAR(100) NOT NULL,
    EntityID BIGINT NOT NULL,
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    IPAddress NVARCHAR(45),
    UserAgent NVARCHAR(500),
    Timestamp DATETIME2 NOT NULL DEFAULT GETDATE(),
    SessionID NVARCHAR(100),
    Status NVARCHAR(20) NOT NULL,
    ErrorMessage NVARCHAR(MAX)
);
GO

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Audit',
    @role_name = NULL,
    @supports_net_changes = 1;
GO

USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'debezium')
BEGIN
    CREATE LOGIN debezium WITH PASSWORD = 'DbzPass@123';
END
GO

USE TestDB;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'debezium')
BEGIN
    CREATE USER debezium FOR LOGIN debezium;
END
GO

EXEC sp_addrolemember 'db_owner', 'debezium';
GO

