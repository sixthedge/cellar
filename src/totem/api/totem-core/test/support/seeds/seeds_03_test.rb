require File.expand_path('../seeds_helper', __FILE__)

describe '03: seeds.rb' do

  before do 
    set_environment
    register_seed_engines
    load_platform_configs(file: __FILE__, file_ext: '03_*', clear_engines: false)
    register_framework_and_platform
    @seed = @env.seed
  end

  it '03: seed order is from seed order section' do 
    refute_empty @seed.order_all, 'Seed order should be populated.'
    expect = [
      'test_framework_seed_zero',
      'test_framework_seed_one',
      'test_framework_seed_two',
      'test_framework_core',
      'test_platform_seed_zero',
      'test_platform_seed_one',
      'test_platform_seed_two',
      'test_platform_main',
    ]
    assert_equal expect, @seed.order_all
  end

  it '03: seed order for framework' do
    expect = [
      'test_framework_seed_zero',
      'test_framework_seed_one',
      'test_framework_seed_two',
      'test_framework_core',
    ]
    assert_equal expect, @seed.order('test_framework')
  end

  it '03: seed order for platform' do
    expect = [
      'test_platform_seed_zero',
      'test_platform_seed_one',
      'test_platform_seed_two',
      'test_platform_main',
    ]
    assert_equal expect, @seed.order('test_platform')
  end

end
