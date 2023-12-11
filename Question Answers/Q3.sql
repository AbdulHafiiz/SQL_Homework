.echo OFF
.timer ON
.mode columns
-- EXPLAIN QUERY PLAN 
WITH city_trips AS (
    SELECT
        station.city AS `city`,
        trip.id AS `trip_id`
    FROM trip
    LEFT JOIN station
    ON trip.start_station_id = station.station_id
    UNION
    SELECT
        station.city AS `city`,
        trip.id AS `trip_id`
    FROM trip
    LEFT JOIN station
    ON trip.end_station_id = station.station_id
)
SELECT
    `city`,
    -- ROUND(COUNT(`trip_id`) * 100 / COUNT(*) OVER ()) AS `ratio`
    ROUND(COUNT(`trip_id`) * 1.0 / (SELECT COUNT(*) from city_trips), 4) AS `ratio`
FROM city_trips
GROUP BY city_trips.city
ORDER BY ratio DESC, city ASC;