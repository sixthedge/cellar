require File.expand_path('../../support_helper', __FILE__)

describe 'registration.rb' do

  before do
    set_environment
    load_platform_configs
    @register         = @env.register
    @registered       = @env.registered
    @platform_options = {
      platform_name:     'test_platform',
      platform_path:     'test/platform',
      platform_scope:    'test_scope',
      platform_sub_type: 'common',
    }
  end

  it 'framework register' do 
    register_framework
    assert_kind_of Array, @registered.platforms
    refute_empty @registered.platforms, 'Registered platforms should be populated with framework.'
    assert_equal 'test_framework', @registered.framework_name
    assert_equal ['test_framework'], @registered.platforms
  end

  it 'platform register' do
    register_framework
    register_platform
    assert_kind_of Array, @registered.platforms
    refute_empty @registered.platforms, 'Registered platforms should be populated with platform.'
    assert_equal ['test_framework', 'test_platform'].sort, @registered.platforms.sort
  end

  it 'engine register' do
    name = 'test_platform_one'
    @register.engine(name, @platform_options)
    assert_equal @platform_options.stringify_keys, @registered.engine_configurations[name]
    assert_equal [name].sort, @registered.engines.sort
  end

  it 'engine register multiple' do
    registered_engines = Array.new
    name = 'test_platform_one'
    @register.engine(name, @platform_options)
    assert_equal @platform_options.stringify_keys, @registered.engine_configurations[name]
    registered_engines.push(name)
    name = 'test_platform_two'
    @register.engine(name, @platform_options)
    assert_equal @platform_options.stringify_keys, @registered.engine_configurations[name]
    registered_engines.push(name)
    name = 'test_platform_three'
    @register.engine(name, @platform_options)
    assert_equal @platform_options.stringify_keys, @registered.engine_configurations[name]
    registered_engines.push(name)
    assert_equal registered_engines.sort, @registered.engines.sort
  end

  it 'engine get options' do
    name = 'test_platform_one'
    @register.engine(name, @platform_options)
    assert_equal @platform_options[:platform_name],     @registered.engine_platform_name(name)
    assert_equal @platform_options[:platform_path],     @registered.engine_platform_path(name)
    assert_equal @platform_options[:platform_scope],    @registered.engine_platform_scope(name)
    assert_equal @platform_options[:platform_sub_type], @registered.engine_platform_sub_type(name)
  end

  it 'engine options not corrupted with multiple' do
    @register.engine('test_platform_one', platform_name: 'one_bad', platform_path: 'one/bad')
    name = 'test_platform_two'
    @register.engine(name, @platform_options)
    @register.engine('test_platform_three', platform_name: 'three_bad', platform_path: 'three/bad')
    assert_equal @platform_options[:platform_name],     @registered.engine_platform_name(name)
    assert_equal @platform_options[:platform_path],     @registered.engine_platform_path(name)
    assert_equal @platform_options[:platform_scope],    @registered.engine_platform_scope(name)
    assert_equal @platform_options[:platform_sub_type], @registered.engine_platform_sub_type(name)
  end

  # Note: performs 'register_engine' helper method to mock engine since requires engine class name from engines.rb.
  it 'engine config option with engine class by symbol' do
    register_engine(@platform_options.merge(path: 'test/platform/one'))
    expect = {'test_platform' => ['Test::Platform::One']}
    actual = @registered.config_value_and_engine_class_names(@platform_options[:platform_path], :platform_name)
    assert_equal expect, actual
  end

  it 'engine config option with engine class by string' do
    register_engine(@platform_options.merge(path: 'test/platform/one'))
    expect = {'test_platform' => ['Test::Platform::One']}
    actual = @registered.config_value_and_engine_class_names(@platform_options[:platform_path], 'platform_name')
    assert_equal expect, actual
  end

  it 'engine config option for multiple engines - platform name' do
    register_engine(@platform_options.merge(path: 'test/platform/one'))
    register_engine(path: 'test/platform/two', platform_name: 'two_platform', platform_path: 'two/platform')
    register_engine(@platform_options.merge(path: 'test/platform/three'))
    expect = {'test_platform' => ['Test::Platform::One', 'Test::Platform::Three']}
    actual = @registered.config_value_and_engine_class_names(@platform_options[:platform_path], :platform_name)
    assert_equal expect, actual
    expect = {'two_platform' => ['Test::Platform::Two']}
    actual = @registered.config_value_and_engine_class_names('two/platform', :platform_name)
    assert_equal expect, actual
  end

  it 'another engine config option for multiple engines - platform_sub_type' do
    register_engine(@platform_options.merge(path: 'test/platform/one'))
    register_engine(path: 'test/platform/two', platform_sub_type: 'two_sub_type', platform_path: 'two/platform')
    register_engine(@platform_options.merge(path: 'test/platform/three'))
    expect = {'common' => ['Test::Platform::One', 'Test::Platform::Three']}
    actual = @registered.config_value_and_engine_class_names(@platform_options[:platform_path], :platform_sub_type)
    assert_equal expect, actual
    expect = {'two_sub_type' => ['Test::Platform::Two']}
    actual = @registered.config_value_and_engine_class_names('two/platform', :platform_sub_type)
    assert_equal expect, actual
  end

end
