require File.expand_path('../../support_helper', __FILE__)

def before_authentication_common(options={})
  options[:file_ext] ||= '01_*'
  options[:file]     ||= __FILE__
  set_environment
  load_platform_configs(options)
  register_framework_and_platform
  register_engine
  @auth = @env.authentication
end

def user; path_to_class('test/platform/main/user'); end

def set_oauth_providers
  ::Totem::Authentication::Oauth::Support::OmniauthProviders.add_providers(@env)
end

def set_secrets_oauth_providers(options={})
  hash = yml_file_to_object(options)
  @auth.instance_variable_set('@all_loaded_oauth_providers', hash)
end