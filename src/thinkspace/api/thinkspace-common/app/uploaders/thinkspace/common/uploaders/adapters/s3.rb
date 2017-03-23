module Thinkspace; module Common; module Uploaders; module Adapters;
  module S3
    extend ::ActiveSupport::Concern
    # # AWS S3
    # Provides support for server to server POSTs with authorization and confirmation.
    # => http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingHTTPPOST.html
    def s3
      secrets           = Rails.application.secrets.aws
      access_key        = secrets.dig('s3', 'paperclip', 'access_key')
      secret_access_key = secrets.dig('s3', 'paperclip', 'secret_access_key')
      region            = secrets.dig('s3', 'paperclip', 'region')
      credentials       = Aws::Credentials.new(access_key, secret_access_key)
      Aws::S3::Resource.new(region: region, credentials: credentials).bucket(s3_bucket)
    end

    def s3_bucket; Rails.application.secrets.aws.dig('s3', 'paperclip', 'bucket_name'); end
    def s3_file_path_for(file); raise_method_error('Method `s3_file_path_for` is not defined in this class.'); end
    def s3_sign_name; params[:name]; end
    def s3_sign_type; params[:type]; end

    def s3_sign
      # The name/type/size are at the root params level due to the way ember-uploader sends them in for signing.
      name = s3_sign_name
      type = s3_sign_type
      raise_authorization_error("Trying to sign with `s3_sign` but multiple files were specified.") unless is_single_file?
      raise_authorization_error("Trying to sign with `s3_sign` but params[:name] is nil.")          unless name.present?
      raise_authorization_error("Trying to sign with `s3_sign` but params[:type] is nil.")          unless type.present?
      response = s3.presigned_post(key: s3_file_path_for(file), success_action_status: '201', content_type: type).fields
      # Bucket needs to be added due to the way that ember-uploader determines the AWS endpoint.
      # => https://github.com/benefitcloud/ember-uploader/issues/125
      response['bucket'] = s3_bucket
      response
    end 

  end
end; end; end; end