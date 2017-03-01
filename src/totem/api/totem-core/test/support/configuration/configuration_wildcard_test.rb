require File.expand_path('../configuration_helper', __FILE__)

def set_configuration_instance_vars
  @config   = @env.config
  @platform = @config.platforms[:test_platform]
  @paths    = @platform[:paths]
end

def configuration_register_engines(*args)
  options = args.extract_options!
  [args].flatten.each do |path|
    register_engine(options.merge(path: path))
  end
end

describe 'W01: configuration.rb wildcard paths' do

  before do
    before_configuration_common(file_ext: 'wildcard/01_*')
    @platform = @config.platforms[:test_platform]
    @paths    = @platform[:paths]
  end

  it 'W01: should be valid' do 
    assert_kind_of Hash, @platform
    refute_empty @platform, 'Platform should be populated.'
  end

  it 'W01: should have primary keys' do
    assert_equal expect_configuration_platform_primary_keys, @platform.keys.sort
  end

  it 'W01: paths should be valid' do
    assert_kind_of Array, @paths
  end

end

describe 'W01: configuration.rb wildcard path engines' do

  before do
    set_environment
    clear_engine_instances
  end

  it 'W01: paths should be valid 1' do
    configuration_register_engines('test/platform/main')
    load_platform_configs(file: __FILE__, file_ext: 'wildcard/01_*', clear_engines: false)
    set_configuration_instance_vars
    expect = ['test/platform/main']
    assert_equal expect, configuration_paths_in_platform
  end

  it 'W01: paths should be valid 2' do
    expect = ['test/platform/main', 'test/platform/another_one', 'test/platform/another_two', 'test/platform/another_three']
    configuration_register_engines(expect)
    load_platform_configs(file: __FILE__, file_ext: 'wildcard/01_*', clear_engines: false)
    set_configuration_instance_vars
    assert_equal expect.sort, configuration_paths_in_platform
  end

  it 'W01: paths should be valid 3 - with multiple namespaces' do
    expect  = ['test/platform/main', 'test/platform/another_one', 'test/platform/another_two']
    expect += ['test/platform/tools', 'test/platform/tools/another_one', 'test/platform/tools/another_two']
    configuration_register_engines(expect)
    load_platform_configs(file: __FILE__, file_ext: 'wildcard/01_*', clear_engines: false)
    set_configuration_instance_vars
    assert_equal expect.sort, configuration_paths_in_platform
  end

  it 'W01: paths should be valid 4 - with multiple namespaces - some do not match wildcard' do
    expect       = ['test/platform/main', 'test/platform/another_one', 'test/platform/another_two']
    expect      += ['test/platform/tools', 'test/platform/tools/another_one', 'test/platform/tools/another_two']
    different_ns = ['test/framework/tools', 'test/framework/tools/another_one', 'test/framework/tools/another_two']
    configuration_register_engines(expect, different_ns)
    assert_equal [expect, different_ns].flatten.sort, @env.engine.path_and_name.keys.sort
    load_platform_configs(file: __FILE__, file_ext: 'wildcard/01_*', clear_engines: false)
    set_configuration_instance_vars
    assert_equal expect.sort, configuration_paths_in_platform
  end

end

describe 'W02: configuration.rb wildcard path engines' do

  before do
    set_environment
    clear_engine_instances
  end

  it 'W02: paths should be valid -  with multiple namespaces - some do not match wildcard' do
    expect       = ['test/platform/tools', 'test/platform/tools/another_one', 'test/platform/tools/another_two']
    others       = ['test/platform/main', 'test/platform/another_one', 'test/platform/another_two']
    different_ns = ['test/framework/tools', 'test/framework/tools/another_one', 'test/framework/tools/another_two']
    configuration_register_engines(expect, others, different_ns)
    assert_equal [expect, others, different_ns].flatten.sort, @env.engine.path_and_name.keys.sort
    load_platform_configs(file: __FILE__, file_ext: 'wildcard/02_*', clear_engines: false)
    set_configuration_instance_vars
    assert_equal expect.sort, configuration_paths_in_platform
  end

end

describe 'W03: configuration.rb wildcard path engines' do

  before do
    set_environment
    clear_engine_instances
  end

  it 'W03: paths should be valid - with multiple namespaces - only want in tools namespace' do
    expect       = ['test/platform/tools/another_one', 'test/platform/tools/another_two']
    root_tools   = ['test/platform/tools']
    others       = ['test/platform/main', 'test/platform/another_one', 'test/platform/another_two']
    different_ns = ['test/framework/tools', 'test/framework/tools/another_one', 'test/framework/tools/another_two']
    configuration_register_engines(expect, root_tools, others, different_ns)
    assert_equal [expect, root_tools, others, different_ns].flatten.sort, @env.engine.path_and_name.keys.sort
    load_platform_configs(file: __FILE__, file_ext: 'wildcard/03_*', clear_engines: false)
    set_configuration_instance_vars
    assert_equal expect.sort, configuration_paths_in_platform
  end

end

describe 'W04: configuration.rb wildcard path engines' do

  before do
    set_environment
    clear_engine_instances
  end

  it 'W04: paths should be valid - with multiple namespaces - main tools paths plus any in tools namespace' do
    expect       = ['test/platform/tools', 'test/platform/tools/another_one', 'test/platform/tools/another_two']
    others       = ['test/platform/main', 'test/platform/another_one', 'test/platform/another_two']
    different_ns = ['test/framework/tools', 'test/framework/tools/another_one', 'test/framework/tools/another_two']
    configuration_register_engines(expect, others, different_ns)
    assert_equal [expect, others, different_ns].flatten.sort, @env.engine.path_and_name.keys.sort
    load_platform_configs(file: __FILE__, file_ext: 'wildcard/04_*', clear_engines: false)
    set_configuration_instance_vars
    assert_equal expect.sort, configuration_paths_in_platform
  end

end