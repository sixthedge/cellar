require File.expand_path('../../support_helper', __FILE__)

def expect_configuration_platform_primary_keys
  [
    :platform_name,
    :platform_path,
    :ember,
    :classes,
    :modules,
    :routes,
    :authentication,
    :authorization,
    :model_access,
    :seed_order,
    :paths,
  ].sort
end

def configuration_paths_in_platform
  @paths.collect {|h| h[:path]}.sort
end

def before_configuration_common(options={})
  options[:file_ext] ||= '01_*'
  options[:file]     ||= __FILE__
  set_environment
  load_platform_configs(options)
  @config = @env.config
end
