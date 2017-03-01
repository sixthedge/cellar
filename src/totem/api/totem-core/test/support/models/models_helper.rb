require File.expand_path('../../support_helper', __FILE__)

# ### Set Model Associations and Verify Expectations ### #

def set_mock_model_associations(*args)
  options = args.extract_options!
  mock    = args.shift
  sz_mock = args.shift
  fn      = options[:fn]
  dir     = options[:dir]
  set_associations_filename(dir, fn)
  add_mock_model_associations(mock, sz_mock)
end

def add_mock_model_associations(mock, sz_mock=nil)
  @env.associations.perform(mock, {})
  assert mock.verify
  assert sz_mock.verify  if sz_mock.present?
end

# Set the association.yml file (with filename prefix) relative to the test folder.
def set_associations_filename(dir, fn)
  load_platform_configs(file: __FILE__, file_ext: '01_*')
  set_db_associations_filename(dir, fn)
  register_models_engines
  @env.engine.reset!
  register_framework_and_platform
end

def set_db_associations_filename(dir=nil, fn=nil)
  filename      = fn.present?  ? "#{fn}_associations.yml" : 'associations.yml'
  full_filename = dir.present? ? "#{dir}/#{filename}"     : filename
  @env.option.db_associations_filename = full_filename
end

def register_models_engines
  clear_engine_instances
  file         = __FILE__
  root_path    = File.expand_path("../", file)
  db_path      = ['fixtures_associations']
  platform_one = register_engine(file: file, path: 'test/associations/one', platform_scope: 'test_platform')
  platform_one.set_root(root_path)
  platform_one.config.paths[:db] = db_path
  platform_two = register_engine(file: file, path: 'test/associations/two', platform_scope: 'test_platform')
  platform_two.set_root(root_path)
  platform_two.config.paths[:db] = db_path
end

# ### Basic test to ensure registration works ### #

def basic_association_paths_test
  set_db_associations_filename
  register_models_engines
  @env.engine.reset!
  assert_equal 2, @env.engine.association_paths.length
end

# ### Mock Model ### #

def mock_model(options={})
  path    = options[:path]
  klass   = options[:model]
  raise "Must supply a class or path to mock model path."  if path.blank? && klass.blank?
  mock    = MiniTest::Mock.new
  klass   = path_to_class(path)  if klass.blank?
  expect_model_common(mock, klass, options)
  expect_model_attributes(mock, options)
  mock
end

def expect_model_common(mock, klass, options={})
  mock.expect :ancestors, [ActiveRecord::Base]
  mock.expect :blank?, false
  ntimes = options[:times] || 10
  mock_expect_ntimes(mock, :kind_of?, true, [Class], ntimes)
  mock_expect_ntimes(mock, :parents, klass.parents, [], ntimes)
  mock_expect_ntimes(mock, :name, klass.name, [], ntimes)
end

def expect_model_attributes(mock, options={})
  attributes = [options[:attributes]].flatten.compact
  mock.expect(:table_exists?, true)
  mock.expect(:column_names, attributes)
  attributes.each do |column|
    mock_expect_ntimes(mock, :method_defined?, true, [column], 1)
  end
end

# A scope 'expect' require special handling since are lambdas.
def expect_model_association_with_scope(mock, options)
  fn         = options[:fn]     || ''
  scopes     = options[:scopes] || {}
  args       = options[:args]
  assoc_name = options[:assoc_name]
  method     = options[:method]
  scope_mock = MiniTest::Mock.new
  scopes.each do |scope_method, scope_args|
    scope_args = scope_args.kind_of?(Array) ? scope_args : [scope_args].flatten.compact
    scope_mock.expect(scope_method, scope_mock, scope_args)  # return self (e.g. scope_mock) so chained methods will succeed
  end
  scope_class = path_to_class("test/associations/one/scope_#{fn}", SimpleDelegator)
  mock.expect(method, nil) do |name, scope, hash|
    if name == assoc_name && hash == args && scope.kind_of?(Proc)
      sm = scope_class.new(scope_mock)
      sm.instance_exec &scope
      assert scope_mock.verify
    else
      false
    end
  end
end

# ### Mock Serializer ### #

def mock_serializer(options={})
  path       = options[:path]
  serializer = options[:serializer]
  model      = options[:model]
  case 
  when path.present?
    klass = path_to_class(path)
  when serializer.present?
    klass = serializer
  when model.present?
    klass = path_to_class(model.name + 'Serializer')
  else
    raise "Must supply a :model class, :serializer class or :path to mock model path."
  end
  mock = MiniTest::Mock.new
  klass.define_singleton_method(:root=)      {|arg| mock.root = arg}
  klass.define_singleton_method(:attribute)  {|*args| mock.attribute(*args)}
  klass.define_singleton_method(:attributes) {|*args| mock.attributes(*args)}
  klass.define_singleton_method(:has_one)    {|*args| mock.has_one(*args)}
  klass.define_singleton_method(:has_many)   {|*args| mock.has_many(*args)}
  expect_serializer_common(mock, model, options)  if model.present?
  mock
end

def expect_serializer_common(mock, model, options={})
  attributes = options[:attributes] || []
  mock.expect :root=, nil, [c_path(model)]
  mock.expect :attributes, nil, attributes
  mock.expect :present?, true, []
end

def set_base_framework_serializer_class
  path_to_class('test/framework/serializer/base', base_serializer_class)
end

def base_serializer_class
  Totem::Core::BaseSerializer
end
