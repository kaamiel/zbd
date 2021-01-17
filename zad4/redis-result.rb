require 'redis'

def extract_microseconds(str)
    str[0..9].to_i * 1_000_000 + str[10..].to_i
end

redis = Redis.new

ids = redis.keys('emission:*').map{ |key| key.gsub('emission:', '') }
diffs = ids.map{ |id| extract_microseconds(redis.hget("emission:#{id}", :created_at)) - extract_microseconds(redis.hget("request:#{id}", :created_at)) }

puts "min\t#{diffs.min.to_f / 1000}\navg\t#{diffs.sum.to_f / diffs.size / 1000}\nmax\t#{diffs.max.to_f / 1000}\n\n"
diffs.group_by{ |diff| (diff.to_f / 1000).round }.transform_values(&:size).sort.each{ |diff, count| puts "#{diff}\t#{count}" }

redis.quit
