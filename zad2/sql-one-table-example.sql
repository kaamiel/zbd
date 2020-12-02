
DROP TABLE IF EXISTS csv_data;
CREATE TABLE csv_data (
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
    value_10 int NOT NULL,
    PRIMARY KEY (date, category)
);

COPY csv_data FROM '/home/kd/zbd/zad2/data/data-60-10-10.csv' (FORMAT 'csv');

ANALYZE csv_data;

\echo 'query1 Execution Time'

EXPLAIN ANALYZE
SELECT
    SUM(value_3)
FROM
    csv_data
WHERE
    date BETWEEN '2020-01-05' AND '2020-01-08';

\echo 'query2 Execution Time'

EXPLAIN ANALYZE
SELECT
    SUM(value_3)
FROM
    csv_data
WHERE
    date BETWEEN '2020-01-05' AND '2020-01-08' AND
    category = 'A';

DROP TABLE IF EXISTS csv_data;
