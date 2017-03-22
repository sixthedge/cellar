module Thinkspace; module Common; module Uploaders;
  class Base
    attr_reader :params, :files, :upload_type, :authable, :ownerable
    attr_reader :context, :user, :single, :current_ability, :current_user

    def initialize(params, user, context=nil)
      @params  = params
      @user    = user
      @context = context
      initialize_params
    end

    # # Processing
    def upload
      raise Exceptions::MethodNotImplementedError, "The `upload` method has not been defined for this class."
    end

    # # Authorize
    def authorize!
      raise Exceptions::MethodNotImplementedError, "The `authorize!` method has not been defined for this class."
    end

    # # Params
    def initialize_params
      @files       = Array.wrap(params[:files])
      @single      = true if @files.length == 0
      @upload_type = params[:upload_type]
      @authable    = params_authable
      @ownerable   = params_ownerable
    end

    def params_record(type)
      id   = params["#{type}_id"]
      type = params["#{type}_type"]
      return nil unless id.present? && type.present?
      klass = type.classify.safe_constantize
      raise_params_record_error("Type [#{type}] was unable to constantize.") unless klass.present?
      record = klass.find_by(id: id)
      raise_params_record_error("Record [#{type}] for id [#{id}] could not be found.") unless record.present?
      record
    end

    def params_authable; params_record('authable'); end
    def params_ownerable; params_record('ownerable'); end

    # # AWS S3
    # Provides support for server to server POSTs with authorization and confirmation.
    # => http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingHTTPPOST.html
    def aws_s3_bucket; Rails.application.secrets.aws.dig('s3', 'paperclip', 'bucket_name'); end
    def aws_s3; Aws::S3::Resource.new.bucket(aws_s3_bucket); end
    def aws_sign
      name = params[:name]
      raise_authorization_error("Trying to sign with `aws_sign` but params[:name] is nil.") unless name.present?
      response = aws_s3.presigned_post(key: "uploads/#{name}", success_action_status: '201').fields
      # Bucket needs to be added due to the way that ember-uploader determines the AWS endpoint.
      # => https://github.com/benefitcloud/ember-uploader/issues/125
      response['bucket'] = aws_s3_bucket
      response
    end

    # # Signing
    # Used for server to server POST (e.g. client -> AWS).
    # => http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingHTTPPOST.html
    def sign_type; 'aws'; end

    # Allow for multiple signing types (e.g. Google Developer Storage)
    # => Only supporting AWS out of the box.
    def sign
      case sign_type
      when 'aws'
        aws_sign
      end
    end

    # # Helpers
    def file; files.first; end

    def current_user
      return context.current_user if context.respond_to?(:current_user)
      @current_user ||= user
    end

    def current_ability
      return context.current_ability if context.respond_to?(:current_ability)
      @current_ability ||= Thinkspace::Authorization::Ability.new(current_user)
    end

    # # Errors
    def raise_params_record_error(message=''); raise Exceptions::ParamsRecordError, message; end
    def raise_authorization_error(message=''); raise Exceptions::AuthorizationError, message; end
  end

end; end; end