require File.expand_path('../seeds_helper', __FILE__)

describe '01: seeds.rb' do

  before do 
    set_environment
    clear_engine_instances
    register_engine(path: 'test/framework/core')
    register_engine
    load_platform_configs(file: __FILE__, file_ext: '01_*', clear_engines: false)
    register_framework_and_platform
    @seed = @env.seed
  end

  it '01: should be valid' do 
    assert_kind_of Array, @seed.order_all
  end

  it '01: should be populated' do 
    refute_empty @seed.order_all, 'Seed order should be populated.'
    assert_equal ['test_framework_core', 'test_platform_main'], @seed.order_all
  end

end
