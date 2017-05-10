module Thinkspace; module Common; module Uploaders; module Adapters;
  class S3
    # # AWS S3
    # Provides support for server to server POSTs with authorization and confirmation.
    # => http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingHTTPPOST.html
    attr_reader :uploader, :s3

    # # Constructor
    def initialize(uploader)
      @uploader = uploader
      @s3       = set_s3
    end

    # # Processing
    def sign
      # The name/type/size are at the root params level due to the way ember-uploader sends them in for signing.
      name = sign_name
      type = sign_type
      raise_authorization_error("[S3] Trying to sign with `sign` but multiple files were specified.") unless is_single_file?
      raise_authorization_error("[S3] Trying to sign with `sign` but params[:name] is nil.")          unless name.present?
      raise_authorization_error("[S3] Trying to sign with `sign` but params[:type] is nil.")          unless type.present?
      response = s3.presigned_post(key: file_path_for(file), success_action_status: '201', content_type: type).fields
      # Bucket needs to be added due to the way that ember-uploader determines the AWS endpoint.
      # => https://github.com/benefitcloud/ember-uploader/issues/125
      response['bucket'] = bucket
      response
    end 

    # # Helpers
    def set_s3
      secrets           = Rails.application.secrets.aws
      access_key        = secrets.dig('s3', 'paperclip', 'access_key')
      secret_access_key = secrets.dig('s3', 'paperclip', 'secret_access_key')
      region            = secrets.dig('s3', 'paperclip', 'region')
      credentials       = Aws::Credentials.new(access_key, secret_access_key)
      Aws::S3::Resource.new(region: region, credentials: credentials).bucket(bucket)
    end

    def bucket; Rails.application.secrets.aws.dig('s3', 'paperclip', 'bucket_name'); end
    def file_path_for(file); raise_method_error('[S3] Method `file_path_for` is not defined in this class.'); end

    # ## Params helpers
    def sign_name;      name;                         end
    def sign_type;      type;                         end
    def name;           params[:name];                end
    def size;           params[:size];                end
    def type;           params[:type];                end
    def url;            URI.decode(params_aws[:url]); end
    def params_aws;     params[:aws];                 end

    # # Delegations
    delegate :params,                    to: :uploader
    delegate :files,                     to: :uploader
    delegate :file,                      to: :uploader
    delegate :authable,                  to: :uploader
    delegate :ownerable,                 to: :uploader
    delegate :user,                      to: :uploader
    delegate :single,                    to: :uploader
    delegate :current_ability,           to: :uploader
    delegate :current_user,              to: :uploader
    delegate :raise_method_error,        to: :uploader
    delegate :raise_authorization_error, to: :uploader
    delegate :render_success,            to: :uploader
    delegate :render_failure,            to: :uploader
    delegate :storage_type,              to: :uploader
    delegate :replace_file_path_part,    to: :uploader
    delegate :is_single_file?,           to: :uploader

  end
end; end; end; end
