require File.expand_path('../authentication_helper', __FILE__)

describe '02: authentication.rb with platform overrides' do

  before do 
    before_authentication_common(file_ext: 'value/02_*')
  end

  it '02: current session' do
    expect = {timeout_time: 600, expire_after_time: 3600, sample_key: 'platform'}
    assert_equal expect, @auth.current_session(user)
  end

  it '02: current session timeout' do
    assert_equal 10.minutes, @auth.current_session_timeout(user)
  end

  it '02: current session expire after' do
    assert_equal 1.hours, @auth.current_session_expire_after(user)
  end

end

describe '02: authentication.rb platform oauth providers' do

  before do 
    before_authentication_common(file_ext: 'value/02_*')
    set_secrets_oauth_providers(file: __FILE__, file_ext: 'value/secrets/02_')
  end

  it '02: all configs regardless of active status' do
    expect = {
      'test_oauth_1'=>{'site'=>'http://localhost:1111', 'active'=>true},
      'test_oauth_2'=>{'site'=>'http://localhost:2222', 'active'=>true},
      'test_oauth_3'=>{'site'=>'http://localhost:3333', 'active'=>false},
      'test_oauth_4'=>{'site'=>'http://localhost:4444', 'active'=>true},
    }
    assert_equal expect, @auth.oauth_configs
  end

  it '02: active platform configs' do
    expect = {
      'test_oauth_1'=>{'site'=>'http://localhost:1111', 'active'=>true},
      'test_oauth_4'=>{'site'=>'http://localhost:4444', 'active'=>true},
    }
    assert_equal expect, @auth.platform_oauth_configs('test_platform')
  end

  it '02: same active platform configs with current object' do
    expect = {
      'test_oauth_1'=>{'site'=>'http://localhost:1111', 'active'=>true},
      'test_oauth_4'=>{'site'=>'http://localhost:4444', 'active'=>true},
    }
    assert_equal expect, @auth.current_platform_oauth_configs(user)
  end

  it '02: active platform secrets' do
    expect = {
      'test_oauth_1'=>{'client_id'=>'1111-123456789', 'client_secret'=>'1111-987654321', 'active'=>true},
      'test_oauth_4'=>{'client_id'=>'4444-123456789', 'client_secret'=>'4444-987654321', 'active'=>true},
    }
    assert_equal expect, @auth.platform_oauth_secrets('test_platform')
  end

  it '02: same active platform secrets with current object' do
    expect = {
      'test_oauth_1'=>{'client_id'=>'1111-123456789', 'client_secret'=>'1111-987654321', 'active'=>true},
      'test_oauth_4'=>{'client_id'=>'4444-123456789', 'client_secret'=>'4444-987654321', 'active'=>true},
    }
    assert_equal expect, @auth.current_platform_oauth_secrets(user)
  end

  it '02: oauth platform secrets for test_oauth_1' do
    expect = {'client_id'=>'1111-123456789', 'client_secret'=>'1111-987654321', 'active'=>true}
    assert_equal expect, @auth.oauth_platform_secrets_for_provider('test_platform', 'test_oauth_1')
  end

  it '02: oauth platform secrets for test_oauth_2' do
    assert_equal Hash.new, @auth.oauth_platform_secrets_for_provider('test_platform', 'test_oauth_2')
  end

  it '02: oauth platform secrets for test_oauth_3' do
    assert_equal Hash.new, @auth.oauth_platform_secrets_for_provider('test_platform', 'test_oauth_3')
  end

  it '02: oauth platform secrets for test_oauth_4' do
    expect = {'client_id'=>'4444-123456789', 'client_secret'=>'4444-987654321', 'active'=>true}
    assert_equal expect, @auth.oauth_platform_secrets_for_provider('test_platform', 'test_oauth_4')
  end

end

describe '02: authentication.rb ominiauth strategies' do

  before do 
    before_authentication_common(file_ext: 'value/02_*')
  end

  it '03: active provider stategy classes added' do
    set_secrets_oauth_providers(file: __FILE__, file_ext: 'value/secrets/03_')
    set_oauth_providers
    expect = [:TestOauth1].sort
    assert_equal expect, OmniAuth::Strategies.constants.grep(/Test/).sort
  end

  it '02: active provider stategy classes added' do
    set_secrets_oauth_providers(file: __FILE__, file_ext: 'value/secrets/02_')
    set_oauth_providers
    expect = [:TestOauth1, :TestOauth2, :TestOauth4].sort
    assert_equal expect, OmniAuth::Strategies.constants.grep(/Test/).sort
  end

end
