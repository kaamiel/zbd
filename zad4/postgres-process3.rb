require 'pg'

WAIT_FOR_NOTIFY_TIMEOUT = 5 # in seconds
EMIT_IMMEDIATELY = 0.1
EMIT_WITH_ADDITIONAL_INFO = 0.4

connection_for_new_requests = PG.connect(dbname: 'kd')
connection_for_additional_info = PG.connect(dbname: 'kd')
connection_for_new_requests.exec('LISTEN new_requests')
connection_for_additional_info.exec('LISTEN additional_info')

prng = Random.new

ret = true
while ret do
    ret = connection_for_new_requests.wait_for_notify(WAIT_FOR_NOTIFY_TIMEOUT) do |_, _, request_id|
        if connection_for_new_requests.exec_params('UPDATE requests SET processed_by_type_3 = true WHERE id = $1 AND NOT processed_by_type_3', [request_id]).cmd_tuples > 0
            request = connection_for_new_requests.exec_params('SELECT cookie, ip_address, additional_info FROM requests WHERE id = $1', [request_id]).first
            # checking whether to emit
            r = prng.rand
            if r <= EMIT_IMMEDIATELY
                # emit based on information from the process 1
                ad_id = 1 # selecting an ad
                connection_for_new_requests.exec_params('INSERT INTO emissions (ip_address, ad_id, request_id) VALUES ($1, $2, $3)', [request['ip_address'], ad_id, request_id])
            elsif r <= EMIT_WITH_ADDITIONAL_INFO
                # emit based on information from processes 1 and 2
                until request['additional_info'] do
                    connection_for_additional_info.wait_for_notify do |_, _, payload|
                        request = connection_for_additional_info.exec_params('SELECT ip_address, additional_info FROM requests WHERE id = $1', [request_id]).first if payload == request_id
                    end
                end
                ad_id = 1 # selecting an ad
                connection_for_new_requests.exec_params('INSERT INTO emissions (ip_address, ad_id, request_id) VALUES ($1, $2, $3)', [request['ip_address'], ad_id, request_id])
            end
        end
    end
end

connection_for_additional_info.close
connection_for_new_requests.close
