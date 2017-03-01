require File.expand_path('../ember_helper', __FILE__)

# Namespaces is the merge of the framework and platform namespaces.
# The namespace sources are the config's keys 'paths' and 'ember => path_namespaces'.
# The ember.rb should fill in any gaps in the namespaces and they should be ordered
# hierarchily for Ember creation (e.g. create 'App.Platform' before 'App.Platform.Main').

def find_by_namespace(name)
  @namespaces.select {|ns| ns[:namespace] == name}
end

def namespace_assertions(namespace, aliases)
  ns = find_by_namespace(namespace)
  assert_equal 1, ns.length
  ns = ns.first
  assert_equal [aliases].flatten.sort, ns[:alias].sort
end

describe '02: ember.rb namespaces' do

  before do
    before_ember_common(file_ext: '02_*')
  end

  it '02: should be valid' do 
    assert_kind_of Array, @namespaces
    refute_empty @namespaces, 'Ember namespaces should be populated.'
    assert_kind_of Hash, @namespaces.first
  end

  it '02: removed when namespace is false' do 
    assert_equal [], find_by_namespace('Test.Platform.NoNamespace')
  end

  # Caution: make sure another path doesn't require this namespace.
  # For example, a different path's namespace 'Test.Platform.Common.Tools' will
  # insert a Test.Platform.Common namespace in the namespace hierarchy.
  it '02: removed when namespace key is present' do 
    assert_equal [], find_by_namespace('Test.Platform.Common')
  end

  it '02: namespace array alias overrides path default alias' do
    namespace_assertions('Test.Platform.MyCommon', ['common', 'my_common'])
  end

  it '02: namespace string alias overrides path default alias and in array' do
    namespace_assertions('Test.Platform.MyCommon.Tools', 'tools')
  end

  it '02: path with no namespace keys gets defaults' do
    namespace_assertions('Test.Platform.Tools.Two', 'test.platform.tools.two')
  end

  if debug_on
    it '02: debug' do
      puts "\n"
      pp '02: Ember namespaces config:', @namespaces
    end
  end

end

describe '02: ember.rb ember=>path_namespaces' do

  before do
    before_ember_common(file_ext: '02_*')
  end

  it '02: same options as paths' do
    namespace_assertions('Test.Me', 'test.me')
    namespace_assertions('Test.Me.Special', 'me_special')
  end

  it '02: creates new top level namespace' do
    namespace_assertions('New', 'new')
    namespace_assertions('New.Top', 'new.top')
    namespace_assertions('New.Top.Level', 'new.top.level')
    namespace_assertions('New.Top.Level.Namespace', 'new.top.level.namespace')
  end

  it '02: removed when namespace is false' do 
    assert_equal [], find_by_namespace('Test.Platform.Ember.NoNamespace')
  end

end

