class Test::Casespace::Route

  include ::Test::Casespace::Models::ModelClasses
  include ::Test::Casespace::Models::ModelSave

  attr_reader :options
  attr_reader :action
  attr_reader :helper
  attr_reader :type
  attr_reader :verb
  attr_reader :test_it_name
  attr_reader :controller_path
  attr_reader :request_options

  attr_reader :dictionary
  attr_reader :model
  attr_reader :user_type

  attr_reader :error_classes
  attr_reader :error_messages

  attr_reader :unauthorized_messages

  def initialize(options={})
    @action               = options[:action]
    @helper               = options[:helper]  # route helper method name
    @type                 = options[:type]
    @verb                 = options[:verb]
    @controller_path      = options[:controller_path]
    @test_it_name         = options[:test_it_name]
    @options              = options[:options] || {}
    @assert_raise_error   = false
    @assert_unauthorized  = false
    @error_classes        = Array.new
  end

  # ###
  # ### Route Actions.
  # ###

  def member?;     type == :member; end
  def collection?; type == :collection; end
  
  def show?;     action == :show;     end
  def view?;     action == :view;     end
  def create?;   action == :create;   end
  def select?;   action == :select;   end
  def update?;   action == :update;   end
  def destroy?;  action == :destroy;  end
  def sign_in?;  action == :sign_in;  end
  def validate?; action == :validate; end

  def view_action?; @view_action.present? || view?; end
  def view_action;  @view_action = true; end

  # ###
  # ### Base Route Model.
  # ###

  def set_model(model); @model = model; end
  def model_id; (model.present? && model.id) || ''; end

  # ###
  # ### Users & User Types.
  # ###

  def set_as_reader;                @user_type = :reader; end
  def set_as_updater;               @user_type = :updater; end
  def set_as_owner;                 @user_type = :owner; end
  def set_as_unauthorized_reader;   @user_type = :unauthorized_reader; end
  def set_as_unauthorized_updater;  @user_type = :unauthorized_updater; end
  def set_as_unauthorized_owner;    @user_type = :unauthorized_owner; end
  def reader?;                user_type == :reader; end
  def updater?;               user_type == :updater; end
  def owner?;                 user_type == :owner; end
  def unauthorized_reader?;   user_type == :unauthorized_reader; end
  def unauthorized_updater?;  user_type == :unauthorized_updater; end
  def unauthorized_owner?;    user_type == :unauthorized_owner; end

  def authorized?;   reader? || updater? || owner?; end
  def unauthorized?; unauthorized_reader? || unauthorized_updater? || unauthorized_owner?; end

  def can_update?;              can_update_authorized? || can_update_unauthorized?; end
  def can_update_authorized?;   updater? || owner?; end
  def can_update_unauthorized?; unauthorized_updater? || unauthorized_owner?; end

  # ###
  # ### Admin Routes. e.g. have /admin/ in controller path and/or custom other route matches.
  # ###

  def admin?; is_config_options_admin_match?; end

  # ###
  # ### Controller Raise Error & Unauthorized Helpers.
  # ###

  def assert_authorized?; @assert_authorized.present?; end
  def assert_authorized(match_messages=nil); @assert_authorized = true; end

  def assert_unauthorized?; @assert_unauthorized.present?; end
  def assert_unauthorized(match_messages=nil)
    @assert_unauthorized   = true
    @unauthorized_messages = Array(match_messages).compact
  end

  def assert_raise_error?; @assert_raise_error.present?; end
  def assert_raise_errors(error_classes, match_messages=nil); set_error_values(error_classes, match_messages); end
  def assert_raise_any_error(match_messages=nil);             set_error_values(nil, match_messages); end

  # ###
  # ### Params.
  # ###

  def include_model_in_params?; @include_model_in_params.present?; end
  def include_model_in_params;  @include_model_in_params = true; end

  def get_request_options; request_options || Hash.new; end
  def get_params;      get_request_options[:params] || Hash.new; end
  def get_params_auth; get_request_options[:auth] || Hash.new; end

  def set_params(key, value); get_params[key] = value; end
  def set_params_sub_action(sub_action); get_params_auth[:sub_action] = sub_action; end

  def get_model_params_value(key);            get_model_params[key]; end
  def set_model_params_value(key, value=nil); get_model_params[key] = value; end

  def get_model_params
    return Hash.new if model.blank?
    get_params[model_to_path] || Hash.new
  end

  # ###
  # ### Controller Requests.
  # ###

  def print_params?; @print_params.present?; end
  def print_params;  @print_params = true; end
  def print_json?;   @print_json.present?; end
  def print_json;    @print_json = true; end

  # ###
  # ### Model Dictionary.
  # ###

  def print_dictionary?;     @print_dictionary.present?; end
  def print_dictionary;      @print_dictionary = true; end

  def print_dictionary_ids?; @print_dictionary_ids.present?; end
  def print_dictionary_ids;  @print_dictionary_ids = true; end

  def dictionary_user;        dictionary_model(user_class); end
  def dictionary_space;       dictionary_model(space_class); end
  def dictionary_assignment;  dictionary_model(assignment_class); end
  def dictionary_phase;       dictionary_model(phase_class); end
  def dictionary_phase_state; dictionary_model(phase_state_class); end

  def dictionary_model(model_class); (dictionary || Hash.new)[model_class]; end

  def add_model_to_dictionary(model)
    raise "Cannot add model #{model_class.inspect} to the dictionary.  Dictionary is blank."  if dictionary.blank?
    raise "Cannot add model #{model_class.inspect} to the dictionary.  Model is blank."  if model.blank?
    raise "Model for class #{model_class.inspect} already exists."  if dictionary.has_key?(model.class)
    dictionary[model.class] = model
  end

  def model_to_path(model_for_path=model)
    model_for_path.class.name.underscore
  end

  # ###
  # ### Call Controller Helper Methods.
  # ###

  def include_controller_helpers?; options[:include_controller_helpers] != false; end

  # Setup typically defines conditional test values so must be run before the test (e.g. 'it')
  def setup; send_helper_method(:setup); end

  def before_save(dictionary, options); @dictionary = dictionary; send_helper_method(:before_save, options); end

  def after_save(options); send_helper_method(:after_save, options); end

  def params(options); send_helper_method(:params, options); end

  private

  def controller_helper_instance
    @controller_helper_instance ||= begin
      ns = options[:controller_helper_namespace]
      return nil if ns.blank?
      ns    = ns.to_s
      ns    = '::' + ns  unless ns.start_with?('::')  # ensure from root namespace
      ns   += '::'       unless ns.end_with?('::')
      name  = ns.camelize + controller_path.camelize
      klass = name.safe_constantize
      klass.blank? ? nil : klass.new
    end
  end

  def send_helper_method(method, options={})
    @request_options ||= options  if method != :setup
    helper_method = get_controller_helper_method(method)
    return if helper_method.blank?
    num_args = controller_helper_instance.method(helper_method).arity
    num_args == 1 ? controller_helper_instance.send(helper_method, self) : controller_helper_instance.send(helper_method, self, options)
  end

  def controller_helper_method?(helper_method); controller_helper_instance.respond_to?(helper_method); end

  def get_controller_helper_method(method)
    # Method value will be setup, before_save, after_save or params.
    return nil unless include_controller_helpers?
    return nil if controller_helper_instance.blank?

    if user_type.present?
      # Most specific user type method e.g. setup_show_reader, setup_show_unauthorized_reader.
      helper_method = "#{method}_#{action}_#{user_type}".to_sym
      return helper_method if controller_helper_method?(helper_method)
      # Less specific user type method e.g. setup_reader, setup_unauthorized_reader
      helper_method = "#{method}_#{user_type}".to_sym
      return helper_method if controller_helper_method?(helper_method)
      # More generic update methods.
      if can_update?
        # The 'can_update_...' methods include both updaters and owners.
        if authorized?
          # Most specific update methods e.g. setup_show_can_update_authorized
          helper_method = "#{method}_#{action}_can_update_authorized".to_sym
          return helper_method if controller_helper_method?(helper_method)
          # Less specific update methods e.g. setup_can_update_authorized
          helper_method = "#{method}_can_update_authorized".to_sym
          return helper_method if controller_helper_method?(helper_method)
        else
          # Most specific update methods e.g. setup_show_can_update_unauthorized
          helper_method = "#{method}_#{action}_can_update_unauthorized".to_sym
          return helper_method if controller_helper_method?(helper_method)
          # Less specific update methods e.g. setup_can_update_unauthorized
          helper_method = "#{method}_can_update_unauthorized".to_sym
          return helper_method if controller_helper_method?(helper_method)
        end
        # 'can_update?' includes authorized and unauthorized updaters and owners.
        # More generic update method e.g. setup_show_can_update
        helper_method = "#{method}_#{action}_can_update".to_sym
        return helper_method if controller_helper_method?(helper_method)
        # Most generic update method e.g. setup_can_update
        helper_method = "#{method}_can_update".to_sym
        return helper_method if controller_helper_method?(helper_method)
      end
    end
    # Least specific methods e.g. setup_show, setup
    helper_method = "#{method}_#{action}".to_sym
    return helper_method if controller_helper_method?(helper_method)
    helper_method = "#{method}".to_sym
    return helper_method if controller_helper_method?(helper_method)
    nil
  end

  def is_config_options_admin_match?
    not_admin_array = get_options_key_array(:not_admin_match)
    return false if not_admin_array.present? && is_config_options_match?(not_admin_array)
    admin_array = get_options_key_array(:admin_match) + ['api/admin']
    is_config_options_match?(admin_array)
  end

  def is_config_options_match?(array)
    match = false
    array.each do |value|
      case
      when value.is_a?(String) || value.is_a?(Symbol)
        match = controller_path.match(value.to_s)
      when value.is_a?(Hash)
        c_match = value[:controller] || ''
        actions = [value[:actions]].flatten.compact.map {|a| a.to_sym}
        match   = controller_path.match(c_match.to_s) && actions.include?(action)
      else
        raise "Unknown admin match value #{value.inspect}.  Must be a string, symbol or hash."
      end
      return true if match.present?
    end
    false
  end

  def get_options_key_array(key); [options[key]].flatten.compact; end

  def set_error_values(error_classes, match_messages)
    @assert_raise_error = true
    @error_classes      = Array(error_classes).compact
    @error_messages     = Array(match_messages).compact
  end

end
