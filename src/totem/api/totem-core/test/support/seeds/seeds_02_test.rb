require File.expand_path('../seeds_helper', __FILE__)

describe '02: seeds.rb' do

  before do 
    set_environment
    register_seed_engines
    load_platform_configs(file: __FILE__, file_ext: '02_*', clear_engines: false)
    register_framework_and_platform
    @seed = @env.seed
  end

  it '02: seed order is path order' do 
    refute_empty @seed.order_all, 'Seed order should be populated.'
    expect = [
      'test_framework_core',
      'test_framework_seed_one',
      'test_framework_seed_two',
      'test_framework_seed_zero',
      'test_platform_main',
      'test_platform_seed_zero',
      'test_platform_seed_one',
      'test_platform_seed_two',
    ]
    assert_equal expect, @seed.order_all
  end

  it '02: seed order for framework' do
    expect = [
      'test_platform_main',
      'test_platform_seed_zero',
      'test_platform_seed_one',
      'test_platform_seed_two',
    ]
    assert_equal expect, @seed.order('test_platform')
  end

  it '02: seed order for platform' do
    expect = [
      'test_framework_core',
      'test_framework_seed_one',
      'test_framework_seed_two',
      'test_framework_seed_zero',
    ]
    assert_equal expect, @seed.order('test_framework')
  end

end
