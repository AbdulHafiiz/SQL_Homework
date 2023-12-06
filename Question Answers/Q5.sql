.timer ON
.header ON

-- EXPLAIN QUERY PLAN
-- Somehow limiting the data in the minitrip CTE enables the query to run in a reasonable time ~20 seconds
-- Although this has a significant storage overhead as the table has to be created, dropped and vacuumed
-- To be completely honest I don't understand the difference in the query plan
CREATE TABLE IF NOT EXISTS joined_trip_dates AS
WITH dates AS (
    SELECT
        DATE(start_time) AS tdate
    FROM trip
    UNION
    SELECT
        DATE(end_time) AS tdate
    FROM trip
), mini_trip AS (
    SELECT *
    FROM trip
    WHERE bike_id <= 100
    LIMIT 100000
)
SELECT *
FROM dates, mini_trip;

SELECT SUM(pgsize) AS table_bytesize
FROM dbstat
WHERE name='joined_trip_dates';

SELECT
    tdate,
    ROUND(
        SUM(
            strftime('%s', MIN(DATETIME(end_time), DATETIME(tdate, '+1 day')))
            - strftime('%s', MAX(DATETIME(start_time), DATETIME(tdate)))
        ) * 1.0 / (SELECT COUNT(DISTINCT(bike_id)) FROM trip WHERE bike_id <= 100),
        4
    ) AS avg_duration
FROM
    joined_trip_dates
WHERE
    DATETIME(start_time) < DATETIME(tdate, '+1 day')
    AND DATETIME(end_time) > DATETIME(tdate)
GROUP BY
    tdate
ORDER BY
    avg_duration DESC
LIMIT 10;

DROP TABLE IF EXISTS joined_trip_dates;

VACUUM;