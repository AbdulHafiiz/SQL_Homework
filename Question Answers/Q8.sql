.echo OFF
.timer ON
.mode column

BEGIN;

    EXPLAIN QUERY PLAN
    WITH weather_date AS (
        SELECT
            events,
            COUNT(DISTINCT("date")) AS day_count
        FROM weather
        GROUP BY events
    )
    SELECT
        weather.events,
        ROUND(
            COUNT(DISTINCT(trip.id)) * 1.0 / day_count,
            4
        ) AS avg_trips
    FROM trip
    JOIN station
        ON trip.start_station_id = station.station_id
    JOIN weather
        ON station.zip_code = weather.zip_code
            AND DATE(trip.start_time) = weather.date
    JOIN weather_date
        ON weather.events = weather_date.events
    GROUP BY
        weather.events
    ORDER BY
        avg_trips DESC,
        weather.events ASC;

COMMIT;