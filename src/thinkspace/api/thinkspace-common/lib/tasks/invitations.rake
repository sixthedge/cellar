require 'csv'

namespace :thinkspace do
  namespace :invitations do
    task :send_from_csv, [:file_path] => [:environment] do |t, args|
      file_path = args.file_path
      file_path = File.expand_path("../files/#{file_path}", __FILE__)
      puts "[thinkspace::invitations] Loading file from: [#{file_path}]"
      invitations = []
      CSV.foreach(file_path, headers: true) do |row|
        data = {}
        row.headers.each do |header|
          # If the header is something like settings:role, put it in data[settings][role]
          # => Else, store as a root key.
          if header.include?(':')
            header_parts = header.split(':')
            key = header_parts.shift
            subkey = header_parts.shift
            data[key] ||= {}
            data[key][subkey] = row[header]
          else
            data[header] = row[header]
          end
        end
        invitations << data
      end
      puts Rails.application.secrets.aws.inspect
      sqs   = AWS::SQS.new(access_key_id: Rails.application.secrets.aws['sqs']['access_key'], secret_access_key: Rails.application.secrets.aws['sqs']['secret_access_key'])
      queue = sqs.queues.named(Rails.application.secrets.aws['sqs']['queue_name'])
      puts "[thinkspace::invitations] Processing invitations against queue: #{queue.inspect}"
      invitations.each do |invitation|
        invitation[:expires_at] = Time.now + 30.days
        puts "[thinkspace::invitations] Sending message of: #{invitation.to_json}"
        queue.send_message(invitation.to_json)
      end

    end
  end
end
