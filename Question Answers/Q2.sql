.echo OFF
.timer ON
.mode columns
-- EXPLAIN QUERY PLAN
SELECT
    COUNT(*) as `station_count`,
    city
FROM station
GROUP BY city
ORDER BY
    station_count DESC,
    city ASC;