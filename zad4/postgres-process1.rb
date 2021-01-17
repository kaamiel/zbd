require 'pg'

if ARGV.empty?
    puts "usage: ruby #{__FILE__} <number of requests>"
    exit
end

NUMBER_OF_REQUESTS = ARGV.first.to_i
MAX_SLEEP_DURATION = 20 # in milliseconds
MIN_SLEEP_DURATION = 10 # in milliseconds
SIZE_OF_COOKIE = 64
CHARS = ('a'..'z').to_a + ('0'..'9').to_a
OCTETS = (1..254).to_a

prng = Random.new

pre_generated_data = NUMBER_OF_REQUESTS.times.map do
    cookie = SIZE_OF_COOKIE.times.map{ CHARS.sample(random: prng) }.join
    ip_address = OCTETS.sample(4, random: prng).join('.')
    sleep_duration = [prng.rand(MAX_SLEEP_DURATION), MIN_SLEEP_DURATION].max
    [cookie, ip_address, sleep_duration.to_f / 1000]
end

connection = PG.connect(dbname: 'kd')

pre_generated_data.each do |cookie, ip_address, sleep_duration|
    connection.exec_params('INSERT INTO requests (cookie, ip_address) VALUES ($1, $2)', [cookie, ip_address])
    sleep sleep_duration
end

connection.close
