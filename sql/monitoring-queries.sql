SELECT 
    now() as current_time,
    max(Timestamp) as last_record_time,
    dateDiff('second', max(Timestamp), now()) as seconds_behind,
    count() as total_records
FROM audit_db.audit;

SELECT 
    toStartOfMinute(Timestamp) as time,
    count() as records_per_minute
FROM audit_db.audit
WHERE Timestamp >= now() - INTERVAL 1 HOUR
GROUP BY time
ORDER BY time DESC
LIMIT 60;

SELECT 
    count() as total_records,
    uniq(AuditID) as unique_audit_ids,
    max(Timestamp) as latest_timestamp,
    min(Timestamp) as earliest_timestamp
FROM audit_db.audit;

SELECT 
    dateDiff('second', min(Timestamp), max(Timestamp)) as time_range_seconds,
    count() / dateDiff('second', min(Timestamp), max(Timestamp)) as avg_records_per_second
FROM audit_db.audit
WHERE Timestamp >= now() - INTERVAL 1 HOUR;

SELECT 
    Status,
    count() as count,
    count() * 100.0 / (SELECT count() FROM audit_db.audit) as percentage
FROM audit_db.audit
GROUP BY Status
ORDER BY count DESC;

SELECT 
    Action,
    count() as count,
    avg(dateDiff('second', Timestamp, now())) as avg_age_seconds
FROM audit_db.audit
GROUP BY Action
ORDER BY count DESC
LIMIT 10;

SELECT 
    toStartOfHour(Timestamp) as hour,
    count() as records,
    uniq(UserID) as unique_users,
    uniq(Action) as unique_actions
FROM audit_db.audit
WHERE Timestamp >= now() - INTERVAL 24 HOUR
GROUP BY hour
ORDER BY hour DESC;

SELECT 
    countIf(Timestamp >= now() - INTERVAL 1 MINUTE) as last_1_min,
    countIf(Timestamp >= now() - INTERVAL 5 MINUTE) as last_5_min,
    countIf(Timestamp >= now() - INTERVAL 15 MINUTE) as last_15_min,
    countIf(Timestamp >= now() - INTERVAL 1 HOUR) as last_1_hour
FROM audit_db.audit;

SELECT 
    toStartOfInterval(Timestamp, INTERVAL 5 MINUTE) as time_interval,
    count() as records,
    uniq(Username) as unique_users
FROM audit_db.audit
WHERE Timestamp >= now() - INTERVAL 1 HOUR
GROUP BY time_interval
ORDER BY time_interval DESC;

SELECT 
    'Replication Health' as metric,
    CASE 
        WHEN dateDiff('second', max(Timestamp), now()) < 60 THEN 'Healthy'
        WHEN dateDiff('second', max(Timestamp), now()) < 300 THEN 'Warning'
        ELSE 'Critical'
    END as status,
    dateDiff('second', max(Timestamp), now()) as lag_seconds
FROM audit_db.audit;

