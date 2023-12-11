.echo OFF
.timer ON
.mode column

BEGIN;

    WITH stormy_station AS (
        WITH date_loc AS (
            SELECT "date", zip_code
            FROM weather
            WHERE events = 'Rain-Thunderstorm'
        )
        SELECT
            COUNT(trip.id) AS trip_count,
            station.station_name,
            station.zip_code
        FROM station
        JOIN date_loc
            ON station.zip_code = date_loc.zip_code
        JOIN trip
            ON station.station_id = trip.start_station_id
            AND DATE(trip.start_time) = date_loc.date
        GROUP BY station.station_id, station.zip_code
    )
    SELECT
        stormy_station.zip_code,
        stormy_station.station_name,
        MAX(stormy_station.trip_count) AS max_trip
    FROM stormy_station
    GROUP BY stormy_station.zip_code;

ROLLBACK;