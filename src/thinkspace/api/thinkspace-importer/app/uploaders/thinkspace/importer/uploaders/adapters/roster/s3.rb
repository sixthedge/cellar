module Thinkspace; module Importer; module Uploaders; module Adapters; module Roster;
  class S3 < Thinkspace::Common::Uploaders::Adapters::S3
    # Note: Most of the Uploaders will not need all the begin/rescue blocks like this has.
    # => This is primarily because of the roster handling that takes place as part of the file upload process.

    # # Processing
    def confirm
      begin
        f = new_file
        f.save!
        uploader.process_roster(f)
        render_success
      rescue => e
        raise_authorization_error("S3 File [#{f.errors}] could not be saved with: [#{e}].")
      end
    end 

    def file_path_for(file)
      # Note: `file` is not needed for this, since we only currently support individual files to S3.
      path = new_file.paperclip_path
      replace_file_path_part(path, ':filename', name)
    end

    # Note: The `s3_new_file` needs to be intelligent enough to return the correct type, based on the model's Paperclip storage.
    # This enables support for client->S3->API->filesystem.  This is NOT the normal use case, but is intended for development.
    # The path for S3 vs. filesystem should be identical, with `public/` added for the filesystem.
    def new_file
      # When the storage type is filesystem, pull the file from S3 and use the standard `new_file`.
      # => Used in development when a __file_upload component has s3=true, but the store is filesystem.
      case storage_type
      when :filesystem
        uploader.new_file(attachment: url)
      when :s3
        uploader.file_class.new(uploader.file_args.merge({
          attachment_file_name:    name,
          attachment_file_size:    size,
          attachment_content_type: type,
          attachment_updated_at:   Time.now
        }))
      end
    end

  end
end; end; end; end; end