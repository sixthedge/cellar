require File.expand_path('../../support_helper', __FILE__)

def user; path_to_class('test/platform/main/user'); end

def register_ember_engines
  # file = __FILE__  # use if engines are in the 'support/ember/fixtures_engines' folder (rather than 'support/fixtures_engines')
  file = nil
  register_engine(file: file, path: 'test/platform/one',   platform_sub_type: 'common')
  register_engine(file: file, path: 'test/platform/two',   platform_sub_type: 'common')
  register_engine(file: file, path: 'test/platform/three', platform_sub_type: 'another')
  register_engine(file: file, path: 'test/platform/four',  platform_sub_type: 'another')  # no application.js file
end

def stylesheet_imports(*args)
  result = Array.new
  [args].flatten.each do |arg|
    result.push "@import '#{arg}';"
  end
  result
end

def before_ember_common(options={})
  options[:file]     ||= __FILE__
  options[:file_ext] ||= '01_*'
  set_environment
  load_platform_configs(options)
  register_framework_and_platform
  register_ember_engines
  set_ember_instance_vars
end

def set_ember_instance_vars
  @ember         = @env.ember
  @config        = @ember.config('test_platform')
  @platform      = @config[:platform]
  @framework     = @config[:framework]
  @require_paths = @config[:require_paths]
  @namespaces    = @config[:namespaces]
  @session       = @config[:session]
end
