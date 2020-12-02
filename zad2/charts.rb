require 'squid'

def generate_chart(file_name, data)
  Prawn::Document.generate(file_name, page_size: [600, 420], align: :center, margin: 0) do
    chart(data, type: :line, height: 420, formats: [:float, :float], labels: [true, true])
  end
end

def generate_execution_time_chart(file_name, name)
  data = { 'query1' => {}, 'query2' => {} }

  10.times do |i|
    File.open("./outs/#{file_name}-execution-time-#{i}.out", 'r').each_slice(2) do |line1, line2|
      next unless line1.include?(name)
      line1 = line1.gsub('Execution Time: ', '')
      execution_time = line2.gsub(' Execution Time: ', '').to_f
      _, query, key = line1.split
      key = key.to_i
      data[query][key] = 0.0 if i == 0
      data[query][key] += execution_time
      data[query][key] /= 10 if i == 9
    end
  end

  generate_chart("./charts/execution-time-#{file_name}-#{name}.pdf", data)
end

def generate_size_of_data_file_chart(name)
  data = { 'sql-one-table' => {}, 'cstore-fdw' => {} }

  %w(sql-one-table cstore-fdw).each do |file_name|
    File.open("./outs/#{file_name}-size-of-data-file.out", 'r').each_slice(2) do |line1, line2|
      next unless line1.include?(name)
      line1 = line1.gsub('Size of data file: ', '')
      size = line2.gsub(' Size of data file: ', '').to_f / 1024
      _, key = line1.split
      data[file_name][key.to_i] = size
    end
  end

  generate_chart("./charts/size-of-data-file-#{name}.pdf", data)
end


%w(file-fdw sql-one-table sql-one-table-no-pk cstore-fdw).each do |file_name|
  %w(number_of_values distance_in_days number_of_categories).each do |name|
    generate_execution_time_chart(file_name, name)
  end
end

%w(number_of_values distance_in_days number_of_categories).each do |name|
  generate_size_of_data_file_chart(name)
end
