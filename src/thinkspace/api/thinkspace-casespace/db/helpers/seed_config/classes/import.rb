module SeedConfigHelperClass; class Import

  # A config hash can include 'config_key: import[filename]' to replace the config_key's value with the import value(s).
  # The import statement can be either:
  #  config_key: import[filename]      #=> import filename value hash[:import]
  #  config_key: import[filename@key]  #=> import filename value hash[key]  e.g. import[users@add_more]
  #  config_key: import[filename1, filename2, ...]  #=> can be in either form as per above; adds/merges compatible data structures in same order.
  # If the filename includes a slash, will use as-is; otherwise prepends 'imports/'
  # A config hash can use the key 'merge_with' to perform a 'reverse' merge with the object hash with the file hash value
  # (e.g. the reverse merge allows keeping any values in the config hash and inserting the new keys/values from file hash).

  attr_reader :import_files, :namespace, :regex

  def initialize(caller, seed, ns=nil)
    @caller       = caller
    @seed         = seed
    @namespace    = ns || :casespace
    @import_files = Hash.new
    @regex        = Regexp.new (/import\[/)
  end

  def process(configs)
    configs.each do |config|
      if config.to_s.match(regex)
        @seed.message color_line("--Processing imports (#{config_name(config)}).", :green)
        deep_replace_imports(config)
      end
    end
  end

  def deep_replace_imports(object)
    case

    when object.is_a?(Hash)
      keys = object.keys
      keys.each do |key|
        value = object[key]
        if value.is_a?(String) && value.match(regex)
          replace_with_import_file_value(object, key, value)
        else
          deep_replace_imports(value)
        end
      end

    when object.is_a?(Array)
      object.each do |value|
        deep_replace_imports(value)
      end
      # If object array element is a hash that has 'merge_with' key with an array value, replace the hash
      # with the hash[:merge_with] elements.
      array = Array.new
      object.each do |value|
        case
        when value.is_a?(Hash) && value.has_key?(:merge_with) && value[:merge_with].is_a?(Array)
          array += value[:merge_with]
        else
          array.push(value)
        end
      end
      object.clear
      array.each {|v| object.push(v)}

    end
  end

  def replace_with_import_file_value(object, okey, ovalue)
    imports      = ovalue.sub('import[', '').sub(']','').split(',').collect {|i| i.strip}
    merge_with   = okey == :merge_with
    import_value = nil
    imports.each do |import|
      file_value = get_import_value(import)
      case
      when merge_with && object.is_a?(Hash) && file_value.is_a?(Hash)
        object.delete(okey)  if object.has_key?(okey)
        object.reverse_merge!(file_value)
        import_value = nil
      when merge_with && object.is_a?(Hash) && file_value.is_a?(Array)  # merge the object hash with each array hash
        import_value = Array.new
        file_value.each do |hash|
          next unless hash.is_a?(Hash)
          merged_hash = hash.reverse_merge(object)
          merged_hash.delete(okey)
          import_value.push merged_hash
        end
        import_value
      when import_value.nil?
        import_value = file_value
      when import_value.is_a?(Hash) && file_value.is_a?(Hash)
        import_value.merge!(file_value)
      when import_value.is_a?(Array) && file_value.is_a?(Array)
        import_value += file_value
      when import_value.is_a?(Array)
        import_value.push(file_value)
      else
        @seed.error "Import value [#{file_value.inspect}] is not compatiable with previous import [#{import_value.inspect}]."
      end
    end
    object[okey] = import_value  if import_value.present?
    import_value
  end

  def get_import_value(import)
    import        = import.sub('import[', '').sub(']','')
    filename, key = import.split('@', 2)
    filename      = filename.match(/\//) ? filename : "imports/#{filename}"  # if has slash assume contains folder
    config        = import_files[filename] || @seed.test_import_file(namespace: namespace, import: filename)
    key           = key.present? ? key.to_sym : :import
    import_files[filename] ||= config
    @seed.error "Import file #{filename.inspect} does not have a key of #{key.inspect}."  unless config.has_key?(key)
    config[key]
  end

  def config_name(config); @caller.casespace_seed_config_name(config); end

  def color_line(*args); @caller.color_line(*args); end

end; end
