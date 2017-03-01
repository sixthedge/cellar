require File.expand_path('../configuration_helper', __FILE__)

describe 'C01: configuration.rb find framework using config files' do

  before do 
    before_configuration_common(
      fixtures_dir: 'fixtures_configs/use_config_files',  # where to find the 'config_files' file
      filename:     '01_config_files',  # filename that contains path of framework/platform config.yml files
      relative_to:  File.expand_path("../fixtures_configs", __FILE__),  # filename's content paths relative to this path
      file_ext:     '01_framework*',  # config.yml files to load
    )
    @framework = @config.platforms[:test_framework]
  end

  it 'C01: should be valid' do
    assert_kind_of Hash, @framework
    refute_empty @framework, 'Framework should be populated.'
  end

  it 'C01: should match config' do
    using_config_files = @framework.deep_dup
    before_configuration_common(file_ext: 'value/01_framework*')
    expect = @config.platforms[:test_framework]
    assert_equal expect, using_config_files
  end

end

describe 'C02: configuration.rb find platform using config files' do

  before do 
    before_configuration_common(
      fixtures_dir: 'fixtures_configs/use_config_files',  # where to find the 'config_files' file
      filename:     '01_config_files',  # filename that contains path of framework/platform config.yml files
      relative_to:  File.expand_path("../fixtures_configs", __FILE__),  # filename's content paths relative to this path
      file_ext:     '01_platform*',  # config.yml files to load
    )
    @platform = @config.platforms[:test_platform]
  end

  it 'C02: should be valid' do
    assert_kind_of Hash, @platform
    refute_empty @platform, 'Platform should be populated.'
  end

  it 'C02: should match config' do
    using_config_files = @platform.deep_dup
    before_configuration_common(file_ext: 'value/01_platform*')
    expect = @config.platforms[:test_platform]
    assert_equal expect, using_config_files
  end

end

describe 'C03: configuration.rb find framework and platform using config files' do

  before do 
    before_configuration_common(
      fixtures_dir: 'fixtures_configs/use_config_files',  # where to find the 'config_files' file
      filename:     '01_config_files',  # filename that contains path of framework/platform config.yml files
      relative_to:  File.expand_path("../fixtures_configs", __FILE__),  # filename's content paths relative to this path
      file_ext:     '01_*',  # config.yml files to load
    )
    @platforms = @config.platforms
  end

  it 'C03: should be valid' do
    assert_kind_of Hash, @platforms
    refute_empty @platforms, 'Config should be populated.'
  end

  it 'C03: should match config' do
    using_config_files = @platforms.deep_dup
    before_configuration_common(file_ext: 'value/01_*')
    expect = @config.platforms
    assert_equal expect, using_config_files
  end

end

describe 'C04: configuration.rb find config files in multiple directories' do

  before do 
    before_configuration_common(
      fixtures_dir: 'fixtures_configs/use_config_files',  # where to find the 'config_files' file
      filename:     '02_config_files',  # filename that contains path of framework/platform config.yml files
      relative_to:  File.expand_path("../fixtures_configs", __FILE__),  # filename's content paths relative to this path
      file_ext:     '02_merge*',  # config.yml files to load
    )
    @platform = @config.platforms[:test_platform]
  end

  it 'C04: should be valid' do
    assert_kind_of Hash, @platform
    refute_empty @platform, 'Platform should be populated.'
  end

  it 'C04: should include all config files' do
    assert_equal 'Test::Platform::Core::ApplicationController', @platform[:classes][:merge_03]
    expect = @platform[:paths].select {|p| p[:path] == 'test/platform/merge_03'}
    refute_empty expect, 'Multiple config files should include path test/platform/merge_03'
    assert_equal expect.length, 1
  end

end
