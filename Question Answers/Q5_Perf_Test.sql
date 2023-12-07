.timer ON
.mode column
.echo OFF

/*
Comparing the performance of joins on different types of data
 - string
 - datetime
 - unix_epoch
 - strftime

RESULTS
String Comparison
 - Execution time 13.125 seconds
 - Table size 2414 MB

Datetime Comparison
 - Execution time 11.553 seconds
 - Table size 2414 MB

Unix Epoch Comparison
 - Execution time 20.122 seconds
 - Table size 903 MB

Strftime Comparison
 - Execution time 10.823 seconds
 - Table size 1508 MB

Strftime comparison runs the fastest and returns the second smallest table.

*/

CREATE TABLE IF NOT EXISTS random_dates (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "date" TEXT
);

.separator ,
.import random_dates.csv random_dates

BEGIN;

    SELECT 'String comparison method';

    CREATE TABLE IF NOT EXISTS startend_dates AS
    WITH starting_dates AS (
        SELECT "date" AS "start_date"
        FROM random_dates
        LIMIT 10000
    ), ending_dates AS (
        SELECT "date" AS "end_date"
        FROM random_dates
        LIMIT 10000
    )
    SELECT "start_date", "end_date"
    FROM starting_dates
    JOIN ending_dates
        ON "start_date" < "end_date";



    SELECT 'Datetime comparison method';

    CREATE TABLE IF NOT EXISTS startend_datetimes AS
    WITH starting_dates AS (
        SELECT DATETIME("date") AS "start_date"
        FROM random_dates
        LIMIT 10000
    ), ending_dates AS (
        SELECT DATETIME("date") AS "end_date"
        FROM random_dates
        LIMIT 10000
    )
    SELECT "start_date", "end_date"
    FROM starting_dates
    JOIN ending_dates
        ON "start_date" < "end_date";



    SELECT 'Unix epoch comparision method';

    CREATE TABLE IF NOT EXISTS startend_unix AS
    WITH starting_dates AS (
        SELECT unixepoch("date") AS "start_date"
        FROM random_dates
        LIMIT 10000
    ), ending_dates AS (
        SELECT unixepoch("date") AS "end_date"
        FROM random_dates
        LIMIT 10000
    )
    SELECT "start_date", "end_date"
    FROM starting_dates
    JOIN ending_dates
        ON "start_date" < "end_date";



    SELECT 'Strftime comparison method';

    CREATE TABLE IF NOT EXISTS startend_strftime AS
    WITH starting_dates AS (
        SELECT strftime('%s', "date") AS "start_date"
        FROM random_dates
        LIMIT 10000
    ), ending_dates AS (
        SELECT strftime('%s', "date") AS "end_date"
        FROM random_dates
        LIMIT 10000
    )
    SELECT "start_date", "end_date"
    FROM starting_dates
    JOIN ending_dates
        ON "start_date" < "end_date";

    SELECT name, CONCAT(SUM(pgsize) * 1.0 / 1000000, ' megabytes') AS table_size
    FROM dbstat
    GROUP BY name
    ORDER BY table_size DESC;

    DROP TABLE startend_dates;
    DROP TABLE startend_datetimes;
    DROP TABLE startend_unix;
    DROP TABLE startend_strftime;
    DROP TABLE random_dates;

COMMIT;

VACUUM;