module Totem; module Core; module Serializers; module SerializerOptions; module Metadata

  def metadata_key; :metadata; end

  # ###
  # ### CONTROLLER - Set Options.
  # ###

  # Include the serialized record's metadata.
  # args:    Hash (scopeable)
  # example: scope: :root  (currently only scope supported)
  def include_metadata(*args)
    options           = args.extract_options!
    options[:include] = true  # currently the only option used is :scope, so creating a default option
    key               = :include_metadata
    set_option_value(key, options.except(:scope), options)
    collect_for(metadata_key, key, options)
  end

  # Add metadata from module method(s).
  # args: Hash (not scopeable)
  #       [:module] required - [module] module containing the method
  #       [:method] optional - [symbol] defaults to controller model class name pluralized
  #       [:id]     optional - [string] defaults to demodulized controller model class name pluralized
  #       [:cache]  optional - [true|false] defaults to true when 'serializer_options.cache' used
  # example: module: MyMod, method: :my_index_method
  # can be called multiple times.
  def include_module_metadata(*args)
    options = args.extract_options!
    collect_for_module(metadata_key, options)
  end

  # Only serialize the metadata e.g. not any records.
  # args: none
  def metadata_only; collect_only_for(metadata_key); end

  # ###
  # ### Collect Metadata Helpers.
  # ###

  def collect_metadata_data;  get_collect_data_for(metadata_key); end
  def clear_collect_metadata; clear_collect_data_for(metadata_key); end

end; end; end; end; end
