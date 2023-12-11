.echo OFF
.timer ON
.mode column

SELECT bike_id, COUNT(DISTINCT(city)) AS city_count
FROM trip
JOIN station
    ON trip.start_station_id = station.station_id
        OR trip.end_station_id = station.station_id
GROUP BY bike_id
HAVING city_count > 1
ORDER BY
    city_count DESC,
    bike_id ASC;