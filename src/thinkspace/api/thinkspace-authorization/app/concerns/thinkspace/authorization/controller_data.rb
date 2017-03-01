module Thinkspace; module Authorization; module ControllerData

  public

  def get_serializer_options; serializer_options; end

  private

  def get_data_name; data_name; end

  def auth;           params[:auth]; end
  def source;         auth[:source]; end
  def source_method;  auth[:source_method]; end

  def record_data?; auth[:model_type].present? && auth[:model_id].present?; end

  def get_data
    access_denied "Controller data_name is blank."  if get_data_name.blank?
    case
    when record_data?     then get_record_data
    when source.present?  then get_source_data
    else
      access_denied "#{get_data_name} module record data is blank and sub action is blank."
    end
  end

  def get_source_data
    path   = source
    mod    = get_serializer_options_module(path)
    method = get_source_method(path)
    access_denied "#{get_data_name} module #{mod.name.inspect} does not respond to #{method.to_s.inspect} for source #{path.inspect}."  unless mod.respond_to?(method)
    ownerable = get_ownerable
    mod.send method, self, ownerable
  end

  def get_record_data
    record   = get_data_record
    authable = record.respond_to?(:authable) ? record.authable : record
    access_denied "#{get_data_name} cannot read authable for record #{record.class.name.inspect} id #{record.id}."  unless can?(:read, authable)
    path   = source.present? ? source : record.class.name.underscore.pluralize
    mod    = get_serializer_options_module(path)
    method = get_source_method(path.singularize)
    access_denied "#{get_data_name} module #{mod.name.inspect} does not respond to #{method.to_s.inspect} for source #{path.inspect}."  unless mod.respond_to?(method)
    ownerable = get_ownerable
    mod.send method, self, record, ownerable
  end

  # ###
  # ### Helpers.
  # ###

  def get_source_method(path)
    method = source_method.present? ? source_method : path.camelize.demodulize.downcase
    "#{get_data_name}_#{method}"
  end

  def get_serializer_options_module(path)
    namespace, const = get_path_parts(path)
    mod_name         = "#{namespace}::Concerns::SerializerOptions::#{const}"
    mod              = mod_name.safe_constantize
    access_denied "#{get_data_name} module #{mod_name.inspect} cannot be constantized."  if mod.blank?
    mod
  end

  def get_path_parts(path)
    name = path.camelize
    [name.deconstantize, name.demodulize]
  end

  def get_ownerable;   get_record_by_type_and_id(:ownerable); end
  def get_data_record; get_record_by_type_and_id(:model); end

  def get_record_by_type_and_id(key)
    type = auth["#{key}_type"]
    id   = auth["#{key}_id"]
    access_denied "#{key.inspect} type is blank."  if type.blank?
    access_denied "#{key.inspect} id is blank."    if id.blank?
    model_class_name = type.classify
    model_class      = model_class_name.safe_constantize
    access_denied "Cannot constantize class #{model_class_name.inspect}"  if model_class.blank?
    record = model_class.find_by(id: id)
    access_denied "#{key} #{model_class_name}.#{id} not found." if record.blank?
    record
  end

  def access_denied(message, user_message='')
    action = (self.action_name || '').to_sym
    model  = "thinkspace/authorization/#{get_data_name}".classify
    raise_access_denied_exception(message, action, model,  user_message: user_message)
  end

end; end; end
