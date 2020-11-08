
DROP TABLE IF EXISTS jsonb_audience, jsonb_targets;

CREATE TABLE jsonb_audience (
    date date NOT NULL,
    content jsonb NOT NULL
);
CREATE TABLE jsonb_targets (
    content jsonb NOT NULL
);

COPY jsonb_audience(content, date) FROM PROGRAM 'find /home/kd/zbd/zad1/data/ -type f -name "audience*json" -exec cat {} \; -exec echo -en "\t" \; -exec sh -c "basename {} | cut -c10-19" \;';
COPY jsonb_targets(content) FROM '/home/kd/zbd/zad1/data/targets.json';


EXPLAIN ANALYZE
WITH audience AS (
    SELECT DISTINCT
        date,
        (jb->'person_id')::int person_id,
        jb->>'demography' demography,
        regexp_split_to_table(jb->>'contacts', '') contact
    FROM (
        SELECT
            date,
            jsonb_array_elements(content) jb
        FROM
            jsonb_audience
        ) ta
    WHERE
        jb->>'contacts' != ''
), targets AS (
    SELECT
        (jb->'target')::int id,
        replace(jb->>'definition', ' ', '_') definition
    FROM (
        SELECT
            jsonb_array_elements(content) jb
        FROM
            jsonb_targets
        ) tt
)
SELECT
    audience.date dzien,
    targets.id grupa,
    audience.contact reklama,
    count(*) osob
FROM
    audience
JOIN
    targets
ON
    audience.demography LIKE targets.definition
GROUP BY
    dzien,
    grupa,
    reklama
ORDER BY
    dzien,
    grupa,
    reklama;


DROP TABLE IF EXISTS jsonb_audience, jsonb_targets;

