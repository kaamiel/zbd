
DROP EXTENSION IF EXISTS cstore_fdw;
CREATE EXTENSION cstore_fdw;

DROP SERVER IF EXISTS cstore_server;
CREATE SERVER cstore_server FOREIGN DATA WRAPPER cstore_fdw;

DROP FOREIGN TABLE IF EXISTS cstore_data;
CREATE FOREIGN TABLE cstore_data (
    date date NOT NULL,
    category text NOT NULL,
    value_1 int NOT NULL,
    value_2 int NOT NULL,
    value_3 int NOT NULL,
    value_4 int NOT NULL,
    value_5 int NOT NULL,
    value_6 int NOT NULL,
    value_7 int NOT NULL,
    value_8 int NOT NULL,
    value_9 int NOT NULL,
    value_10 int NOT NULL
)
SERVER cstore_server;

COPY cstore_data FROM '/home/kd/zbd/zad2/data/data-60-10-10.csv' (FORMAT 'csv');

ANALYZE cstore_data;

\echo 'query1 Execution Time'

EXPLAIN ANALYZE
SELECT
    SUM(value_3)
FROM
    cstore_data
WHERE
    date BETWEEN '2020-01-05' AND '2020-01-08';

\echo 'query2 Execution Time'

EXPLAIN ANALYZE
SELECT
    SUM(value_3)
FROM
    cstore_data
WHERE
    date BETWEEN '2020-01-05' AND '2020-01-08' AND
    category = 'A';

DROP FOREIGN TABLE IF EXISTS cstore_data;
DROP SERVER IF EXISTS cstore_server;
DROP EXTENSION IF EXISTS cstore_fdw;
