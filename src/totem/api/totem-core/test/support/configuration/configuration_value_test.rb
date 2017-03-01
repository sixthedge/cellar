require File.expand_path('../configuration_helper', __FILE__)

describe 'V01: configuration.rb framework' do

  before do
    before_configuration_common(file_ext: 'value/01_framework*')
    @framework = @config.platforms[:test_framework]
  end

  it 'V01: should be valid' do 
    assert_kind_of Hash, @framework
    refute_empty @framework, 'Framework should be populated.'
  end

  it 'V01: should have primary keys' do
    assert_equal expect_configuration_platform_primary_keys, @framework.keys.sort
  end

  it 'V01: should be populated' do 
    assert_kind_of Hash, @framework
    refute_empty @framework, 'Framework should be populated.'
  end

  it 'V01: classes should be populated' do 
    assert_kind_of Hash, @framework.classes
    refute_empty @framework.classes, 'Framework classes should be populated.'
  end

  it 'V01: modules should be populated' do 
    assert_kind_of Hash, @framework.modules
    refute_empty @framework.modules, 'Framework modules should be populated.'
  end

  it 'V01: model access should be populated' do 
    assert_kind_of Hash, @framework.model_access
    refute_empty @framework.model_access, 'Framework model access should be populated.'
  end

  it 'V01: classes should be valid' do 
    expect = {
      application_controller:    'Test::Framework::Core::ApplicationController',
      base_serializer:           'Test::Framework::Core::BaseSerializer',
      serializer_scope:          'Test::Framework::Core::Serializers::Scope',
      authentication_controller: 'Test::Framework::Oauth::AuthenticationController',
    }
    assert_equal expect, @framework.classes
  end

  it 'V01: modules should be valid' do 
    expect = {
      core_module:            'Test::Framework::Core::Module',
      controller_model_class: 'Test::Framework::Core::Controllers::TotemControllerModelClass',
      controller_api_render:  'Test::Framework::Core::Controllers::ApiRender',
      controller_params:      'Test::Framework::Core::Controllers::TotemParams',
    }
    assert_equal expect, @framework.modules
  end

  if debug_on
    it 'V01: debug' do
      puts "\n"
      pp 'V01: Configuration Framework:', @framework
    end
  end

end

describe 'V01: configuration.rb platform' do

  before do
    before_configuration_common(file_ext: 'value/01_platform*')
    @platform = @config.platforms[:test_platform]
  end

  it 'V01: should be valid' do 
    assert_kind_of Hash, @platform
    refute_empty @platform, 'Platform should be populated.'
  end

  it 'V01: should have primary keys' do
    assert_equal expect_configuration_platform_primary_keys, @platform.keys.sort
  end

  it 'V01: should be populated' do 
    assert_kind_of Hash, @platform
    refute_empty @platform, 'Platform should be populated.'
  end

  it 'V01: classes should be populated' do 
    assert_kind_of Hash, @platform.classes
    refute_empty @platform.classes, 'Platform classes should be populated.'
  end

  it 'V01: modules should be populated' do 
    assert_kind_of Hash, @platform.modules
    refute_empty @platform.modules, 'Platform modules should be populated.'
  end

  it 'V01: model access should be populated' do 
    assert_kind_of Hash, @platform.model_access
    refute_empty @platform.model_access, 'Platform model access should be populated.'
  end

  it 'V01: classes should be valid' do 
    expect = {
      application_controller:    'Test::Platform::Core::ApplicationController',
      base_serializer:           'Test::Platform::Core::BaseSerializer',
      serializer_scope:          'Test::Platform::Core::Serializers::Scope',
      authentication_controller: 'Test::Platform::Oauth::AuthenticationController',
    }
    assert_equal expect, @platform.classes
  end

  it 'V01: modules should be valid' do 
    expect = {
      core_module:            'Test::Platform::Core::Module',
      controller_model_class: 'Test::Platform::Core::Controllers::TotemControllerModelClass',
      controller_api_render:  'Test::Platform::Core::Controllers::ApiRender',
      controller_params:      'Test::Platform::Core::Controllers::TotemParams',
    }
    assert_equal expect, @platform.modules
  end

  if debug_on
    it 'V01: debug' do
      puts "\n"
      pp 'V01: Configuration Platform:', @platform
    end
  end

end

describe 'V02: configuration.rb merged' do

  before do
    before_configuration_common(file_ext: 'value/02_*')
    @platform = @config.platforms[:test_platform]
  end

  it 'V02: should be valid' do 
    assert_kind_of Hash, @platform
    refute_empty @platform, 'Platform should be populated.'
  end

  it 'V02: should have primary keys' do
    assert_equal expect_configuration_platform_primary_keys, @platform.keys.sort
  end

  it 'V02: should be populated' do 
    assert_kind_of Hash, @platform
    refute_empty @platform, 'Platform should be populated.'
  end

  it 'V02: classes should be populated' do 
    assert_kind_of Hash, @platform.classes
    refute_empty @platform.classes, 'Platform classes should be populated.'
  end

  it 'V02: modules should be populated' do 
    assert_kind_of Hash, @platform.modules
    refute_empty @platform.modules, 'Platform modules should be populated.'
  end

  it 'V02: merged classes should be valid with lowest merge order number having priority' do 
    expect = {
      merge_main: 'Test::Platform::Main1',
      merge_01:   'Test::Platform::Class1',
      merge_02:   'Test::Platform::Class2',
    }
    assert_equal expect, @platform.classes
  end

  it 'V02: merged modules should be valid with lowest merge order number having priority' do 
    expect = {
      merge_main: 'Test::Platform::Main1',
      merge_01:   'Test::Platform::Module1',
      merge_02:   'Test::Platform::Module2',
    }
    assert_equal expect, @platform.modules
  end

  it 'V02: merged paths should be valid' do 
    expect = ['test/platform/main','test/platform/merge_01', 'test/platform/another', 'test/platform/merge_02'].sort
    @paths = @platform[:paths]
    assert_equal expect, configuration_paths_in_platform
  end

  it 'V02: merged paths should be valid' do
    path = @platform[:paths].find {|p| p.path == 'test/platform/main'}
    refute_nil path, "Test platform main path should not be nil."
    assert_kind_of Hash, path
    assert_equal 'Test.Platform.1.Main', path[:ember][:namespace]
  end

  if debug_on
    it 'V02: debug' do
      puts "\n"
      pp 'V02: Configuration Platform:', @platform
    end
  end

end
