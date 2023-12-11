.echo OFF
.timer ON
.mode columns

-- EXPLAIN QUERY PLAN
-- Somehow limiting the data in the mini_trip CTE enables the query to run in a reasonable time ~20 seconds
-- Although this has a significant storage overhead as the table has to be created, dropped and vacuumed
-- To be completely honest I don't understand the difference in the query plan
-- EXPLAIN QUERY PLAN

BEGIN;

    -- Temp table is used to store length of mini_trip table 
    PRAGMA temp_store = 2;
    CREATE TEMP TABLE _variables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        var_name TEXT,
        int_value INTEGER
    );

    -- Inserting and updateing temp variable table
    INSERT INTO _variables (var_name)
    VALUES ('mini_trip_len');

    UPDATE _variables
    SET int_value = (
        SELECT COUNT(*)
        FROM trip
        WHERE bike_id <= 100
    )
    WHERE var_name = 'mini_trip_len';

    -- Create cross join table for trip duration calculation
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
        LIMIT (SELECT int_value FROM _variables WHERE var_name = 'mini_trip_len') -- Somehow makes this query executable, I have no idea why
    )
    SELECT dates.tdate, mini_trip.end_time, mini_trip.start_time, mini_trip.bike_id
    FROM dates
    CROSS JOIN mini_trip;

    -- Displays size of cross join table
    SELECT CONCAT(SUM(pgsize)/1000000, ' megabytes') AS table_megabytesize
    FROM dbstat
    WHERE name='joined_trip_dates';

    -- Average duration calculation
    SELECT
        tdate,
        ROUND(
            SUM(
                -- Convert to unix epoch timestamps, then truncate the start and end times
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
    DROP TABLE _variables;

COMMIT;

VACUUM;