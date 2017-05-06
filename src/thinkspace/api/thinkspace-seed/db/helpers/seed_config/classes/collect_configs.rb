module SeedConfigHelperClass; class CollectConfigs

  attr_reader :namespace, :config_content

  def initialize(caller, seed, ns=nil)
    @caller    = caller
    @seed      = seed
    @namespace = ns || :seed
  end

  def process
    config_names    = get_config_names
    @config_content = process_import_text(config_names)
    configs         = Array.new
    config_names.each do |config_name|
      config                = get_config(config_name)
      config[:_config_name] = config_name
      pre_configs           = load_prereq_files(config)
      pre_configs.each {|c| configs.push(c)  unless configs.include?(c) }
      configs.push(config)  unless configs.include?(config)
    end
    process_imports(configs)
    configs
  end

  def get_config_names
    config_names = Array.new
    Array.wrap(@seed.test_config_names).each do |name|
      content = @seed.test_config_content(namespace: namespace, config: name)
      if include_configs?(content)
        content = remove_import_text(content)
        config_names.push(name)
        hash  = YAML.load(content).deep_symbolize_keys
        names = hash[:include_configs] or []
        Array.wrap(names).each {|n| config_names.push(n)}
      else
        config_names.push(name)
      end
    end
    config_names
  end

  # Remove import_text so doesn't create a Psych::SyntaxError.
  def remove_import_text(content)
    regex = Regexp.new /import_text\[.*?\].*?\n/
    return content unless content.match(regex)
    new_content = ''
    content.each_line do |line|
      new_content += line.match(regex) ? '' : line
    end
    new_content
  end

  def include_configs?(content); content.match('include_configs:'); end

  def process_import_text(config_names)
    ::SeedConfigHelperClass::ImportText.new(@caller, @seed).process(config_names)
  end

  def process_imports(configs)
    ::SeedConfigHelperClass::Import.new(@caller, @seed).process(configs)
  end

  def get_config(config_name)
    if content = config_content[config_name]
      YAML.load(content).deep_symbolize_keys
    else
      @seed.test_config_file(config: config_name, namespace: namespace)
    end
  end

  def add_include_config_names(config, config_names)
    Array.wrap(config[:include_configs] || Array.new).reverse.each do |config_name|
      config_names.unshift(config_name) unless config_names.include?(config_name)
    end
  end

  def load_prereq_files(config, configs=Array.new, times=0, max=15)
    configs.unshift config  unless configs.include?(config)
    prereqs = [config[:prereq_configs]].flatten.compact
    if prereqs.present?
      if times >= max
        names = configs.collect {|c| config_name(c)}
        @seed.error "Seed config file prerequisites nested more than #{max} levels deep.  Prereq configs #{names}."
      end
      prereqs.each do |prereq|
        prereq.deep_symbolize_keys! if prereq.is_a?(Hash)
        prereq = {config: prereq} if value_string_or_symbol?(prereq)
        prereq[:namespace]     ||= namespace
        prereq[:test_data_dir] ||= (@seed.test_data_seed_name || prereq[:config])
        config_name = prereq[:config]
        if config_name.present? && config_content[config_name].blank?
          content                     = @seed.test_config_content(prereq)
          new_content                 = SeedConfigHelperClass::ImportText.new(@caller, @seed).get_import_content(content)
          config_content[config_name] = new_content if new_content.present?
        end
        config = get_config(config_name)
        config[:_config_name] = prereq[:config]
        load_prereq_files(config, configs, times+=1, max)
      end
    end
    configs
  end

  def value_string_or_symbol?(value); value.instance_of?(String) || value.instance_of?(Symbol); end

  def config_name(config); @caller.seed_config_name(config); end

end; end
