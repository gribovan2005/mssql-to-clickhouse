CREATE DATABASE IF NOT EXISTS audit_db;

CREATE TABLE audit_db.audit_kafka
(
    ID Int32,
    Code Int32,
    Source String,
    SourceDetails Nullable(String),
    Data Nullable(String),
    Date Int64,
    Login String,
    Realm String,
    DelegatedUserID String,
    DelegatedUserLogin Nullable(String),
    UserID String,
    ExtendedData Nullable(String),
    EventLevel Int32,
    UniqueId Nullable(String),
    RoleId Int32,
    Serial Nullable(String),
    ClientId Nullable(String),
    GroupName Nullable(String)
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:29092',
    kafka_topic_list = 'mssql.AnalyticsServiceDb1021.dbo.Audit',
    kafka_group_name = 'clickhouse_audit_group_v2',
    kafka_format = 'AvroConfluent',
    format_avro_schema_registry_url = 'http://schema-registry:8081',
    kafka_num_consumers = 1,
    kafka_skip_broken_messages = 10;

CREATE TABLE audit_db.audit
(
    ID Int32,
    Code Int32,
    Source String,
    SourceDetails Nullable(String),
    Data Nullable(String),
    Date DateTime64(3),
    Login String,
    Realm String,
    DelegatedUserID String,
    DelegatedUserLogin Nullable(String),
    UserID String,
    ExtendedData Nullable(String),
    EventLevel Int32,
    UniqueId Nullable(String),
    RoleId Int32,
    Serial Nullable(String),
    ClientId Nullable(String),
    GroupName Nullable(String),
    _timestamp DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_timestamp)
ORDER BY (Date, ID)
SETTINGS index_granularity = 8192;

CREATE MATERIALIZED VIEW audit_db.audit_mv TO audit_db.audit AS
SELECT
    ID,
    Code,
    Source,
    SourceDetails,
    Data,
    fromUnixTimestamp64Milli(Date) AS Date,
    Login,
    Realm,
    DelegatedUserID,
    DelegatedUserLogin,
    UserID,
    ExtendedData,
    EventLevel,
    UniqueId,
    RoleId,
    Serial,
    ClientId,
    GroupName,
    _timestamp
FROM audit_db.audit_kafka;
