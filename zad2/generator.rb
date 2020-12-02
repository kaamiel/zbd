require 'date'
require 'csv'
require 'distribution'

START_DATE = Date.new(2020, 1, 1)
DATES = (START_DATE..).first(10_000)
CATEGORIES = ('A'..).first(1000)
VALUES = ('value_1'..).first(1000)
MEAN = 0
STANDARD_DEVIATION = 10

def generate_data(number_of_days: 60, number_of_categories: 10, number_of_values: 10)
  normal = Distribution::Normal.rng(MEAN, STANDARD_DEVIATION)
  CSV.open("./data/data-#{number_of_days}-#{number_of_categories}-#{number_of_values}.csv", 'wb') do |csv|
    DATES.first(number_of_days).each do |date|
      number_of_categories.times do |c|
        row = [date, CATEGORIES[c]]
        row += number_of_values.times.map{ normal.call.to_i }
        csv << row
      end
    end
  end
end

def explain_analyze_queries(name, key, number_of_days, number_of_categories, number_of_values, table_name)
  if name == 'distance_in_days'
    date_from = DATES.first(number_of_days - key).sample
    date_to = date_from + key
  else
    date_from, date_to = DATES.first(number_of_days).sample(2).sort
  end
  value = VALUES.first(number_of_values).sample

  %{
ANALYZE #{table_name};

\\echo 'Execution Time: #{name} query1 #{key}'

EXPLAIN ANALYZE
SELECT SUM(#{value})
FROM #{table_name}
WHERE date BETWEEN '#{date_from.to_s}' AND '#{date_to.to_s}';

\\echo 'Execution Time: #{name} query2 #{key}'

EXPLAIN ANALYZE
SELECT SUM(#{value})
FROM #{table_name}
WHERE date BETWEEN '#{date_from.to_s}' AND '#{date_to.to_s}' AND category = '#{CATEGORIES.first(number_of_categories).sample}';
}
end

def size_of_data_file(name, key, table_name)
  %{
\\echo 'Size of data file: #{name} #{key}'

SELECT 'Size of data file: ' || #{table_name == 'cstore_data' ? "cstore_table_size('cstore_data')" : "(pg_stat_file(pg_relation_filepath('#{table_name}'))).size"};
}
end

def generate_file_fdw_script(name:, key:, number_of_days: 60, number_of_categories: 10, number_of_values: 10)
  %{
-- generate_file_fdw_script(name: #{name}, key: #{key}, number_of_days: #{number_of_days}, number_of_categories: #{number_of_categories}, number_of_values: #{number_of_values})

DROP FOREIGN TABLE IF EXISTS csv_data;
CREATE FOREIGN TABLE csv_data (
    date date NOT NULL,
    category text NOT NULL,
    #{VALUES.first(number_of_values).map{ |v| "#{v} int NOT NULL" }.join(",\n    ")}
)
SERVER csv_data_server
OPTIONS (
    filename '/home/kd/zbd/zad2/data/data-#{number_of_days}-#{number_of_categories}-#{number_of_values}.csv',
    format 'csv'
);

#{explain_analyze_queries(name, key, number_of_days, number_of_categories, number_of_values, 'csv_data')}

DROP FOREIGN TABLE IF EXISTS csv_data;
}
end

def generate_sql_one_table_script(name:, key:, number_of_days: 60, number_of_categories: 10, number_of_values: 10, primary_key: true)
  %{
-- generate_sql_one_table_script(name: #{name}, key: #{key}, number_of_days: #{number_of_days}, number_of_categories: #{number_of_categories}, number_of_values: #{number_of_values})

DROP TABLE IF EXISTS csv_data;
CREATE TABLE csv_data (
    date date NOT NULL,
    category text NOT NULL,
    #{'PRIMARY KEY (date, category),' if primary_key}
    #{VALUES.first(number_of_values).map{ |v| "#{v} int NOT NULL" }.join(",\n    ")}
);

COPY csv_data FROM '/home/kd/zbd/zad2/data/data-#{number_of_days}-#{number_of_categories}-#{number_of_values}.csv' (FORMAT 'csv');

#{size_of_data_file(name, key, 'csv_data')}

#{explain_analyze_queries(name, key, number_of_days, number_of_categories, number_of_values, 'csv_data')}

DROP TABLE IF EXISTS csv_data;
}
end

def generate_cstore_fdw_script(name:, key:, number_of_days: 60, number_of_categories: 10, number_of_values: 10)
  %{
-- generate_cstore_fdw_script(name: #{name}, key: #{key}, number_of_days: #{number_of_days}, number_of_categories: #{number_of_categories}, number_of_values: #{number_of_values})

DROP FOREIGN TABLE IF EXISTS cstore_data;
CREATE FOREIGN TABLE cstore_data (
    date date NOT NULL,
    category text NOT NULL,
    #{VALUES.first(number_of_values).map{ |v| "#{v} int NOT NULL" }.join(",\n    ")}
)
SERVER cstore_server;

COPY cstore_data FROM '/home/kd/zbd/zad2/data/data-#{number_of_days}-#{number_of_categories}-#{number_of_values}.csv' (FORMAT 'csv');

#{size_of_data_file(name, key, 'cstore_data')}

#{explain_analyze_queries(name, key, number_of_days, number_of_categories, number_of_values, 'cstore_data')}

DROP FOREIGN TABLE IF EXISTS cstore_data;
}
end

NUMBERS_OF_VALUES_AND_CATEGORIES = [1, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800]
DISTANCES_IN_DAYS = [1, 100, 200, 300, 400, 500, 1000, 2000, 3000, 4000, 5000, 6000, 7000]

# generate_data

# # co się dzieje jak w tabeli jest tylko jedna kolumna, a co jak tych kolumn jest kilkaset?
# # co się dzieje jak kategoria jest jedna a co jak jest ich dużo?
# NUMBERS_OF_VALUES_AND_CATEGORIES.each do |n|
#   generate_data(number_of_values: n)
#   generate_data(number_of_categories: n)
# end

# # co się dzieje jak przedziały dat w pytaniach są długie a co jak są krótkie?
# generate_data(number_of_days: 8000)

10.times do |i|
  File.open("./scripts/file-fdw-full-#{i}.sql", 'w') do |file|
    NUMBERS_OF_VALUES_AND_CATEGORIES.each do |n|
      file.write generate_file_fdw_script(name: 'number_of_values', key: n, number_of_values: n)
      file.write generate_file_fdw_script(name: 'number_of_categories', key: n, number_of_categories: n)
    end

    DISTANCES_IN_DAYS.each do |n|
      file.write generate_file_fdw_script(name: 'distance_in_days', key: n, number_of_days: 8000)
    end
  end

  File.open("./scripts/sql-one-table-full-#{i}.sql", 'w') do |file|
    NUMBERS_OF_VALUES_AND_CATEGORIES.each do |n|
      file.write generate_sql_one_table_script(name: 'number_of_values', key: n, number_of_values: n)
      file.write generate_sql_one_table_script(name: 'number_of_categories', key: n, number_of_categories: n)
    end

    DISTANCES_IN_DAYS.each do |n|
      file.write generate_sql_one_table_script(name: 'distance_in_days', key: n, number_of_days: 8000)
    end
  end

  File.open("./scripts/sql-one-table-no-pk-full-#{i}.sql", 'w') do |file|
    NUMBERS_OF_VALUES_AND_CATEGORIES.each do |n|
      file.write generate_sql_one_table_script(name: 'number_of_values', key: n, number_of_values: n, primary_key: false)
      file.write generate_sql_one_table_script(name: 'number_of_categories', key: n, number_of_categories: n, primary_key: false)
    end

    DISTANCES_IN_DAYS.each do |n|
      file.write generate_sql_one_table_script(name: 'distance_in_days', key: n, number_of_days: 8000, primary_key: false)
    end
  end

  File.open("./scripts/cstore-fdw-full-#{i}.sql", 'w') do |file|
    NUMBERS_OF_VALUES_AND_CATEGORIES.each do |n|
      file.write generate_cstore_fdw_script(name: 'number_of_values', key: n, number_of_values: n)
      file.write generate_cstore_fdw_script(name: 'number_of_categories', key: n, number_of_categories: n)
    end

    DISTANCES_IN_DAYS.each do |n|
      file.write generate_cstore_fdw_script(name: 'distance_in_days', key: n, number_of_days: 8000)
    end
  end
end



# Dir.entries('data/').select{ |file_name| file_name.match?(/^data-\d+-\d+-\d+\.csv$/) }.each do |file_name|
#   _, number_of_days, number_of_categories, number_of_values = file_name.split(/^data\-(\d+)\-(\d+)\-(\d+)\.csv$/).map(&:to_i)


# end
