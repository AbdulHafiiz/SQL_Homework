.echo OFF
.timer ON
.mode columns
-- EXPLAIN QUERY PLAN
WITH station_visits AS (
    SELECT
        station.city AS `city`,
        trip.id AS `trip_id`,
        station.station_name AS `station_name`
    FROM trip
    LEFT JOIN station
    ON trip.start_station_id = station.station_id
    UNION
    SELECT
        station.city AS `city`,
        trip.id AS `trip_id`,
        station.station_name AS `station_name`
    FROM trip
    LEFT JOIN station
    ON trip.end_station_id = station.station_id
)
SELECT city, station_name, COUNT(*) AS `visit_count`
FROM station_visits
GROUP BY city, station_name
ORDER BY visit_count DESC
LIMIT 5;