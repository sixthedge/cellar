require File.expand_path('../ember_helper', __FILE__)

def expect_ember_framework_primary_keys
  [
    :api_handler_root_path,
    :auth,
    :css,
    :default_fatal_message,
    :environment,
    :name,
    :path_namespaces,
    :register,
    :route_map_paths,
    :template_paths,
  ].sort
end

describe '01: ember.rb framework' do

  before do 
    before_ember_common
  end

  it '01: should have primary keys' do
    assert_equal expect_ember_framework_primary_keys, @framework.keys.sort
  end

  it '01: environment' do
    assert_equal 'test', @framework[:environment]
  end

  it '01: name' do
    assert_equal 'test_framework', @framework[:name]
  end

  it '01: default fatal message' do
    assert_equal 'A fatal framework error occurred.', @framework[:default_fatal_message]
  end

  it '01: route_map_paths' do
    assert_kind_of Array, @framework[:route_map_paths]
    assert_equal ['test/framework/ember/config/routes'].sort, @framework[:route_map_paths].sort
  end

  it '01: api handler root path' do
    assert_equal 'test/framework/ember/lib/messages/handlers/', @framework[:api_handler_root_path]
  end

  it '01: path namespaces' do
    assert_equal [], @framework[:path_namespaces]
  end

  it '01: template paths' do
    expect = {'template_path_1' => 'test/framework/ember/auth/path1', 'template_path_2' => 'test/framework/ember/path2'}
    paths  = @framework[:template_paths]
    assert_kind_of Hash, paths
    assert_equal expect, paths
  end

  it '01: require paths' do
    paths = @framework[:require_paths]
    assert_nil paths, "Framework requirie paths should be moved to primary key."
  end

  it '01: auth' do
    auth = @framework[:auth]
    assert_kind_of Hash, auth
    assert_equal '/test/framework/authentication/oauth/sign_out',auth['sign_out_url']
    assert_equal 'auth_token', auth['tokenKey']
    assert_equal 'user_id', auth['tokenIdKey']
    assert_equal ['emberData','rememberable'].sort, auth['modules'].sort
  end

  it '01: auth authRedirectable' do
    auth = @framework[:auth]['authRedirectable']
    assert_kind_of Hash, auth
    assert_equal 'sign_in', auth['route']
    assert_equal 'another', auth['another']
  end

  it '01: auth actionRedirectable' do
    auth = @framework[:auth]['actionRedirectable']
    assert_kind_of Hash, auth
    assert_equal true, auth['signInSmart']
    assert_kind_of Array, auth['signInBlacklist']
    assert_equal ['sign_in'], auth['signInBlacklist']
  end

  it '01: register' do
    register = @framework[:register]
    assert_kind_of Hash, register
  end

  it '01: register route' do
    register = @framework[:register]['route']
    assert_kind_of Hash, register
    assert_equal 'test.framework.auth_ns.SignInRoute', register['sign_in']
    assert_equal 'test.framework.auth_ns.SignOutRoute', register['sign_out']
  end

  it '01: register controller' do
    register = @framework[:register]['controller']
    assert_kind_of Hash, register
    assert_equal 'test.framework.auth_ns.SignInController', register['sign_in']
    assert_equal 'test.framework.auth_ns.SignOutController', register['sign_out']
  end

  it '01: css' do
    css = @framework[:css]
    assert_kind_of Hash, css
    assert_equal ['body_class', 'another_class'].sort, css.keys.sort
    assert_equal 'test-framework more-framework', css['body_class']
    assert_equal 'test-framework-another', css['another_class']
  end

  if debug_on
    it '01: debug' do
      puts "\n"
      pp '01: Ember framework config:', Hash[@framework.sort_by{|k,v| k}]
    end
  end


end

