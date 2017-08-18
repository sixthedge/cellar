require 'ims/lti'
require 'oauth/request_proxy/action_controller_request'

module Totem; module Authentication; module Lti
  class RequestHandler

    # ### Totem::Authentication::Lti::RequestHandler
    # ----------------------------------------
    #
    # This class contains all the methods for interpreting and validating params from an LTI request


    # ### Attrs
    attr_reader :params
    attr_reader :request
    attr_reader :options

    attr_accessor :email
    attr_accessor :resource_link_id
    attr_accessor :context_title
    attr_accessor :consumer_key
    attr_accessor :consumer
    attr_accessor :consumer_secret
    attr_accessor :provider
    attr_accessor :resource
    attr_accessor :roles
    attr_accessor :user
  

    # ### Initialization
    def initialize(params, request, options={})
      @params  = params
      @request = request
      @options = options

      raise "No params provided for #{self.inspect}"  unless params.present?
      raise "No request provided for #{self.inspect}" unless request.present?
    end


    # ### Public Methods

    # Validate
    # => Setup the params needed for authentication
    # => Return whether or not the request is valid
    def validate
      @email            ||= get_param_email_primary
      raise_missing_param_error(EMAIL_PRIMARY_KEY)      unless email.present?

      @resource_link_id ||= get_param_resource_link_id
      raise_missing_param_error(RESOURCE_LINK_ID_KEY)   unless resource_link_id.present?

      @consumer_key     ||= get_param_consumer_key
      raise_missing_param_error(OAUTH_CONSUMER_KEY_KEY) unless consumer_key.present?

      @context_title    ||= get_param_context_title

      @consumer         ||= get_consumer
      @consumer_secret  ||= get_consumer_secret
      @provider         ||= get_provider

      is_valid?
    end

    # Process
    # => Validate, setup all appropriate request data, and register contexts
    # => Return self
    def process
      raise RequestValidationError unless validate

      @roles      = get_roles
      @user       = get_or_create_user
      @resource   = get_resource

      register
      self
    end

    # Register
    # => Update the the outcome service url and result sourcedid contexts if present in the params
    def register
      find_or_create_outcome_service_url_context
      find_or_create_result_sourcedid_context
    end

    def is_valid?
      provider.valid_request?(request)
    end

    def is_instructor?
      roles            = get_roles unless roles.present?
      instructor_roles = roles & VALID_INSTRUCTOR_ROLES
      instructor_roles.present?
    end

    def request_validation_error; RequestValidationError; end
    def missing_param_error;      MissingParamError;      end
    def resource_not_found_error; ResourceNotFoundError;  end
    def consumer_not_found_error; ConsumerNotFoundError;  end


    private


    def find_or_create_outcome_service_url_context
      value         = get_param_outcome_service_url
      return unless value.present?
      context       = context_class.find_or_create_by(email: @email, key: OUTCOME_SERVICE_URL_KEY, contextable: space)
      context.value = value
      context.save
    end

    def find_or_create_result_sourcedid_context
      value         = get_param_result_sourcedid
      return unless value.present?
      context       = context_class.find_or_create_by(email: @email, key: RESULT_SOURCEDID_KEY, ownerable: user, contextable: assignment)
      context.value = value
      context.save
    end

    def get_provider
      provider_class.new(consumer_key, consumer_secret, params)
    end

    def get_or_create_user
      user  = user_class.find_by(email: email)
      user  = user_class.create(email: email, first_name: get_param_first_name, last_name: get_param_last_name) unless user.present?
      user.state = 'active'
      user.save
      user
    end

    def get_consumer       
      consumer = consumer_class.find_by(consumer_key: consumer_key)
      raise ConsumerNotFoundError unless consumer.present?
      consumer
    end

    def get_consumer_secret
      consumer.consumer_secret
    end

    def get_resource
      resource = context_class.find_or_create_by(email: @email, key: RESOURCE_LINK_ID_KEY, value: @resource_link_id)
      raise ResourceNotFoundError unless resource.contextable.present?
      resource
    end

    def get_roles
      param_roles = get_param_roles
      raise_missing_param_error(ROLES_KEY) unless param_roles.present?
      return Array.new unless param_roles.present?
      get_param_roles.split(',')
    end


    # ### Param Helpers
    def get_param(key);                params[key];                        end
    def get_param_email_primary;       get_param(EMAIL_PRIMARY_KEY);       end
    def get_param_roles;               get_param(ROLES_KEY);               end
    def get_param_consumer_key;        get_param(OAUTH_CONSUMER_KEY_KEY);  end
    def get_param_context_title;       get_param(CONTEXT_TITLE_KEY);       end
    def get_param_oauth_signature;     get_param(OAUTH_SIGNATURE_KEY);     end
    def get_param_resource_link_id;    get_param(RESOURCE_LINK_ID_KEY);    end
    def get_param_first_name;          get_param(FIRST_NAME_KEY);          end
    def get_param_last_name;           get_param(LAST_NAME_KEY);           end
    def get_param_outcome_service_url; get_param(OUTCOME_SERVICE_URL_KEY); end
    def get_param_result_sourcedid;    get_param(RESULT_SOURCEDID_KEY);    end

    def has_param?(key) get_param(key).present?; end

    def raise_missing_param_error(param)
      raise MissingParamError, "Param #{param} not provided to #{self.inspect}"
    end


    # ### Errors
    class RequestValidationError < StandardError;          end
    class MissingParamError      < RequestValidationError; end
    class ResourceNotFoundError  < StandardError;          end
    class ConsumerNotFoundError  < StandardError;          end


    # ### Classes
    def user_class;     get_platform_class('user');     end
    def context_class;  get_platform_class('context');  end
    def consumer_class; get_platform_class('consumer'); end
    def provider_class; IMS::LTI::ToolProvider;         end

    def get_platform_class(class_name)
      klass = ::Totem::Settings.authentication.current_model_class(self, "#{class_name}_model".to_sym)
      raise "Unknown platform #{class_name} model class for #{self.class.name}."  if klass.blank?
      klass
    end


    # ### Constants
    RESOURCE_LINK_ID_KEY    = 'resource_link_id'
    ROLES_KEY               = 'ext_roles'

    CONTEXT_TITLE_KEY       = 'context_title'

    OAUTH_CONSUMER_KEY_KEY  = 'oauth_consumer_key'
    OAUTH_SIGNATURE_KEY     = 'oauth_signature_key'

    EMAIL_PRIMARY_KEY       = 'lis_person_contact_email_primary'
    FIRST_NAME_KEY          = 'lis_person_name_given'
    LAST_NAME_KEY           = 'lis_person_name_family'
    OUTCOME_SERVICE_URL_KEY = 'lis_outcome_service_url'
    RESULT_SOURCEDID_KEY    = 'lis_result_sourcedid'

    VALID_INSTRUCTOR_ROLES  =
      [ 
        'Instructor',
        'urn:lti:instrole:ims/lis/Instructor',
        'urn:lti:role:ims/lis/Instructor'
      ]

  end
end; end; end
