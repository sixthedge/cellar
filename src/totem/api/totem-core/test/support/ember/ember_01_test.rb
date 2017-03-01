require File.expand_path('../ember_helper', __FILE__)

def expect_ember_primary_keys
  [
    :framework,
    :platform,
    :require_paths,
    :namespaces,
    :session,
  ].sort
end

describe '01: ember.rb config' do

  before do
    before_ember_common
  end

  it '01: should be valid' do 
    assert_kind_of Hash, @config
    refute_empty @config, 'Ember config should be populated.'
  end

  it '01: should have primary keys' do 
    assert_equal expect_ember_primary_keys, @config.keys.sort
  end

  it '01: framework should be valid' do 
    assert_kind_of Hash, @framework
    refute_empty @framework, 'Ember framework should be populated.'
  end

  it '01: platform should be valid' do 
    assert_kind_of Hash, @platform
    refute_empty @platform, 'Ember platform should be populated.'
  end

  it '01: require paths should be valid' do 
    assert_kind_of Hash, @require_paths
    refute_empty @require_paths, 'Ember require paths should be populated.'
  end

  it '01: namespaces should be valid' do 
    assert_kind_of Array, @namespaces
    refute_empty @namespaces, 'Ember namespaces should be populated.'
    assert_kind_of Hash, @namespaces.first
  end

  if debug_on
    it '01: debug' do
      puts "\n"
      puts "01: Ember config primary keys: #{@config.keys.inspect}\n\n"
    end
  end

end

describe '01: ember.rb javascript require paths' do

  before do 
    before_ember_common
  end

  it '01: sub type [common] symbol works' do
    actual = @ember.javascript_require_paths('test/platform', :common).flatten.sort
    expect = ['test/platform/one/master', 'test/platform/two/master'].sort
    assert_equal expect, actual
  end

  it '01: sub type [common] string works' do
    actual = @ember.javascript_require_paths('test/platform', 'common').flatten.sort
    expect = ['test/platform/one/master', 'test/platform/two/master'].sort
    assert_equal expect, actual
  end

  it '01: sub type [another]' do
    actual = @ember.javascript_require_paths('test/platform', :another).flatten.sort
    expect = ['test/platform/three/master'].sort
    assert_equal expect, actual
  end

  it '01: sub type [common, another]' do
    actual = @ember.javascript_require_paths('test/platform', :common, :another).flatten.sort
    expect = ['test/platform/one/master', 'test/platform/two/master', 'test/platform/three/master'].sort
    assert_equal expect, actual
  end

  it '01: sub types blank gets all sub types' do
    actual = @ember.javascript_require_paths('test/platform').flatten.sort
    expect = ['test/platform/one/master', 'test/platform/two/master', 'test/platform/three/master'].sort
    assert_equal expect, actual
  end

  it '01: bad sub type' do
    actual = @ember.javascript_require_paths('test/platform', :bad)
    expect = []
    assert_equal expect, actual
  end

end

describe '01: ember.rb stylesheet @import paths' do

  before do 
    before_ember_common
  end

  it '01: sub type [common] symbol works' do
    actual = @ember.stylesheet_import_paths('test/platform', :common)
    expect = stylesheet_imports('test/platform/one/master', 'test/platform/two/master')
    expect = ['', expect].flatten.join("\n")
    assert_equal expect, actual
  end

  it '01: sub type [common] string works' do
    actual = @ember.stylesheet_import_paths('test/platform', 'common')
    expect = stylesheet_imports('test/platform/one/master', 'test/platform/two/master')
    expect = ['', expect].flatten.join("\n")
    assert_equal expect, actual
  end

  it '01: sub type [another]' do
    actual = @ember.stylesheet_import_paths('test/platform', :another)
    expect = stylesheet_imports('test/platform/three/master')
    expect = ['', expect].flatten.join("\n")
    assert_equal expect, actual
  end

  it '01: sub type [common, another]' do
    actual = @ember.stylesheet_import_paths('test/platform', :common, :another)
    expect = stylesheet_imports('test/platform/one/master', 'test/platform/two/master', 'test/platform/three/master')
    expect = ['', expect].flatten.join("\n")
    assert_equal expect, actual
  end

  it '01: sub types blank gets all sub types' do
    actual = @ember.stylesheet_import_paths('test/platform')
    expect = stylesheet_imports('test/platform/one/master', 'test/platform/two/master', 'test/platform/three/master')
    expect = ['', expect].flatten.join("\n")
    assert_equal expect, actual
  end

  it '01: bad sub type' do
    actual = @ember.stylesheet_import_paths('test/platform', :bad)
    assert_equal '', actual
  end

end
