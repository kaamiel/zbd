#!/bin/bash

for ((i = 0; i < 10; ++i)); do
    psql < file-fdw-full-${i}.sql > file-fdw-${i}.out &&
    psql < sql-one-table-full-${i}.sql > sql-one-table-${i}.out &&
    psql < sql-one-table-no-pk-full-${i}.sql > sql-one-table-no-pk-${i}.out &&
    psql < cstore-fdw-full-${i}.sql > cstore-fdw-${i}.out &&

    grep "Execution Time" file-fdw-${i}.out > file-fdw-execution-time-${i}.out &&
    grep "Execution Time" sql-one-table-${i}.out > sql-one-table-execution-time-${i}.out &&
    grep "Execution Time" sql-one-table-no-pk-${i}.out > sql-one-table-no-pk-execution-time-${i}.out &&
    grep "Execution Time" cstore-fdw-${i}.out > cstore-fdw-execution-time-${i}.out &&

    echo "ok $i" ||
    echo "failed $i"
done

grep "Size of data file" sql-one-table-0.out > sql-one-table-size-of-data-file.out &&
grep "Size of data file" cstore-fdw-0.out > cstore-fdw-size-of-data-file.out
