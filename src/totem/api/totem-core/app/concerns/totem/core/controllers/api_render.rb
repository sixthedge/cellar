module Totem; module Core; module Controllers; module ApiRender

  # ###
  # ### Controller's render or head method.
  # ###

  def controller_render_json(json, options={})
    options[:json] ||= json
    render options
  end

  def controller_render_no_content; head :no_content; end

  def controller_render_error(record, options={})
    defaults = {
      status:     422,
      adapter:    :json_api,
      serializer: ::Totem::Settings.classes.totem.error_serializer,
      json:       record,
    }
    render defaults.merge(options)
  end

  # ###
  # ### API controller methods for saving, destroying and rendering.
  # ###

  def controller_save_record(record, options={})
    record.save ? controller_render(record, options) : controller_render_error(record)
  end

  def controller_destroy_record(record, options={})
    record.destroy ? controller_render_no_content : controller_render_error(record)
  end

  # Serialize a single record (can be an array) into an array with the pluralized root path.
  def controller_render_plural_root(records, options={}); controller_render(records, options.merge(plural_root: true)); end

  def controller_render_view(record, options={}); controller_render(record, options.merge(view: true)); end

  def controller_render(records, options={})
    json = controller_json(records, options)
    controller_after_json(json, options)  if controller_after_json?
    controller_render_json(json, options)
  end

  # ###
  # ### Main method to generate the json.
  # ###

  def controller_json(records, options={})
    case
    when controller_collect_data_only?  then controller_collect_only_data_json(records, options)
    when controller_paginated?          then controller_paginated_json(records, options)
    when controller_cache?              then controller_cache_json(records, options)
    else                                controller_call_json_method(records, options)
    end
  end

  def controller_collect_data_only?; serializer_options_defined? && serializer_options.collect_only?; end

  # ###
  # ### Return the record(s) json hash.
  # ###

  def controller_call_json_method(records, options)
    case
    when (method = options[:json_method]).present?
      controller_raise_error "Controller does not respond to json method [#{method}]." unless self.respond_to?(method, true)
      self.send(method)
    when options[:view] == true
      controller_view_json(records, options)
    else
      controller_as_json(records, options)
    end
  end

  # Returns json hash.
  def controller_as_json(records, options={})
    serializer = controller_get_serializer_class(records, options)
    serializer.totem_serialize_as_json records, controller_default_serializer_options(options)
  end

  # Returns json hash for a controller 'view' action.
  # Record data set to empty array.
  def controller_view_json(record, options={})
    delete_keys = [options[:delete]].flatten.compact
    json        = controller_as_json(record, options)
    json[:data] = Array.new  # remove the base record value for a view
    return json if delete_keys.blank?
    included = Array.new
    (json[:included] || Array.new).each do |hash|
      type = hash[:type] || ''
      included.push(hash) unless delete_keys.find {|k| type.to_s.end_with?(k.to_s)}.present?
    end
    json[:included] = included
    json
  end

  # ###
  # ### Collect Data.
  # ###

  # Returns only the collect data in the json e.g. ability, metadata.
  def controller_collect_only_data_json(records, options={})
    controller_call_json_method(records, options)
    serializer_options.collect_module_data
    controller_add_collect_data_to_json(serializer_options.collect_keys, Hash.new)
  end

  def controller_add_collect_data_to_json(keys, json)
    return unless serializer_options.collect_data_exists?
    keys.each do |key|
      method = "controller_#{key}_add_to_json".to_sym
      self.send(method, json) if self.respond_to?(method)
    end
    json
  end

  # ###
  # ### Helpers
  # ###

  def controller_default_serializer_options(options)
    options[:scope] = controller_serializer_scope(options)  unless options.has_key?(:scope)
    options
  end

  # Create a serializer scope that does not depend on a view context.  A step to make an api only server.
  # e.g. remove need for: options[:scope] = view_context
  def controller_serializer_scope(options)
    scope                    = ActiveSupport::OrderedOptions.new
    scope.current_user       = current_user
    scope.current_ability    = current_ability
    scope.serializer_options = serializer_options
    scope
  end

  def controller_serializer_scope_add_totem_action_authorize_values(scope)
    return unless self.respond_to?(:totem_action_authorize)
    scope.record_authable  = totem_action_authorize.record_authable
    scope.params_authable  = totem_action_authorize.params_authable
    scope.record_ownerable = totem_action_authorize.record_ownerable
    scope.params_ownerable = totem_action_authorize.params_ownerable
  end

  def controller_get_serializer_class(records, options)
    unless (class_name = options[:serializer]).present?
      render_record = records.respond_to?(:to_ary) ? records.first : records
      class_name    = render_record.present? ? render_record.class.name : controller_model_class_name
      class_name   += 'Serializer'
    end
    serializer = class_name.safe_constantize
    controller_raise_error "Cannot constantize model serializer name [#{class_name}]"  if serializer.blank?
    serializer
  end

  def controller_model_class_name
    self.class.totem_controller_model_class
  end

  def controller_model_class
    class_name = controller_model_class_name
    klass      = class_name.safe_constantize
    controller_raise_error "Cannot constantize controller model class name [#{class_name}]"  if klass.blank?
    klass
  end

  def controller_singular_path; controller_model_class_name.underscore; end
  def controller_plural_path;   controller_singular_path.pluralize; end

  def controller_debug_message(message=''); puts "[debug] #{message}"; end

  def serializer_options_defined?; defined?(serializer_options); end

  def controller_ability_class_name; controller_ability_class.name; end

  def controller_ability_class
    @_controller_ability_class ||= begin
      ability_class = ::Totem::Settings.authorization.current_ability_class(self)
      controller_raise_error "Ability class is blank."  if ability_class.blank?
      ability_class
    end
  end

  # ### Module availability check.  Will be overridden by module if included.
  def controller_cache?;      false; end
  def controller_paginated?;  false; end
  def controller_after_json?; false; end
  # ###

  include ApiRender::Cache
  include ApiRender::Paginate
  include ApiRender::JsonApiIncluded
  include ApiRender::Ability
  include ApiRender::Metadata
  include ApiRender::AfterJson
  include ApiRender::Message

  def controller_raise_error(message)
    raise ControllerRenderError, message
  end

  class ControllerRenderError < StandardError; end

end; end; end; end
