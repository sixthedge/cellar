namespace :paperclip do
  namespace :aws do
    namespace :s3 do
      task :migrate => [:environment] do |t, args|
        access_key        = Rails.application.secrets.aws['s3']['paperclip']['access_key']
        secret_access_key = Rails.application.secrets.aws['s3']['paperclip']['secret_access_key']
        bucket_name       = Rails.application.secrets.aws['s3']['paperclip']['bucket_name']
        s3                = AWS::S3.new(access_key_id: access_key, secret_access_key: secret_access_key)
        bucket            = s3.buckets[bucket_name]

        bucket.objects.each do |object|
          key  = object.key # /thinkspace/resources/files/files/000/000/092/original/question_WHO_Growth_Chart_W-f-L___H-f-A.pdf
          puts "\n [paperclip:aws:s3:migrate] Parsing [#{key}]"
          next unless key.match(/artifact/) and key.match(/\d+\/\d+\/\d+/)
          id   = key.split('/')[6]
          file = Thinkspace::Artifact::File.where(id: id).first
          next unless file.present?
          file.attachment.reprocess! unless file.attachment.fingerprint.present? # Add fingerprint if it does not exist.
          new_key = file.attachment.path # Get the path based on the new path option from model.
          puts "\n [paperclip:aws:s3:migrate] Copying [#{key}] to [#{new_key}]"
          # aws_new_file = bucket.objects[new_key] # Stage the location to be copied to, e.g.: /files/assignment/:id/:basename-numeric_timestamp.:extension
          # object.copy_to aws_new_file, { acl: :public_read}
        end

      end
    end
  end
end