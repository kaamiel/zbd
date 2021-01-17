require 'pg'

WAIT_FOR_NOTIFY_TIMEOUT = 5 # in seconds

connection = PG.connect(dbname: 'kd')
connection.exec('LISTEN new_requests')

ret = true
while ret do
    ret = connection.wait_for_notify(WAIT_FOR_NOTIFY_TIMEOUT) do |_, _, request_id|
        if connection.exec_params('UPDATE requests SET processed_by_type_2 = true WHERE id = $1 AND NOT processed_by_type_2', [request_id]).cmd_tuples > 0
            request = connection.exec_params('SELECT cookie, ip_address FROM requests WHERE id = $1', [request_id]).first
            additional_info = request['cookie'] + request['ip_address'] # adding additional info
            connection.exec_params('UPDATE requests SET additional_info = $2 WHERE id = $1', [request_id, additional_info])
        end
    end
end

connection.close
