#!/bin/bash

set -x

number_of_requests=1500

for ((i = 0; i < 5; ++i)); do

    redis-cli FLUSHDB

    ruby redis-process2.rb &
    ruby redis-process3.rb &

    # ruby redis-process2.rb &
    # ruby redis-process3.rb &

    # ruby redis-process2.rb &
    # ruby redis-process3.rb &

    # ruby redis-process2.rb &
    # ruby redis-process3.rb &

    sleep 2

    ruby redis-process1.rb $number_of_requests &
    # ruby redis-process1.rb $number_of_requests &
    # ruby redis-process1.rb $number_of_requests &
    # ruby redis-process1.rb $number_of_requests &

    wait

    echo
    ruby redis-result.rb

done
