.echo OFF
.timer ON
.mode column

BEGIN;

    SELECT
        weather.events AS events,
        ROUND(
            (COUNT(trip.id) * 1.0) / (COUNT(DISTINCT(weather.date)) * 1.0),
            4
        ) AS avg_trips
    FROM trip
    JOIN station
        ON trip.start_station_id = station.station_id
    JOIN weather
        ON station.zip_code = weather.zip_code
        AND DATE(trip.start_time) = weather.date
    GROUP BY weather.events
    ORDER BY
        avg_trips DESC,
        events ASC;

COMMIT;