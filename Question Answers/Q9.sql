.echo OFF
.timer ON
.mode column

BEGIN;

    EXPLAIN QUERY PLAN
    WITH short_trip AS (
        SELECT
            trip.start_station_id,
            DATE(trip.start_time) AS "start_date",
            station.zip_code,
            CASE
                WHEN strftime('%s', trip.end_time) - strftime('%s', trip.start_time) <= 60
                    THEN 'short'
                ELSE 'long'
            END trip_type
        FROM trip
        JOIN station
            ON trip.start_station_id = station.station_id
    )
    SELECT
        short_trip.trip_type,
        ROUND(AVG(weather.mean_temp), 4) AS average_temp
    FROM short_trip
    JOIN weather
        ON weather.date = short_trip.start_date
            AND weather.zip_code = short_trip.zip_code
    GROUP BY short_trip.trip_type;


COMMIT;