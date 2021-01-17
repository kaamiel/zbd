#!/bin/bash

set -x

number_of_requests=1500

for ((i = 0; i < 5; ++i)); do

    psql < postgres-create.sql

    ruby postgres-process2.rb &
    ruby postgres-process3.rb &

    # ruby postgres-process2.rb &
    # ruby postgres-process3.rb &

    # ruby postgres-process2.rb &
    # ruby postgres-process3.rb &

    # ruby postgres-process2.rb &
    # ruby postgres-process3.rb &

    sleep 2

    ruby postgres-process1.rb $number_of_requests &
    # ruby postgres-process1.rb $number_of_requests &
    # ruby postgres-process1.rb $number_of_requests &
    # ruby postgres-process1.rb $number_of_requests &

    wait

    echo
    ruby postgres-result.rb

done
