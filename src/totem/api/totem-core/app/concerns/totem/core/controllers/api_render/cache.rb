module Totem; module Core; module Controllers; module ApiRender; module Cache

  include ApiRender::CacheQueryKey

  CONTROLLER_CACHE_DEFAULTS = {
    expires_in: 5.days,
  }.freeze

  extend ::ActiveSupport::Concern

  included do
    def controller_cache?
      # controller_cache_clear  # clear all of the controller cache
      return false unless ::Rails.configuration.action_controller.perform_caching.present?
      return false unless cache_store.present?
      return false unless serializer_options_defined?
      serializer_options.cache?
    end
  end

  # ###
  # ### Public method.
  # ###

  def controller_cache_json(record_or_scope, options={})
    # options[:debug] = true
    # options[:debug] = :key
    key_options       = serializer_options.cache_options.merge(options)
    str_key           = controller_cache_key(record_or_scope, key_options)
    key               = controller_cache_key_digest(str_key)
    cache_options     = key_options.slice(:expires_in).reverse_merge(CONTROLLER_CACHE_DEFAULTS)
    from_cache        = true
    json = cache(key, cache_options) do
      from_cache = false
      cache_json = options[:json] || controller_call_json_method(record_or_scope, options)
      if controller_can_cache_record_data?
        serializer_options.collect_cache_module_data
        controller_add_collect_data_to_json(serializer_options.cache_keys, cache_json)
      end
      cache_json
    end
    json = json.deep_dup  unless ::Rails.env.production?  # a dev 'memory_store' returns the cached object; if updated then updates cache
    controller_cache_debug(json, str_key, key, from_cache, key_options, cache_options) if key_options[:debug].present?
    controller_cache_create_record_data(json, record_or_scope, options) if from_cache
    json
  end

  private

  def controller_can_cache_record_data?
    serializer_options.cache_ownerable?
  end

  # Since the json was in the cache, the records where not serialized e.g. the purpose of caching.
  # Need to collect the record data (e.g. abilities and metadata) in the serializer options (don't need the json itself)
  # to add to the cache json by after_json.
  def controller_cache_create_record_data(json, record_or_scope, options)
    return unless serializer_options.serialize_record_data? # no data to collect
    serializer_options.collect_only  # set to all possible collectable data
    serializer_options.data_not_cached  if controller_can_cache_record_data?  # keep keys that could be cached but are false in cache options
    if serializer_options.cacheable_data?
      controller_call_json_method(record_or_scope, options)  # set the data not cached to be included in after_json
    end
  end

  # ###
  # ### Cache Key.
  # ###

  # If have options[:cache_key], it will become the key (no other key parts are added other than options[:cache_keys]).
  def controller_cache_key(record_or_scope, options)
    parts = Array.new
    if (key = options[:cache_key]).present?
      controller_cache_convert_timestamp_to_keys(parts, key)
      controller_cache_add_generic_keys(parts, options)
    else
      case
      when controller_cache_record_or_scope_is_a_scope?(record_or_scope)
        controller_cache_add_collection_key(parts, record_or_scope, options)
      when record_or_scope.is_a?(Array)
        controller_cache_add_collection_key(parts, record_or_scope, options)
      else
        controller_cache_add_member_key(parts, record_or_scope, options)
      end
    end
    parts.join('/')
  end

  def controller_cache_record_or_scope_is_a_scope?(record_or_scope); record_or_scope.is_a?(::ActiveRecord::Relation); end

  def controller_cache_key_digest(key)
    digest = Digest::MD5.new  # other digest options: Digest::SHA1.new, Digest::SHA256.new
    digest.update(key)
    digest.hexdigest
  end

  def controller_cache_add_collection_key(parts, scope, options)
    controller_cache_add_controller_key(parts, options)
    controller_cache_additional_keys(parts, scope, options)
  end

  def controller_cache_add_member_key(parts, record, options)
    controller_cache_add_controller_key(parts, options)
    parts.push record.id
    controller_cache_additional_keys(parts, record, options)
  end

  def controller_cache_add_controller_key(parts, options)
    parts.push self.class.name.underscore
    parts.push self.action_name
  end

  def controller_cache_additional_keys(parts, record_or_scope, options)
    controller_cache_add_controller_sub_action_key(parts, options)
    controller_cache_add_model_ids_key(parts, options)
    controller_cache_add_ownerable_key(parts, options)
    controller_cache_add_generic_keys(parts, options)
    controller_cache_add_model_query_key(parts, record_or_scope, options)
    controller_cache_add_serializer_options_cache_values(parts, options)
  end

  # ###
  # ### Special Cache Key Parts (e.g. ownerable, ids, sub_action).
  # ###

  def controller_cache_add_ownerable_key(parts, options)
    ownerable = options[:ownerable]
    return if ownerable.blank?
    parts.push :ownerable
    parts.push ownerable.class.name.underscore
    parts.push ownerable.id
  end

  def controller_cache_add_model_ids_key(parts, options)
    ids = options[:ids] || serializer_options.params_ids
    return if ids.blank?
    parts.push Array(ids).map {|id| id.to_s}
  end

  def controller_cache_add_controller_sub_action_key(parts, options)
    sub_action = options[:sub_action] || serializer_options.params_auth_sub_action
    return if sub_action.blank?
    parts.push Array(sub_action).map {|sa| sa.to_s}
  end

  # ###
  # ### Generic Cache Key Parts (options[:cache_keys]).  Can be any time or an object with a to_s method e.g. string, symbol.
  # ###

  def controller_cache_add_generic_keys(parts, options)
    keys = options[:cache_keys]
    return if keys.blank?
    controller_cache_convert_timestamp_to_keys(parts, keys)
  end

  # ###
  # ### Model Cache Query Key Parts
  # ###

  def controller_cache_add_model_query_key(parts, record_or_scope, options)
    query_key = controller_cache_model_query_key(record_or_scope, options)
    if query_key.include?(nil)
      # If the query_key has a nil value (e.g. no records created yet), try calling
      # the json method to see if it populates the records.
      options[:json] = controller_call_json_method(record_or_scope, options)
      query_key      = controller_cache_model_query_key(record_or_scope, options)
    end
    raise_controller_cache_error "query_key has a nil value #{query_key.inspect}." if query_key.include?(nil)
    controller_cache_convert_timestamp_to_keys(parts, query_key)
  end

  # If the cache_options contain :query_key, then call the CacheQueryKey module,
  # otherwise call the model method.
  def controller_cache_model_query_key(record_or_scope, options)
    query_key = Array.new
    if serializer_options.cache_query?
      query_key += controller_cache_query_key(record_or_scope, options)
    end
    return query_key  if query_key.present? && !serializer_options.add_model_cache_query_key?
    method = controller_cache_model_query_key_method(record_or_scope, options)
    raise_controller_cache_error "model does not respond to query_key method [#{method}]."  if serializer_options.add_model_cache_query_key? && !record_or_scope.respond_to?(method)
    if record_or_scope.respond_to?(method)
      query_key += record_or_scope.send(method, record_or_scope, serializer_options.cache_ownerable, options)
    end
    raise_controller_cache_error "invalid model query_key method [#{method}]."  if query_key.blank?  # no cache query key value or model key value
    @_totem_query_key_method = method # setting instance var for for debug message
    query_key
  end

  def controller_cache_model_query_key_method(record_or_scope, options)
    method = options[:query_key_method]
    return method if method.present?
    default_method = :totem_cache_query_key
    action         = self.action_name || ''
    "#{default_method}_#{action}".to_sym
  end

  def controller_cache_convert_timestamp_to_keys(parts, query_key)
    return if query_key.blank?
    Array(query_key).collect {|value| parts.push value.is_a?(Time) ? value.utc.to_s(:nsec) : value.to_s}
  end

  # ###
  # ### Cache Options Key Parts.
  # ###

  # Convert the serializer options cache related values into a key part.
  def controller_cache_add_serializer_options_cache_values(parts, options)
    cache_options     = controller_cache_convert_hash_to_cache_key(serializer_options.cache_options.except(:debug))
    cache_options_key = [:cache_options, cache_options]
    parts.push cache_options_key.join(':')
    return unless serializer_options.collect_cache_key_options_exists?
    cache_key_options = serializer_options.collect_cache_key_options
    keys              = cache_key_options.keys.sort
    keys.each do |key|
      array = cache_key_options[key]
      next if array.blank?
      key_parts = Array.new
      key_parts.push(key.to_s)
      array.each do |hash|
        key_parts.push controller_cache_convert_hash_to_cache_key(hash)
      end
      parts.push key_parts.join(':')  if key_parts.present?
    end
  end

  def controller_cache_convert_hash_to_cache_key(hash)
    hash_parts = Array.new
    hash.keys.sort.each do |key|
      value = hash[key]
      if controller_cache_active_record?(value)
        hash_parts.push "#{key}=#{value.class.name}.#{value.id}"
      else
        hash_parts.push "#{key}=#{value}"
      end
    end
    hash_parts
  end

  # ###
  # ### Helpers.
  # ###

  def controller_cache_clear;   cache_store.clear; end
  def controller_cashe_cleanup; cache_store.cleanup; end

  def controller_cache_active_record?(value)
    return false if value.is_a?(Class)
    value.class.ancestors.include?(::ActiveRecord::Base) && value.respond_to?(:id)
  end

  def controller_cache_debug(json, str_key, key, from_cache, options, cache_options)
    if options[:debug] == :key
      message = "From cache: #{from_cache.inspect.upcase}  Cache digest: #{key}"
      controller_debug_message ('-' * message.length)
      controller_debug_message message
      controller_debug_message ('-' * message.length)
      return
    end
    option_keys = [:cache_key, :cache_keys, :ids, :sub_action, :ownerable, :query_key_method, :json_method]
    key_options = controller_cache_convert_hash_to_cache_key options.slice(*option_keys)
    puts "\n"
    controller_debug_message ('-' * 100)
    controller_debug_message "From cache   : #{from_cache.inspect.upcase}"
    controller_debug_message "Controller   : #{self.class.name}##{self.action_name}"
    controller_debug_message "Cache options: #{cache_options.inspect}"
    controller_debug_message "Key options  : #{key_options.join(', ')}"
    controller_debug_message "Model method : #{@_totem_query_key_method}"        if @_totem_query_key_method.present?
    controller_debug_message "Cache query  : #{serializer_options.cache_query}"  if serializer_options.cache_query?
    controller_debug_message "JSON keys    : #{json.keys.sort}"
    controller_debug_message "Cache str key: #{str_key}"
    controller_debug_message "Cache digest : #{key}"
    controller_debug_message "#{('-' * 100)}\n\n"
  end

  def raise_controller_cache_error(message); raise CacheError, "Controller #{self.class.name.inspect}: #{message}"; end

  class CacheError < StandardError; end

end; end; end; end; end
