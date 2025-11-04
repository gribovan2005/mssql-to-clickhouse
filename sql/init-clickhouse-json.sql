CREATE DATABASE IF NOT EXISTS audit_db;

CREATE TABLE IF NOT EXISTS audit_db.audit_kafka
(
    AuditID Int64,
    UserID Int32,
    Username String,
    Email String,
    Action String,
    EntityType String,
    EntityID Int64,
    OldValue Nullable(String),
    NewValue Nullable(String),
    IPAddress Nullable(String),
    UserAgent Nullable(String),
    Timestamp Int64,
    SessionID Nullable(String),
    Status String,
    ErrorMessage Nullable(String)
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:29092',
    kafka_topic_list = 'mssql.TestDB.dbo.Audit',
    kafka_group_name = 'clickhouse_audit_group',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 1,
    kafka_skip_broken_messages = 10;

CREATE TABLE IF NOT EXISTS audit_db.audit
(
    AuditID Int64,
    UserID Int32,
    Username String,
    Email String,
    Action String,
    EntityType String,
    EntityID Int64,
    OldValue Nullable(String),
    NewValue Nullable(String),
    IPAddress Nullable(String),
    UserAgent Nullable(String),
    Timestamp DateTime64(3),
    SessionID Nullable(String),
    Status String,
    ErrorMessage Nullable(String),
    _timestamp DateTime DEFAULT now()
)
ENGINE = MergeTree()
ORDER BY (Timestamp, AuditID);

CREATE MATERIALIZED VIEW IF NOT EXISTS audit_db.audit_mv TO audit_db.audit AS
SELECT
    AuditID,
    UserID,
    Username,
    Email,
    Action,
    EntityType,
    EntityID,
    OldValue,
    NewValue,
    IPAddress,
    UserAgent,
    fromUnixTimestamp64Milli(Timestamp) AS Timestamp,
    SessionID,
    Status,
    ErrorMessage
FROM audit_db.audit_kafka;

