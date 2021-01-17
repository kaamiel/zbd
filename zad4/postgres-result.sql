
SELECT
    min(diff),
    avg(diff),
    max(diff)
FROM (
    SELECT
        extract(milliseconds FROM (emissions.created_at - requests.created_at)) diff
    FROM
        emissions JOIN requests ON emissions.request_id = requests.id
    ) diffs;


SELECT
    diff,
    count(*)
FROM (
    SELECT
        round(extract(milliseconds FROM (emissions.created_at - requests.created_at))) diff
    FROM
        emissions JOIN requests ON emissions.request_id = requests.id
    ) diffs
GROUP BY
    diff
ORDER BY
    diff;

