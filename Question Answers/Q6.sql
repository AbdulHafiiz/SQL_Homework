.echo OFF
.timer ON
.mode column

WITH mini_trip1 AS (
    SELECT *
    FROM trip
    WHERE bike_id BETWEEN 100 AND 200
), mini_trip2 AS (
    SELECT *
    FROM trip
    WHERE bike_id BETWEEN 100 AND 200
)
SELECT
    mini_trip1.bike_id AS bike_id,
    mini_trip1.id AS former_trip_id,
    mini_trip1.start_time AS former_start_time,
    mini_trip1.end_time AS former_end_time,
    mini_trip2.id AS latter_trip_id,
    mini_trip2.start_time AS latter_start_time,
    mini_trip2.end_time AS latter_end_time
FROM mini_trip1
JOIN mini_trip2
    ON mini_trip1.bike_id = mini_trip2.bike_id
    AND former_trip_id < latter_trip_id
WHERE 
    former_end_time > latter_start_time
ORDER BY
    bike_id ASC,
    former_trip_id ASC,
    latter_trip_id ASC;