require 'redis'

SUBSCRIBE_TIMEOUT = 5 # in seconds
EMIT_IMMEDIATELY = 0.1
EMIT_WITH_ADDITIONAL_INFO = 0.4

redis = Redis.new
new_requests_subscriber = Redis.new
additional_info_subscriber = Redis.new

prng = Random.new

begin
    new_requests_subscriber.subscribe_with_timeout(SUBSCRIBE_TIMEOUT, :new_requests) do |on|
        on.message do |_, request_key|
            if redis.hsetnx(request_key, :processed_by_type_3, true)
                request = redis.hgetall(request_key)
                emission_key = request_key.gsub('request', 'emission')
                # checking whether to emit
                r = prng.rand
                if r <= EMIT_IMMEDIATELY
                    # emit based on information from the process 1
                    ad_id = 1 # selecting an ad
                    redis.eval("return redis.call('HSET', '#{emission_key}', 'ip_address', '#{request['ip_address']}', 'ad_id', '#{ad_id}', 'created_at', table.concat(redis.call('TIME')))")
                elsif r <= EMIT_WITH_ADDITIONAL_INFO
                    # emit based on information from processes 1 and 2
                    additional_info_subscriber.subscribe(:additional_info) do |on|
                        on.subscribe do
                            additional_info_subscriber.unsubscribe if redis.hexists(request_key, :additional_info)
                        end
                        on.message do |_, msg|
                            additional_info_subscriber.unsubscribe if msg == request_key
                        end
                    end
                    ad_id = 1 # selecting an ad
                    redis.eval("return redis.call('HSET', '#{emission_key}', 'ip_address', '#{request['ip_address']}', 'ad_id', '#{ad_id}', 'created_at', table.concat(redis.call('TIME')))")
                end
            end
        end
    end
rescue Redis::TimeoutError
    redis.quit
    new_requests_subscriber.quit
    additional_info_subscriber.quit
end
