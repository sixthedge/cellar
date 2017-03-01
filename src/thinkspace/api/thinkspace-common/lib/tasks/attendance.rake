namespace :thinkspace do
  namespace :attendance do
    task :table_from_csv, [:file_path] => [:environment] do |t, args|
      file_path = args.file_path
      file_path = File.expand_path("../files/#{file_path}", __FILE__)
      puts "[thinkspace:attendance] Loading file from: [#{file_path}]"
      student_trs = []
      count       = 0
      CSV.foreach(file_path, headers: true) do |row|
        count += 1
        puts row.inspect
        student_tr = "<tr><td>#{row['last_name']}</td><td>#{row['first_name']}</td><td><input type='checkbox' name='student_#{count}'></td><td>#{count}</td></tr>"
        student_trs << student_tr
      end

      table_start = '<table><thead><tr><th>Name</th><th></th><th>Present?</th><th>Number</th></thead><tbody>'
      table_end   = '</tbody></table>'
      table = table_start + student_trs.join('') + table_end
      puts "\n\n\n\n\n TABLE HTML: \n\n\n\n\n"
      puts table
    end
  end
end
