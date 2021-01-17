require 'redis'

SUBSCRIBE_TIMEOUT = 5 # in seconds

redis = Redis.new
subscriber = Redis.new

begin
    subscriber.subscribe_with_timeout(SUBSCRIBE_TIMEOUT, :new_requests) do |on|
        on.message do |_, request_key|
            if redis.hsetnx(request_key, :processed_by_type_2, true)
                request = redis.hgetall(request_key)
                additional_info = request['cookie'] + request['ip_address'] # adding additional info
                redis.hset(request_key, additional_info: additional_info)
                redis.publish(:additional_info, request_key)
            end
        end
    end
rescue Redis::TimeoutError
    redis.quit
    subscriber.quit
end
