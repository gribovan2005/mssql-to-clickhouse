USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TestDB')
BEGIN
    CREATE DATABASE TestDB;
END
GO

USE TestDB;
GO

-- Enable CDC for the database if not already enabled
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'TestDB' AND is_cdc_enabled = 0)
BEGIN
    EXEC sys.sp_cdc_enable_db;
END
GO

-- Drop the table if it exists
IF OBJECT_ID('dbo.Audit', 'U') IS NOT NULL
BEGIN
    -- Disable CDC for the table if it exists
    IF EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE t.name = 'Audit' AND s.name = 'dbo' AND t.is_tracked_by_cdc = 1)
    BEGIN
        EXEC sys.sp_cdc_disable_table 
            @source_schema = N'dbo',
            @source_name = N'Audit',
            @capture_instance = 'dbo_Audit';
    END
    
    DROP TABLE dbo.Audit;
END
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

-- Enable CDC for the table
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Audit',
    @role_name = NULL,
    @supports_net_changes = 1,
    @capture_instance = 'dbo_Audit';
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

-- Grant necessary permissions for CDC
EXEC sp_addrolemember 'db_owner', 'debezium';
GO

-- Grant additional CDC permissions
GRANT SELECT ON SCHEMA::cdc TO debezium;
GRANT VIEW DATABASE STATE TO debezium;
GO
