module Totem; module Core; module Serializers; module SerializerOptions; module Cache

  # ###
  # ### CONTROLLER - Set Options.
  # ###

  # Cache json.
  # options: Hash (not scopeable)
  #          [:ownerable] optional - [record] ownerable record
  #          [key]        optional - [true|false] defaults to true; whether data for the key should be cached (e.g. ability, metadata)
  # example: ownerable: user, metadata: false
  def cache(options={})
    query_key = options.delete(:query_key)
    cache_query_key(query_key)  if query_key.present?
    @_cache_options = cache_options.merge(options)
    cache_on
  end

  def cache_query_key(*args); cache_query.push(*args); end

  # ###
  # ### Helpers.
  # ###

  def cache?;    @_cache_response == true; end
  def cache_on;  @_cache_response = true; end
  def cache_off; @_cache_response = false; end

  def cache_options;    @_cache_options || Hash.new; end
  def cache_ownerable;  cache_options[:ownerable]; end
  def cache_ownerable?; cache? && cache_ownerable.present?; end

  def cache_instance_var; cache_options[:instance_var]; end

  def cache_query;       @_cache_query ||= Array.new; end
  def clear_cache_query; @_cache_query = Array.new; end
  def cache_query?; cache_query.present?; end

  def add_model_cache_query_key?; cache_options[:model_query_key] == true; end

  def cache_keys; collect_keys.select {|key| cache_key?(key)}; end
  def cache_key?(key); cache? && cache_options[key] != false; end

  def cacheable_data?; collect_only_keys_exist?; end

  def data_not_cached
    module_data_not_cached
    collect_only_keys.delete_if {|key| cache_options[key] != false}
  end

  def module_data_not_cached
    collect_only_keys.each do |key|
      mod_array = collect_module[key]
      next if mod_array.blank?
      mod_array.delete_if {|hash| hash[:cache] != false}
      collect_module.delete(key)  if mod_array.blank?
    end
  end

end; end; end; end; end
