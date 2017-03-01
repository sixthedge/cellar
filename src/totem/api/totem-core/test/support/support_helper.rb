$:.push ENV['TOTEM_TEST_HELPER']  # add totem's test_helper.rb to the load path before requiring it

require 'test_helper'
require 'pp'

def debug_on
  false
end

module Test
  module Framework
    def self.table_name_prefix; 'test_framework_'; end
  end
  module Platform
    def self.table_name_prefix; 'test_platform_'; end  # used by environment classes to get engine name then current_platform_name
  end
end

def set_environment
  @env = ::Totem::Core::Environment.new
  @env.option.db_associations_filename = 'associations.yml'  # used in engines.rb and called when a model class is created
end

def base_platform_config
  'test/platform'
end

def load_platform_configs(options={})
  search_dir, file_ext = search_dir_and_file_ext_from_options(options)
  @env.option.configuration_file_directory_search = search_dir
  @env.option.configuration_file_extension        = file_ext
  @env.option.configuration_files_relative_to     = options[:relative_to]
  @env.option.configuration_files_filename        = options[:filename]
  clear_engine_instances  unless options[:clear_engines] == false
  @env.config.platforms  # load file and set the configuration
end

def search_dir_and_file_ext_from_options(options)
  file         = options[:file]
  file_ext     = options[:file_ext]
  fixtures_dir = options[:fixtures_dir] || 'fixtures_configs'
  case file
  when false    # allow passing false to set as nil
    search_dir = nil
  when nil      # make relative to test/support/fixtures_configs
    search_dir = File.expand_path("../#{fixtures_dir}", __FILE__) 
  else          # make relative to the file's folder (e.g. the test file: test/support/configuration/fixtures_configs)
    search_dir = File.expand_path("../#{fixtures_dir}", file) 
  end
  case file_ext
  when false    # allow passing false to set as nil
    file_ext = nil
  when nil      # use default file ext pattern
    file_ext = "*.config.yml"
  else
    # use the original value
  end
  [search_dir, file_ext]
end

def clear_engine_instances
  @env.engine.instance_variable_set("@engine_instances", [])  # reset the engine array
end

def register_framework_and_platform
  register_framework
  register_platform
end

def register_framework
  @env.register.framework('test_framework', 'test/framework')
end

def register_platform
  @env.register.platform('test_platform', 'test/platform')
end

# When called without options, registers the 'test/platform/main' engine.
# Note: Call from the _test file with (file: __FILE__) if requires engine.root to be set to the test folder.
def register_engine(options={})
  file            = options.delete(:file) || __FILE__
  path            = options.delete(:path) || 'test/platform/main'
  engine_name     = options.delete(:engine_name) || path_to_name(path)
  options[:reset] = false unless options.has_key?(:reset)
  options[:platform_path] ||= 'test/platform'
  options[:platform_name] ||= path_to_name(options[:platform_path])
  engine_path = path + '/engine'
  klass       = path_to_class(engine_path)
  @env.register.engine(engine_name, options)  unless options[:register] == false
  mock_engine_methods(klass, file, engine_name)
  engines = @env.engine.instance_variable_get("@engine_instances")
  engine  = klass.new
  engines.push(engine)  # add engine to engine array
  @env.engine.reset!    # reset the instance variables so will be re-populated from current engine array
  engine
end

# Add methods relative to the test engine name.
def mock_engine_methods(klass, file, engine_name)
  unless klass.method_defined?(:root)
    klass.send :define_method, :root do
      @engine_root ||= File.expand_path("../fixtures_engines/#{engine_name}",  file)
      @engine_root
    end
    klass.send :define_method, :set_root do |value|
      @engine_root = value
    end
  end
  unless klass.method_defined?(:engine_name)
    klass.send :define_method, :engine_name do
      engine_name
    end
  end
  unless klass.method_defined?(:config)
    klass.send :define_method, :config do
      @mock_config            ||= ActiveSupport::OrderedOptions.new
      @mock_config.paths      ||= HashWithIndifferentAccess.new
      @mock_config.paths[:db] ||= ['db']  # required by engines.rb to load engine associations
      @mock_config
    end
    klass.send :define_method, :paths do
      @mock_config.paths
    end
  end
end

# Create a module based on the path.
def path_to_module(path)
  path_mod_name = path.camelize
  path_mod      = path_mod_name.safe_constantize
  return path_mod  if path_mod.present? && path_mod.kind_of?(Module)
  raise "Path #{path.inspect} constant already exists as a #{path_mod.name} and is not a module."  if path_mod.present?
  parent_mod_name = path_mod_name.deconstantize
  parent_mod      = parent_mod_name.safe_constantize
  path_to_module(parent_mod_name.underscore)  if parent_mod.blank?  # recursive call for nesting modules
  parent_mod      = parent_mod_name.safe_constantize
  raise "Path #{path.inspect} parent #{parent_mod.inspect} does not exist.  Is it defined?"  if parent_mod.blank?
  mod_name = path_mod_name.demodulize
  mod      = parent_mod.const_set(mod_name, Module.new)
  raise "Could not create module #{mod_name.inspect} in module #{parent_mod.inspect}."  if mod.blank?
  unless mod.method_defined?(:table_name_prefix)  # add class method to get current platform name
    mod.send :define_singleton_method, :table_name_prefix do
      self.name.underscore.gsub(/\//,'_') + '_'
    end
  end
  mod
end

# Get the class's module to define a class.
def class_module(path)
  class_name    = path.classify                  # e.g. Test::Platform::Main::Engine
  path_mod_name = class_name.deconstantize       # e.g. Test::Platform::Main
  path_to_module(path_mod_name.underscore)
end

# Create a class extending ActiveRecord::Base
def path_to_model(path)
  path_to_class(path, ActiveRecord::Base)
end

# Create a serializer for the class.
def class_serializer(klass)
  path            = klass.name.underscore
  serializer      = path_to_class(path + '_serializer', Totem::Core::BaseSerializer)
  serializer.root = path
  serializer.send(:include, Totem::Core::Serializers::ActiveModelSerializer)
  serializer
end

# Create a class based on the path.
def path_to_class(path, base_class=nil)
  class_name = path.classify
  klass      = class_name.safe_constantize
  return klass if klass.present? && klass.kind_of?(Class)
  raise "Class #{class_name.inspect} constant already exists as a #{klass.name} and is not a class."  if klass.present?
  path_mod       = class_module(path)
  class_mod_name = class_name.demodulize
  if base_class.present?
    klass = path_mod.const_set(class_mod_name, Class.new(base_class))
  else
    klass = path_mod.const_set(class_mod_name, Class.new)
  end
  raise "Could not create class #{class_name.inspect} in module #{path_mod.inspect}."  if klass.blank?
  klass
end

def path_to_name(path)
  @env.engine.to_engine_name(path)
end

def c_path(*args)
  results = Array.new
  args.each do |arg|
    results.push arg.name.underscore
  end
  args.length > 1 ? results : results.first
end

def c_path_plural(*args)
  results = [c_path(*args)].flatten.map{|a| a.pluralize}
  args.length > 1 ? results : results.first
end

def c_sym(*args)
  results = [c_path(*args)].flatten.map{|a| a.gsub(/\//,'_').to_sym}
  args.length > 1 ? results : results.first
end

def c_sym_plural(*args)
  results = [c_path_plural(*args)].flatten.map{|a| a.gsub(/\//,'_').to_sym}
  args.length > 1 ? results : results.first
end

def c_foreign_key(klass)
  klass.name.foreign_key
end

def c_path_id(klass)
  klass.name.underscore + '_id'
end

def c_path_ids(klass)
  klass.name.underscore + '_ids'
end

# Read file content and convert
def yml_file_to_object(options={})
  content = read_file_content(options)
  YAML.load(content)
end

def read_file_content(options={})
  file         = options[:file] || __FILE__
  file_ext     = options[:file_ext]
  fixtures_dir = options[:fixtures_dir] || 'fixtures_configs'

  search_dir = File.expand_path("../#{fixtures_dir}", file)
  file = nil
  Dir.chdir(search_dir) do
    files = Dir.glob("#{file_ext}*")
    raise "More than one file with file ext #{file_ext.inspect}" if files.length > 1
    file = files.shift
  end
  File.read( File.join(search_dir, file) )
end

# A hack to add a mock method multiple times.
# This should only be used for common calls that are not important in testing
# the implementation flow.
#
# Note: Minitest::Mock (v4.7.5):
#   1. mock.verify verifies at least one actual call is made for each unique return value.
#   2. mock.verify does 'not' verify the 'number' of mock.expect's added with the same return value are actually called.
#   3. must add an 'expect' for each actual call.
#
#   Examples:
#
#     mock.expect(:mycall, nil)
#     mock.verify
#     * Errors unless :mycall is called at least once (e.g. sets the acutal return value of 'nil').
#
#     mock.expect(:mycall, nil)
#     mock.expect(:mycall, true)
#     mock.verify
#     * Errors unless :mycall is called twice; first to return nil and second to return true.
#
#     mock.expect(:mycall, nil)
#     mock.expect(:mycall, nil)
#     mock.verify
#     * Errors unless :mycall is called at least 'once' (e.g. since all return values are the same).
#
#     mock.expect(:mycall, nil)
#     mock.expect(:mycall, true)
#     mock.expect(:mycall, true)
#     mock.expect(:mycall, true)
#     mock.expect(:mycall, nil)
#     mock.expect(:mycall, nil)
#     mock.verify
#     * Errors unless :mycall is called at least 'twice'; once for nil and once for true.
#     * The other :mycall expect's have a matching return value of the first two, so they pass verification.
#
def mock_expect_ntimes(mock, name, retval, args, n=1)
  n.times do
    mock.expect(name, retval, args)
  end
end

# Debug a code block and show the backtrace e.g. debug_block { do-something }
def debug_block(&block)
  puts "\nDebug block running"
  begin
    block.call
    puts "Debug block successful\n"
  rescue => e
    puts "Debug block error:\n"
    puts e.inspect
    puts e.backtrace
    raise e
  end
end
