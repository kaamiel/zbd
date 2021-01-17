
DROP TRIGGER IF EXISTS additional_info_trigger ON requests;
DROP TRIGGER IF EXISTS new_request_trigger ON requests;
DROP FUNCTION IF EXISTS additional_info_notification, new_request_notification;
DROP TABLE IF EXISTS emissions, requests;

CREATE TABLE requests (
    id bigserial PRIMARY KEY,
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    processed_by_type_2 boolean NOT NULL DEFAULT false,
    processed_by_type_3 boolean NOT NULL DEFAULT false,
    cookie text NOT NULL,
    ip_address text NOT NULL,
    additional_info text
);

CREATE TABLE emissions (
    id bigserial PRIMARY KEY,
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    ip_address text NOT NULL,
    ad_id int NOT NULL,
    request_id bigint NOT NULL
);

CREATE OR REPLACE FUNCTION new_request_notification()
RETURNS trigger AS $$
    BEGIN
        PERFORM pg_notify('new_requests', NEW.id::text);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER new_request_trigger
    AFTER INSERT ON requests
    FOR EACH ROW
    EXECUTE PROCEDURE new_request_notification();

CREATE OR REPLACE FUNCTION additional_info_notification()
RETURNS trigger AS $$
    BEGIN
        PERFORM pg_notify('additional_info', NEW.id::text);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER additional_info_trigger
    AFTER UPDATE ON requests
    FOR EACH ROW
    WHEN (OLD.additional_info IS NULL AND NEW.additional_info IS NOT NULL)
    EXECUTE PROCEDURE additional_info_notification();

-- INSERT INTO requests (cookie, ip_address) VALUES ('asdasdajhsbdjf', '127.0.0.1');
