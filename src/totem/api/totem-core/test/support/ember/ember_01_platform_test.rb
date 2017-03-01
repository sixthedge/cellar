require File.expand_path('../ember_helper', __FILE__)

def expect_ember_platform_primary_keys
  [
    :auth,
    :css,
    :default_fatal_message,
    :locale,
    :name,
    :path_namespaces,
    :route_map_paths,
    :routes,
    :template_paths,
  ].sort
end

describe '01: ember.rb platform' do

  before do 
    before_ember_common
  end

  it '01: should have primary keys' do
    assert_equal expect_ember_platform_primary_keys, @platform.keys.sort
  end

  it '01: auth' do
    auth = @platform[:auth]
    assert_kind_of Hash, auth
    assert_equal '/test/platform/main/home/sign_out', auth['sign_out_url']
    assert_equal 'test.platform.main.user_ns', auth['user_namespace']
    assert_equal '/test/platform/main/users/sign_in', auth['signInEndPoint']
  end

  it '01: auth actionRedirectable' do
    auth = @platform[:auth]['actionRedirectable']
    assert_kind_of Hash, auth
    assert_equal 'test/platform/main/sign_in_route', auth['signInRoute']
  end

  it '01: css' do
    css = @platform[:css]
    assert_kind_of Hash, css
    assert_equal ['body_class', 'another_class'].sort, css.keys.sort
    assert_equal 'test-platform', css['body_class']
    assert_equal 'test-platform-another', css['another_class']
  end

  it '01: default fatal message' do
    assert_equal 'A fatal platform error occurred.', @platform[:default_fatal_message]
  end

  it '01: locale' do
    assert_equal 'en', @platform[:locale]
  end

  it '01: name' do
    assert_equal 'test_platform', @platform[:name]
  end

  it '01: path namespaces' do
    expect = [{
      path: 'test/platform/special/namespace',
      ember: {
        namespace:       'Test.Platform.Special.Namespace',
        namespace_alias: ['test.platform.special.namespace'],
      }
    }]
    assert_equal expect, @platform[:path_namespaces]
  end

  it '01: route_map_paths' do
    assert_kind_of Array, @platform[:route_map_paths]
    expect = ['test/platform/main/config/routes', 'test/platform/one/config/routes', 'test/platform/two/config/routes'].sort
    assert_equal expect, @platform[:route_map_paths].sort
  end

  it '01: routes' do
    assert_kind_of Hash, @platform[:routes]
    expect = {url: 'api', glob_match: '*ember'}
    assert_equal expect, @platform[:routes]
  end

  it '01: template paths' do
    expect = {'template_path_1' => 'test/platform/path1', 'template_path_2' => 'test/platform/path2', 'template_path_3' => 'test/platform/path3'}
    paths  = @platform[:template_paths]
    assert_kind_of Hash, paths
    assert_equal expect, paths
  end

  it '01: require paths' do
    paths = @platform[:require_paths]
    assert_nil paths, "Platform requirie paths should be moved to primary key."
  end

  if debug_on
    it '01: debug' do
      puts "\n"
      pp '01: Ember platform config:', Hash[@platform.sort_by{|k,v| k}]
    end
  end

end
