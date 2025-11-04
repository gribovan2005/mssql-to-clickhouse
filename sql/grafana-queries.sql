SELECT 
    count() as total_records,
    countIf(Status = 'SUCCESS') as successful,
    countIf(Status = 'FAILED') as failed,
    countIf(Status = 'PENDING') as pending
FROM audit_db.audit;

SELECT 
    toStartOfMinute(Timestamp) as time,
    count() as records_per_minute
FROM audit_db.audit
WHERE Timestamp >= now() - INTERVAL 1 HOUR
GROUP BY time
ORDER BY time;

SELECT 
    Action,
    count() as count
FROM audit_db.audit
GROUP BY Action
ORDER BY count DESC;

SELECT 
    EntityType,
    count() as count
FROM audit_db.audit
GROUP BY EntityType
ORDER BY count DESC;

SELECT 
    Status,
    count() as count
FROM audit_db.audit
GROUP BY Status;

SELECT 
    toStartOfHour(Timestamp) as hour,
    Action,
    count() as count
FROM audit_db.audit
WHERE Timestamp >= now() - INTERVAL 24 HOUR
GROUP BY hour, Action
ORDER BY hour, count DESC;

SELECT 
    Username,
    count() as operations,
    uniq(Action) as unique_actions
FROM audit_db.audit
GROUP BY Username
ORDER BY operations DESC
LIMIT 10;

SELECT 
    max(Timestamp) as last_record_time,
    count() as total_records,
    min(Timestamp) as first_record_time,
    dateDiff('second', min(Timestamp), max(Timestamp)) as time_span_seconds
FROM audit_db.audit;

SELECT 
    toStartOfInterval(Timestamp, INTERVAL 5 MINUTE) as time,
    avg(AuditID) as avg_audit_id,
    count() as records
FROM audit_db.audit
WHERE Timestamp >= now() - INTERVAL 1 HOUR
GROUP BY time
ORDER BY time;

SELECT 
    Status,
    EntityType,
    count() as count
FROM audit_db.audit
GROUP BY Status, EntityType
ORDER BY count DESC
LIMIT 20;

