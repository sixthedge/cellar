module Thinkspace; module Importer; module Uploaders; module Adapters; module Roster;
  module S3
    extend ::ActiveSupport::Concern
    # Note: Most of the Uploaders will not need all the begin/rescue blocks like this has.
    # => This is primarily because of the roster handling that takes place as part of the file upload process.

    # # Processing
    def s3_confirm
      begin
        f = s3_new_file
        f.save!
        process_roster(f)
        render_success
      rescue => e
        raise_authorization_error("S3 File [#{f.errors}] could not be saved with: [#{e}].")
      end
    end 

    # Note: The `s3_new_file` needs to be intelligent enough to return the correct type, based on the model's Paperclip storage.
    # This enables support for client->S3->API->filesystem.  This is NOT the normal use case, but is intended for development.
    # The path for S3 vs. filesystem should be identical, with `public/` added for the filesystem.
    def s3_new_file
      # When the storage type is filesystem, pull the file from S3 and use the standard `new_file`.
      # => Used in development when a __file_upload component has s3=true, but the store is filesystem.
      case storage_type
      when :filesystem
        new_file(attachment: s3_url)
      when :s3
        file_class.new(file_args.merge({
          attachment_file_name:    s3_name,
          attachment_file_size:    s3_size,
          attachment_content_type: s3_type,
          attachment_updated_at:   Time.now
        }))
      end
    end

    # # Helpers
    def s3_file_path_for(file)
      # Note: `file` is not needed for this, since we only currently support individual files to S3.
      path = new_file.paperclip_path
      replace_file_path_part(path, ':filename', s3_name)
    end

    def s3_params; params[:aws];  end
    def s3_name;   params[:name]; end
    def s3_size;   params[:size]; end
    def s3_type;   params[:type]; end
    def s3_url;    URI.decode(s3_params[:url]); end

  end
end; end; end; end; end