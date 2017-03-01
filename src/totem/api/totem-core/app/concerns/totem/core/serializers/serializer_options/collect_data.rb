module Totem; module Core; module Serializers; module SerializerOptions; module CollectData

  # ###
  # ### CONTROLLER - Set Options.
  # ###

  # Collect all record data (e.g. ability, metadata, etc.) but don't serialize the record itself.
  # Only adds data for the base record(s).
  def collect_only;  @collect_only_keys = collect_keys.uniq; end

  # Return whether have any collect_data or collect_module.
  def collect_exists?; collect_data_exists? || collect_module_exists?; end

  # ###
  # ### SERIALIZER.
  # ###

  def skip_collect_ability?; collect_only_keys.present? && !collect_only_keys.include?(ability_key); end

  def skip_collect_association?(association_name)
    return false if collect_only_keys.blank? # not collecting only record data (e.g. serializing records) so include it
    options  = get_association_options(association_name)
    only_key = [collect_options_keys.values].flatten.find {|key| options.has_key?(key)}
    only_key.blank?
  end

  # ###
  # ### Serializer/Controller Helpers.
  # ###

  def collect_data_ownerable
    return cache_ownerable  if cache_ownerable?
    return current_user     unless totem_action_authorize?
    record_ownerable || params_ownerable || current_user
  end

  def collect_only?;        collect_only_keys.present?; end

  def collect_data_exists?;   collect_data.present?; end
  def collect_module_exists?; collect_module.present?; end

  def collect_cache_key_options_exists?; collect_cache_key_options.present?; end

  def collect_only_keys_exist?; collect_only_keys.present?; end

  def clear_collect_data_for(key); collect_data.delete(key); end

  # Used only in tests.  Clear collect data to appear as a new request.
  def clear_collect_data; @collect_data = Hash.new; @collect_module = Hash.new; end
  def clear_collect_cache_key_options; @collect_cache_key_options = Hash.new; end

  # ###
  # ### SerializerOptions Helpers (e.g. called by other serailizer_options methods).
  # ###

  def collect_for(key, options_key, options)
    add_collect_key(key)
    (collect_options_keys[key] ||= Array.new).push(options_key)
    add_collect_cache_key_options(key, options_key, options)
  end

  def collect_for_module(key, hash)
    add_collect_key(key)
    mod_hash = validate_and_standardize_collect_module_hash(key, hash)
    (collect_module[key] ||= Array.new).push(mod_hash)
    add_collect_cache_key_options(key, :module, mod_hash)
  end

  def collect_only_for(key); add_collect_only_key(key); end

  # ###
  # ### Record JSON Data Collection e.g. abilities, metadata, etc.
  # ###

  attr_reader :collect_data
  attr_reader :collect_keys
  attr_reader :collect_module
  attr_reader :collect_only_keys
  attr_reader :collect_options_keys
  attr_reader :collect_cache_key_options

  def init_collect_data
    @collect_data              = Hash.new
    @collect_module            = Hash.new
    @collect_options_keys      = Hash.new
    @collect_cache_key_options = Hash.new
    @collect_keys              = Array.new
    @collect_only_keys         = Array.new
  end

  def get_collect_data_for(key); (collect_data[key] ||= Array.new); end

  def add_collect_key(key);      collect_keys.push(key)      unless collect_keys.include?(key); end
  def add_collect_only_key(key); collect_only_keys.push(key) unless collect_only_keys.include?(key); end

  def get_collect_cache_key_options_for(key); (collect_cache_key_options[key] ||= Array.new); end

  def add_collect_cache_key_options(key, options_key, hash)
    get_collect_cache_key_options_for(key).push(hash.merge(options_key: options_key))
  end

  # ###
  # ### Collect Data for Records and Modules.
  # ###

  def serialize_record_data?; collect_keys.present? || collect_only_keys.present?; end

  # 'active_model_serializers' evaluates whether to include abilities and sets the abilities hash.
  # 'active_model_serializers' will set the abilities to nil if 'metadata_only?' e.g. skips processing the abilities.
  # 'serialize_record_data?' is a high level check to determine if either an ability or metadata method has been called.
  def collect_record_data(serializer, abilities)
    return unless serialize_record_data?
    record = serializer.object
    return if record.blank?
    keys = collect_only_keys.present? ? collect_only_keys : collect_keys
    collect_record_data_for_keys(serializer, keys, record, abilities)
  end

  def collect_record_data_for_keys(serializer, keys, record, abilities)
    return if keys.blank?
    keys.each do |key|
      next unless collect_key_record_data?(serializer, key)
      data = nil
      if key == :ability
        data = abilities
      else
        method = "serializer_#{key}".to_sym
        if record.respond_to?(method, true)
          data = record.send(method, collect_data_ownerable, self)
        end
      end
      next if data.blank?
      data_array = get_collect_data_for(key)
      data_array.push id: record.id, type: record.class.name.underscore, data: data
    end
  end

  # Evaluate the option_keys for the data (e.g. :ability, :metadata) to see if the serializer_options scope includes
  # this serializer e.g. :include_ability, :include_metadata.
  def collect_key_record_data?(serializer, key)
    option_keys = collect_options_keys[key]
    return false if option_keys.blank?
    option_keys.each do |option_key|
      return true if (evaluate_option_root_first(serializer, option_key)).present?
    end
    false
  end

  # ###
  # ### Collect Module Data.
  # ###

  # Check each module data hash for cache:false.  Delete from the module data array.
  # If the module data array is blank, remove the key from the collect_module hash.
  def collect_cache_module_data
    return unless collect_module_exists?
    collect_keys.each do |key|
      mod_array = collect_module[key]
      next if mod_array.blank?
      mod_cache_array = Array.new
      mod_array.delete_if do |hash|
        hash[:cache] != false ? (mod_cache_array.push(hash) and true) : false
      end
      collect_module.delete(key)  if mod_array.blank?
      next if mod_cache_array.blank?
      collect_module_data_for(key, mod_cache_array)
    end
  end

  # Collect all module data in the collect_data hash.
  def collect_module_data
    return unless collect_module_exists?
    collect_keys.each do |key|
      mod_array = collect_module[key]
      next if mod_array.blank?
      collect_module_data_for(key, mod_array)
    end
  end

  def collect_module_data_for(key, mod_array)
    collect_array = get_collect_data_for(key)
    mod_array.each do |hash|
      mod         = hash[:module]
      method      = hash[:method]
      id          = hash[:id]
      mod_data    = mod.send(method, controller, collect_data_ownerable)
      data        = Hash.new
      data[:id]   = id
      data[:data] = mod_data
      collect_array.push(data)
    end
  end

  private

  def validate_and_standardize_collect_module_hash(key, hash)
    mod = hash[:module]
    error "Collect #{key} module is blank in #{hash.inspect}."         if mod.blank?
    error "Collect #{key} module is not a module in #{hash.inspect}."  unless mod.is_a?(Module)
    method = hash[:method] || "#{key}_#{model_class_name.demodulize.underscore.pluralize}"  # assume an index method
    error "Collect #{key} module does not respond to method #{method.inspect} in #{hash.inspect}."  unless mod.respond_to?(method)
    id     = hash[:id] || model_class_name.underscore.pluralize  # assume is an index ability
    dup_id = (collect_module[key] || Array.new).find {|h| h[:id] == id}
    error "Collect #{key} module id #{id.inspect} is a duplicate in #{hash.inspect}."  if dup_id.present?
    cache = hash.has_key?(:cache) ? hash[:cache] : true
    {module: mod, method: method, id: id, cache: cache}
  end

end; end; end; end; end
