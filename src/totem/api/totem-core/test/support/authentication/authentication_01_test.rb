require File.expand_path('../authentication_helper', __FILE__)

describe '01: authentication.rb' do

  before do 
    before_authentication_common(file_ext: 'value/01_*')
  end

  it '01: should be valid' do 
    assert_kind_of Hash, @auth.platforms
    refute_empty @auth.platforms, 'Authentication should be populated.'
  end

  it '01: should have framework' do
    refute_empty @auth.platform('test_framework'), 'Framework test_framework should be populated.'
  end

  it '01: should have platform' do
    refute_empty @auth.platform('test_platform'), 'Platform test_platform should be populated.'
  end

  it '01: current model class' do
    assert_equal user, @auth.current_model_class(user)
  end

  it '01: current route' do
    assert_equal '/test/platform/home', @auth.current_route(user, :home)
    assert_equal '/test/platform/home', @auth.current_home_route(user)
    assert_equal '/test/platform/public', @auth.current_route(user, :public)
  end

  it '01: current session inherited from framework' do
    expect = {timeout_time: 1800, expire_after_time: 21600, sample_key: 'framework'}
    assert_equal expect, @auth.current_session(user)
  end

  it '01: current session timeout inherited from framework' do
    assert_equal 30.minutes, @auth.current_session_timeout(user)
  end

  it '01: current session expire after inherited from framework' do
    assert_equal 6.hours, @auth.current_session_expire_after(user)
  end

  it '01: oauth configs is hash' do
    assert_kind_of Hash, @auth.platform_oauth_configs('test_platform')
  end

  it '01: oauth secrets is hash' do
    assert_kind_of Hash, @auth.platform_oauth_secrets('test_platform')
  end

  it '01: oauth providers is hash' do
    assert_kind_of Hash, @auth.oauth_platform_secrets_for_provider('test_platform', 'test_oauth_1')
  end

end
