require File.expand_path('../configuration_helper', __FILE__)

describe 'configuration.rb' do

  before do 
    set_environment
    load_platform_configs
    @config    = @env.config
    @platforms = @config.platforms
  end

  it 'should be valid' do 
    assert_kind_of Hash, @platforms
    refute_empty @platforms, 'Configuration platforms should be populated.'
  end

  it 'has platform keys' do
    assert_equal [:test_framework, :test_platform].sort, @platforms.keys.sort
  end

  if debug_on
    it 'debug' do
      puts "\n"
      pp 'Configuration Platforms:', @platforms
    end
  end

end
