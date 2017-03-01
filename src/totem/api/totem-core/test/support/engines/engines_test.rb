require File.expand_path('../../support_helper', __FILE__)

def framework_user; path_to_class('test/framework/core/user'); end
def user; path_to_class('test/platform/main/user'); end

def engine_platform_hash
  {
    'test_platform_main' => 'Test::Platform::Main',
    'test_platform_one'  => 'Test::Platform::One',
    'test_platform_two'  => 'Test::Platform::Two',
  }
end

def engine_platform_names
  engine_platform_hash.keys.sort
end

def before_engines_common
  set_environment
  load_platform_configs
  @platform_engine_main = register_engine
  @platform_engine_one  = register_engine(path: 'test/platform/one')
  @platform_engine_two  = register_engine(path: 'test/platform/two')
  @engine = @env.engine
end

def assert_engine_instance_variable(var, value)
  assert @engine.instance_variable_defined?(var), "Instance variable #{var.inspect} should be defined."
  assert_equal value, @engine.instance_variable_get(var)
end

describe 'engines.rb' do

  before do 
    set_environment
    load_platform_configs
    @engine = @env.engine
  end

  it 'should be valid' do 
    assert_kind_of Array, @engine.engines
  end

  it 'should be populated' do 
    register_engine
    refute_empty @engine.engines, 'Engines should be populated.'
  end

end

describe 'engines.rb engine instances' do

  before do 
    before_engines_common
  end

  it 'registered engines are populated' do
    expect = [@platform_engine_main, @platform_engine_one, @platform_engine_two]
    assert_equal expect, @engine.engines
  end

  it 'only registered engines are returned' do
    register_engine(path: 'test/platform/three', register: false)
    assert_equal 4, @engine.engines.length
    assert_equal 3, @env.registered.engines.length
    expect = [@platform_engine_main, @platform_engine_one, @platform_engine_two]
    actual = @engine.engines.select { |e| @engine.is_registered_platform_engine?(e) }
    assert_equal expect, actual
  end

  it 'engines_reset!' do 
    assert_equal 3, @engine.engines.length
    @engine.engines_reset!
    assert_engine_instance_variable('@engine_instances', nil)
  end

end

describe 'engines.rb instance variables' do

  before do 
    before_engines_common
  end

  it 'names' do 
    assert_equal engine_platform_names, @engine.names.sort
  end

  # The full engine class name includes class-name::Engine.
  # However, the configured 'engine name' does not include ::Engine, nor does the table name prefix.
  it 'name and engine' do 
    assert_equal engine_platform_names, @engine.name_and_engine.keys.sort
    engine_platform_hash.each do |name, class_name|
      assert_equal "#{class_name}::Engine", @engine.name_and_engine[name].class.name
    end
  end

  it 'name and class' do 
    assert_equal engine_platform_names, @engine.name_and_class.keys.sort
    engine_platform_hash.each do |name, class_name|
      assert_equal class_name, @engine.name_and_class[name]
    end
  end

  it 'path and name' do 
    paths = engine_platform_hash.values.collect {|c| c.underscore }.sort
    assert_equal paths, @engine.path_and_name.keys.sort
    engine_platform_hash.each do |name, class_name|
      assert_equal name, @engine.path_and_name[class_name.underscore]
    end
  end

  it 'association paths' do 
    register_engine(path: 'test/platform/three')
    register_engine(path: 'test/platform/four')
    actual = @engine.association_paths.sort
    assert_kind_of Array, actual
    assert_equal 2, actual.length
    assert_match('test_platform_one', actual.first)
    assert_match('test_platform_three', actual.last)
  end

  it 'associations file name blank error' do
    @env.option.db_associations_filename = nil
    e = assert_raises(RuntimeError) do
      @engine.association_paths
    end
    assert_match(/associations file name.*blank/i, e.to_s)
  end

  it 'reset!' do 
    @engine.names
    @engine.name_and_engine
    @engine.name_and_class
    @engine.path_and_name
    @engine.association_paths
    @engine.reset!
    assert_engine_instance_variable('@engine_names', nil)
    assert_engine_instance_variable('@engine_name_and_engine', nil)
    assert_engine_instance_variable('@engine_name_and_class', nil)
    assert_engine_instance_variable('@engine_path_and_name', nil)
    assert_engine_instance_variable('@engine_association_paths', nil)
  end

end

describe 'engines.rb helpers' do

  before do 
    before_engines_common
  end

  it 'loaded?' do 
    engine_platform_hash.each do |name, class_name|
      assert @engine.loaded?(name), "Engine #{name.inspect} should be loaded."
    end
  end

  it 'to engine name' do
    assert_equal 'test_platform_main', @engine.to_engine_name('Test::Platform::Main')
    assert_equal 'test_platform_main', @engine.to_engine_name('test/platform/main')
    assert_equal 'test_platform_main', @engine.to_engine_name('test_platform_main')
    # will not convert:
    refute_match 'test_platform_main', @engine.to_engine_name('Test.Platform.Main')
    assert_nil @engine.to_engine_name(Test::Platform::Main), "To engine name with non-string should be nil."
  end

end

describe 'engines.rb finders' do

  before do 
    before_engines_common
  end

  it 'get by name' do
    assert_equal 1, @engine.get_by_name('test_platform_main').length
    assert_kind_of Test::Platform::Main::Engine, @engine.get_by_name('test_platform_main').first
    assert_equal 1, @engine.get_by_name('test_platform_one').length
    assert_kind_of Test::Platform::One::Engine, @engine.get_by_name('test_platform_one').first
    assert_equal 1, @engine.get_by_name('test_platform_two').length
    assert_kind_of Test::Platform::Two::Engine, @engine.get_by_name('test_platform_two').first
    assert_equal [], @engine.get_by_name('test_platform_bad')
  end

  it 'find by name' do
    engine_platform_names.each do |name|
      assert_equal [name], @engine.find_by_name(name)
    end
    assert_equal [], @engine.find_by_name('test_platform_bad')
  end

  it 'find by starts with' do
    assert_equal engine_platform_names, @engine.find_by_starts_with('test').sort
  end

  it 'find by starts with new platform' do
    register_engine(path: 'test/platform/new_one')
    register_engine(path: 'test/platform/new_two')
    assert_equal ['test_platform_new_one', 'test_platform_new_two'].sort, @engine.find_by_starts_with('test_platform_new').sort
  end

  it 'find by starts with bad platform' do
    assert_equal [], @engine.find_by_starts_with('bad').sort
  end

end

# To get the current platform name, engine.rb first gets the engine name from the
# table name prefix class method, then does a lookup on the engine's registered platform name.
describe 'engines.rb current platform name' do

  before do 
    before_engines_common
    register_engine(path: 'test/framework/core', platform_name: 'test_framework', platform_path: 'test/framework')
    @current_framework = 'test_framework'
    @current_platform  = 'test_platform'
  end

  it 'framework from class' do
    assert_equal @current_framework, @engine.current_platform_name(framework_user)
  end

  it 'framework from instance' do
    assert_equal @current_framework, @engine.current_platform_name(framework_user.new)
  end

  it 'platform from class' do
    assert_equal @current_platform, @engine.current_platform_name(user)
  end

  it 'platform from instance' do
    assert_equal @current_platform, @engine.current_platform_name(user.new)
  end

end
