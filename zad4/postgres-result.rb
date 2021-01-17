require 'pg'

QUERY1 = %{
SELECT
    min(diff),
    avg(diff),
    max(diff)
FROM (
    SELECT
        extract(milliseconds FROM (emissions.created_at - requests.created_at)) diff
    FROM
        emissions JOIN requests ON emissions.request_id = requests.id
    ) diffs
}

QUERY2 = %{
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
    diff
}

connection = PG.connect(dbname: 'kd')

result1 = connection.exec(QUERY1).first
result2 = connection.exec(QUERY2)

puts "min\t#{result1['min']}\navg\t#{result1['avg']}\nmax\t#{result1['max']}\n\n"
result2.each_row{ |diff, count| puts "#{diff}\t#{count}" }

connection.close
