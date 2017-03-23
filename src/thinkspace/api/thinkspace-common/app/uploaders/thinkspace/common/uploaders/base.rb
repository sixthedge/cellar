module Thinkspace; module Common; module Uploaders;
  class Base
    attr_reader :params, :files, :uploader_type, :authable, :ownerable, :params_uploader
    attr_reader :context, :user, :single, :current_ability, :current_user

    include Adapters::S3

    # # Constructor
    def initialize(params, user, context=nil)
      @params  = params
      @user    = user
      @context = context
      initialize_params
    end

    # # Processing
    def upload; raise_method_error('The `upload` method has not been defined for this class.'); end
    def confirm
      case adapter
      when 's3'
        raise_method_error('The `s3_confirm` method has not been defined for this class.') unless self.respond_to?(:s3_confirm)
        s3_confirm
      else
        raise_method_error("Adapter [#{adapter}] did not have a confirm method specified.")
      end
    end

    # # Authorization
    def authorize!; raise_method_error('The `authorize!` method has not been defined for this class.'); end

    # # Params
    def initialize_params
      @files         = Array.wrap(params[:files])
      @single        = true if @files.length == 0
      @uploader_type = params_uploader[:type]
      @authable      = params_uploader_authable
      @ownerable     = params_uploader_ownerable
    end

    def params_uploader_record(type)
      return nil unless params_uploader.has_key?(type)
      id   = params_uploader[type][:id]
      type = params_uploader[type][:type]
      return nil unless id.present? && type.present?
      klass = type.classify.safe_constantize
      raise_params_record_error("Type [#{type}] was unable to constantize.") unless klass.present?
      record = klass.find_by(id: id)
      raise_params_record_error("Record [#{type}] for id [#{id}] could not be found.") unless record.present?
      record
    end

    def params_uploader_authable;  params_uploader_record('authable'); end
    def params_uploader_ownerable; params_uploader_record('ownerable'); end
    def params_uploader;  @params_uploader ||= JSON.parse(params[:uploader]).with_indifferent_access; end

    # # Signing
    # Used for server to server POST (e.g. client -> AWS).
    # => http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingHTTPPOST.html
    def adapter; 's3'; end

    # Allow for multiple signing types (e.g. Google Developer Storage)
    # => Only supporting AWS out of the box.
    def sign
      case adapter
      when 's3'
        raise_method_error('The `s3_sign` method has not been defined for this class.') unless self.respond_to?(:s3_sign)
        s3_sign 
      end
    end

    # # Rendering
    def render_success; {success: true}; end
    def render_failure; {success: false}; end

    # # Helpers
    def file; files.first; end
    def is_single_file?; single; end

    def current_user
      return context.current_user if context.respond_to?(:current_user)
      @current_user ||= user
    end

    def current_ability
      return context.current_ability if context.respond_to?(:current_ability)
      @current_ability ||= Thinkspace::Authorization::Ability.new(current_user)
    end

    def replace_file_path_part(path, part, value)
      path.gsub!(/#{part}/, value)
    end   

    # # Errors
    def raise_params_record_error(message=''); raise Exceptions::ParamsRecordError, message; end
    def raise_authorization_error(message=''); raise Exceptions::AuthorizationError, message; end
    def raise_method_error(message=''); raise Exceptions::MethodNotImplementedError, message; end
  end

end; end; end