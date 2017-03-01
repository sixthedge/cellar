require File.expand_path('../seeds_helper', __FILE__)

describe 'seeds.rb errors' do

  before do 
    set_environment
    @seed = @env.seed
  end

  it 'no platforms to process' do
    load_platform_configs
    @env.config.instance_variable_set('@all_platform_configurations', {})
    e = assert_raises(RuntimeError) {@seed.order_all}
    assert_match(/no platforms defined.*seed/i, e.to_s)
  end

  it 'framework is not registered' do
    load_platform_configs
    e = assert_raises(RuntimeError) {@seed.order_all}
    assert_match(/framework.*not.*registered/i, e.to_s)
  end

  it 'E01: framework paths blank' do
    load_platform_configs(file: __FILE__, file_ext: 'error/01_*')
    register_framework
    e = assert_raises(RuntimeError) {@seed.order_all}
    assert_match(/no seed order.*defined.*test_framework/i, e.to_s)
  end

  it 'E02: platform paths blank' do
    load_platform_configs(file: __FILE__, file_ext: 'error/02_*')
    register_framework_and_platform
    e = assert_raises(RuntimeError) {@seed.order_all}
    assert_match(/no seed order.*defined.*test_platform/i, e.to_s)
  end

end

