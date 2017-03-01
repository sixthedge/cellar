public

def casespace_seed_configs_process
  set_common_seed_loader_namespaces
  casespace_seed_config_require_seed_config_helpers
  casespace_seed_config_require_seed_config_helper_classes
  configs = ::SeedConfigHelperClass::CollectConfigs.new(self, @seed).process
  @seed.message color_line(">>Processing seed configs in this order: #{configs.collect{|config| casespace_seed_config_name(config)}}.", :cyan, :bold)
  casespace_seed_reset_all_model_column_info
  casespace_seed_config_process_configs(configs)
end

# Ensure if any migrations add/remove columns, the model class column info is updated.
def casespace_seed_reset_all_model_column_info
  model_classes = ActiveRecord::Base.descendants
  model_classes.each do |klass|
    next unless klass.name.match('Thinkspace')
    klass.reset_column_information
  end
end

def casespace_config_models; @casespace_config_models ||= CasespaceConfigModels.new(self, @seed); end

def casespace_seed_config_process_configs(configs)
  casespace_reset_assignments_created
  configs.each do |config|
    casespace_seed_config_process(config)
    casespace_config_models.print_config_models if casespace_seed_config_process_print_config_models? || config[:print_models] == true
  end
  @seed.message color_line("++All config processing.", :cyan, :bold)
  casespace_config_models.clear_find_by  # do not add the find_by ids since doing db wide
  casespace_seed_config_process_add_phase_components
  casespace_seed_config_process_auto_input(configs)
  casespace_seed_config_process_builder(configs)
  casespace_config_models.print_models if casespace_seed_config_process_print_models?
end

def casespace_seed_config_process_print_config_models?; ENV['PRINT_MODELS'] == 'config' || ENV['PM'] == 'config'; end
def casespace_seed_config_process_print_models?;        ENV['PRINT_MODELS'] == 'true'   || ENV['PM'] == 'true'; end

def casespace_seed_config_process(config)
  casespace_seed_config_require_data_files(config)
  methods = casespace_seed_config_get_config_methods
  name    = color_line(casespace_seed_config_name(config), :bold)
  @seed.message color_line("++Processing config (") + name + color_line(').') if methods.present?
  methods.each do |method|
    self.send method, config
  end
end

# ### Helpers

def casespace_seed_config_require_data_files(config)
  reqs = [config[:require_data_files]].flatten.compact
  reqs.each do |req|
    namespace = :casespace
    if casespace_seed_config_value_string_or_symbol?(req)
      test_data_dir = req
    else
      namespace     = req[:namespace] || namespace
      test_data_dir = req[:test_data_dir]
    end
    @seed.require_data_files(namespace, test_data_dir)
  end
end

def casespace_seed_config_value_string_or_symbol?(value); value.instance_of?(String) || value.instance_of?(Symbol); end

# Will run method: "casespace_seed_config_add_#{ns_key.pluralize}" with the 'config' as a parameter.
def casespace_seed_config_get_config_methods
  @_casespace_seed_config_process_method_order ||= begin
    casespace_methods = casespace_seed_config_casespace_process_method_order
    methods           = casespace_methods.collect {|m| casespace_seed_config_get_config_method_from_key(m)}
    @seed.namespace_lookup.keys.sort.each do |key|
      method = casespace_seed_config_get_config_method_from_key(key.to_s.pluralize)
      if self.respond_to?(method, true)  # add engine method
        methods.push method
      end
    end
    methods
  end
end

def casespace_seed_config_casespace_process_method_order
  [:users, :spaces, :space_users, :repeat_space_users, :assignments, :phase_templates, :phases] # base casespace methods in order of processing
end

def casespace_seed_config_get_config_method_from_key(key); "casespace_seed_config_add_#{key}".to_sym; end

def casespace_seed_config_require_seed_config_helpers
  return if ENV['SKIP_SEED_CONFIG_REQUIRE'] == 'true'
  dir = File.join(@seed.db_helpers_dir(:casespace), 'seed_config')
  @seed.message "++Require seed config helpers in #{dir.inspect}"
  dir_files = Dir.glob(File.join(dir, '*_helper.rb'))
  dir_files.each do |file|
    require file
  end
end

def casespace_seed_config_require_seed_config_helper_classes
  dir = File.join(@seed.db_helpers_dir(:casespace), 'seed_config/classes')
  @seed.message "++Require seed config helper classes in #{dir.inspect}"
  dir_files = Dir.glob(File.join(dir, '*.rb'))
  dir_files.each do |file|
    require file
  end
end

#########################################################################################
# ###
# ### Process Phase Components.
# ###

def casespace_seed_config_process_add_phase_components
  @seed.message "++Adding seed config phase components. (all configs)"
  add_casespace_phase_components
end

#########################################################################################
# ###
# ### Process Auto Input.
# ###
# Multiple configs may contain an 'auto_input' section, but there can be only one
# to process all phases (e.g. neo).  The non-all-phase auto input configs (e.g. when do not
# have 'scope: all') perform auto input on the configs defined phases only.
def casespace_seed_config_process_auto_input(configs)
  if casespace_seed_config_auto_input?(configs)
    auto_input_configs = casespace_seed_config_filter_auto_input_configs(configs)
    if auto_input_configs.present?
      @seed.require_data_file(:casespace, 'auto_input/base.rb')
      casespace_seed_config_require_data_files(require_data_files: :auto_input)
      auto_input_configs.each do |config|
        casespace_seed_config_add_auto_input(config)
      end
    end
  end
end

def casespace_seed_config_filter_auto_input_configs(configs)
  auto_input_configs = Array.new
  all_phases_configs = Array.new
  configs.each do |config|
    auto_input = config[:auto_input]
    next if auto_input.blank?
    all_phases_configs.push(config) if auto_input[:scope].present? && auto_input[:scope].to_s == 'all'
    auto_input_configs.push(config)
  end
  return auto_input_configs  if all_phases_configs.blank?
  if all_phases_configs.length > 1
    names = all_phases_configs.collect {|config| casespace_seed_config_name(config)}
    casespace_seed_config_error "More than one seed config has auto input for all phases #{names.inspect}."
  end
  all_phases_configs
end

def casespace_seed_config_auto_input?(configs=[])
  return true if @seed.test_config_auto_input?
  names = configs.collect {|config| casespace_seed_config_name(config)}
  names.include?('auto_input')  # assume want to auto_input if included the config named 'auto_input'
end

#########################################################################################
# ###
# ### Builder.
# ###
def casespace_seed_config_process_builder(configs)
  @seed.message "++Adding builder templates. (all spaces, assignments and phases)"
  create_builder_templates(configs)
end

#########################################################################################
# ###
# ### Message/Error Helpers.
# ###

def casespace_seed_config_name(config); config[:_config_name]; end

def casespace_seed_config_message(message, config=nil)
  message += " (#{casespace_seed_config_name(config)})"  if config.present?
  @seed.message message
end

def casespace_seed_config_error(message, config=nil)
  message = "[#{casespace_seed_config_name(config)}] " + message  if config.present?
  @seed.error message
end
