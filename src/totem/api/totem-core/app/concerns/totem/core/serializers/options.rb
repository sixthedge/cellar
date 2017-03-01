module Totem; module Core; module Serializers; class Options

  include SerializerOptions::Ability
  include SerializerOptions::Associations
  include SerializerOptions::Attributes
  include SerializerOptions::Authorize
  include SerializerOptions::Cache
  include SerializerOptions::CollectData
  include SerializerOptions::Controller
  include SerializerOptions::Debug
  include SerializerOptions::Metadata

  attr_reader :controller
  attr_reader :global_serializer_options
  attr_reader :root_serializer_options
  attr_reader :association_serializer_options
  attr_reader :custom_serializer_options
  attr_reader :default_options
  attr_reader :debug_options

  # ###
  # ### Public custom option getter and setter.  Used by serailzers and controllers and shared by all serializers.
  # ###

  def get(key); custom_serializer_options[key]; end

  def set(key, value)
    custom_serializer_options[key] = value
    get(key) # return the set value
  end

  # ###
  # ### Set ROOT serializer class.
  # ###

  # def set_root_serializer(serializer); root_serializer_options[:serializer_class] ||= serializer.class.name; end
  def set_root_serializer(name); root_serializer_options[:serializer_class] ||= name; end

  # ###
  # ### PRIVATE.
  # ###
  private

  def initialize(controller, defaults={})
    @controller                     = controller
    @global_serializer_options      = HashWithIndifferentAccess.new
    @root_serializer_options        = HashWithIndifferentAccess.new
    @association_serializer_options = HashWithIndifferentAccess.new
    @custom_serializer_options      = HashWithIndifferentAccess.new
    @default_options                = defaults || Hash.new
    @debug_options                  = Hash.new
    error("Default values must be a hash.")  unless default_options.kind_of?(Hash)
    init_collect_data
  end

  # ###
  # ### Helpers.
  # ###

  def is_boolean?(value); value == true || value == false; end

  def element_in_array_ends_with?(array, value)
    return false if array.blank?
    check_value = value.to_s
    array.find {|a| check_value.ends_with?(a.to_s)}.present?
  end

  # ######################################################################################
  # Option methods used by serializers.

  def evaluate_option(serializer, key)
    global_serializer_options[key] || get_serializer_option(serializer, key)
  end

  def evaluate_option_root_first(serializer, key)
    if root_serializer?(serializer)
      value = root_serializer_options[key]
      return value  if value.present?
    end
    evaluate_option(serializer, key)
  end

  def evaluate_array_option(serializer, association_name, key, options={})
    key_all = "#{key}_all".to_sym
    # ###
    # ### global checks
    # ###
    # key_all
    value = global_serializer_options[key_all]
    return value if is_boolean?(value)
    # key_all_except
    key_all_except = "#{key}_all_except".to_sym
    array = global_serializer_options[key_all_except]
    return array.include?(association_name) ? false : true  if array.present?
    # key
    array = global_serializer_options[key]
    return true  if array.present? && array.include?(association_name)
    # ###
    # ### association scope checks
    # ###
    # key_all
    value = get_serializer_option(serializer, key_all)
    return value if is_boolean?(value)
    # key_all_except
    array = get_serializer_option(serializer, key_all_except)
    return array.include?(association_name) ? false : true  if array.present?
    # key
    array = get_serializer_option(serializer, key)
    return true  if array.present? && array.include?(association_name)
    return false if options[:ends_with].blank?
    # ends with check
    return true  if evaluate_array_option_ends_with(serializer, association_name, key)
    # default return value
    false
  end

  def evaluate_array_option_ends_with(serializer, association_name, key)
    key_ends_with = "#{key}_ends_with".to_sym
    array = global_serializer_options[key_ends_with] # global check
    return true if array.present? && element_in_array_ends_with?(array, association_name)
    array = get_serializer_option(serializer, key_ends_with) # association check
    array.present? && array.include?(association_name)
  end

  def evaluate_hash_option(serializer, root_key, key)
    hash  = global_serializer_options[root_key]
    return hash[key] if hash.present? && hash.has_key?(key)
    hash = get_serializer_option(serializer, root_key)
    return hash[key] if hash.present? && hash.has_key?(key)
    nil
  end

  # Get the serializer 'options' whether from root or association.
  def get_serializer_options(serializer)
    return root_serializer_options if root_serializer?(serializer)
    get_association_options(serializer.class.totem_root_name)
  end

  # Get serializer 'option' from root or association.
  def get_serializer_option(serializer, key)
    get_serializer_options(serializer)[key]
  end

  def root_serializer?(serializer)
    return false unless root_serializer_options[:serializer_class] == serializer.class.name
    # (serializer.options[:root_ids] || []).include? serializer.object.id
    (get_serializer_options_hash(serializer)[:root_ids] || []).include? serializer.object.id
  end

  def get_serializer_options_hash(serializer)
    serializer.instance_variable_get(:@instance_options)
  end

  # ######################################################################################
  # Option methods used by controllers.

  def get_default_option(key); default_options[key]; end

  def get_option_hash_for_scope(scope)
    return global_serializer_options  if scope.blank?  # default to global option
    case scope.to_sym
    when (:all || :global)
      global_serializer_options
    when :root
      root_serializer_options
    else
      association_name = scope.to_s.singularize.to_sym
      get_association_options(association_name)
    end
  end

  def get_option_hash_for_scope_and_keys(*args)
    scope = args.shift
    value = get_option_hash_for_scope(scope)
    return Hash.new if value.blank?
    [args].flatten.each do |key|
      value = value[key] || Hash.new
    end
    value
  end

  def set_option_array_values(*args)
    options         = args.extract_options!
    key             = args.shift
    key             = "#{key}_ends_with".to_sym  if options[:ends_with].present?
    scope_hash      = get_option_hash_for_scope(options[:scope])
    scope_hash[key] = (scope_hash[key] || Array.new) + [args].flatten.compact
  end

  def set_option_hash_values(*args)
    options    = args.extract_options!
    root_key   = args.shift
    key        = args.shift
    value      = args.shift
    scope_hash = get_option_hash_for_scope(options[:scope])
    scope_hash[root_key]    ||= Hash.new
    scope_hash[root_key][key] = value
  end

  def set_option_value(*args)
    options         = args.extract_options!
    key             = args.shift
    value           = args.shift
    scope_hash      = get_option_hash_for_scope(options[:scope])
    scope_hash[key] = value
  end

  # Get the association's option values either by an association_name passed
  # by a controller or the serializer's totem_root_name.
  def get_association_options(association_name)
    association_serializer_options[association_name] ||= Hash.new
    association_serializer_options[association_name]
  end

  def error(message)
    raise "#{self.class.name}: #{message}"
  end

end; end; end; end
