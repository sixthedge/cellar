require File.expand_path('../../support_helper', __FILE__)

describe 'registration.rb errors' do

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

  it 'framework name cannot be blank' do
    e = assert_raises(RuntimeError) {@register.framework}
    assert_match(/framework name.*blank/i, e.to_s)
  end

  it 'framework path cannot be blank' do
    e = assert_raises(RuntimeError) {@register.framework('test_framework')}
    assert_match(/framework path.*blank/i, e.to_s)
  end

  it 'framework name must be a string' do
    e = assert_raises(RuntimeError) {@register.framework(:test_framework, 'test/framework/core')}
    assert_match(/framework.*not a string/i, e.to_s)
  end

  it 'framework cannot be registered more than once' do
    register_framework
    e = assert_raises(RuntimeError) {register_framework}
    assert_match(/framework.*already been registered/i, e.to_s)
  end

  it 'platform name cannot be blank' do
    e = assert_raises(RuntimeError) {@register.platform}
    assert_match(/platform.*blank/i, e.to_s)
  end

  it 'platform path cannot be blank' do
    e = assert_raises(RuntimeError) {@register.platform('test_platform')}
    assert_match(/platform path.*blank/i, e.to_s)
  end

  it 'platform must be a string' do
    e = assert_raises(RuntimeError) {@register.platform(:test_platform, 'test/platform/main')}
    assert_match(/platform.*not a string/i, e.to_s)
  end

  it 'platform cannot register until framework registered' do
    e = assert_raises(RuntimeError) {register_platform}
    assert_match(/framework has not been set/i, e.to_s)
  end

  it 'platform cannot be registered more than once' do
    register_framework
    register_platform
    e = assert_raises(RuntimeError) {register_platform}
    assert_match(/platform.*already been registered/i, e.to_s)
  end

  it 'engine cannot be blank' do
    e = assert_raises(RuntimeError) {@register.engine('')}
    assert_match(/engine.*blank/i, e.to_s)
  end

  it 'engine must be a string' do
    e = assert_raises(RuntimeError) {@register.engine(:test_engine_name)}
    assert_match(/engine.*not a string/i, e.to_s)
  end

end
