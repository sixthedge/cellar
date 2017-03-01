require File.expand_path('../../support_helper', __FILE__)

def class_config_class;  Totem::Core::Settings::ConfigClass; end
def module_config_class; Totem::Core::Settings::ConfigModule; end

describe '01: registration.rb framework classes after register' do

  before do 
    set_environment
    load_platform_configs(file: __FILE__, file_ext: '01_*')
    register_framework_and_platform
    @class     = @env.class
    @framework = @class.test_framework
  end

  it '01: should be valid' do 
    assert_kind_of Hash, @class
    assert_equal [:test_platform, :test_framework].sort, @class.keys.sort
  end

  it '01: should be kind of config class' do 
    assert_kind_of class_config_class, @framework
  end

  it '01: has class' do 
    assert @framework.has_class?(:class_1), "Framework should have class_1."
    assert @framework.has_class?(:class_2), "Framework should have class_2."
    assert @framework.has_class?(:class_3), "Framework should have class_3."
  end

  it '01: should have classes' do 
    assert_equal path_to_class('test/framework/core/class_1'), @framework.class_1
    assert_equal path_to_class('test/framework/core/controllers/class_2'), @framework.class_2
    assert_equal path_to_class('test/framework/core/models/class_3'), @framework.class_3
  end

  if debug_on
    it '01: debug' do
      puts "\n"
      pp '01: Registration classes:', @framework
    end
  end

end

describe '01: registration.rb framework modules after register' do

  before do 
    set_environment
    load_platform_configs(file: __FILE__, file_ext: '01_*')
    register_framework_and_platform
    @module    = @env.module
    @framework = @module.test_framework
  end

  it '01: should be valid' do 
    assert_kind_of Hash, @module
    assert_equal [:test_platform, :test_framework].sort, @module.keys.sort
  end

  it '01: should be kind of config class' do 
    assert_kind_of module_config_class, @framework
  end

  it '01: has module' do 
    assert @framework.has_module?(:module_0), "Framework should have module_0."
    assert @framework.has_module?(:module_1), "Framework should have module_1."
    assert @framework.has_module?(:module_2), "Framework should have module_2."
    assert @framework.has_module?(:module_3), "Framework should have module_3."
  end

  it '01: should have modules' do
    assert_equal path_to_module('test/framework/core/module_1'), @framework.module_1
    assert_equal path_to_module('test/framework/core/controllers/module_2'), @framework.module_2
    assert_equal path_to_module('test/framework/core/models/module_3'), @framework.module_3
    assert_equal path_to_module('test/framework/core/module_0'), @framework.module_0
  end

  it '01: modules should be returned in order' do 
    expect = [
      path_to_module('test/framework/core/module_1'),
      path_to_module('test/framework/core/controllers/module_2'),
      path_to_module('test/framework/core/models/module_3'),
      path_to_module('test/framework/core/module_0'),
    ]
    assert_equal expect, @framework.get_all
  end

  if debug_on
    it '01: debug' do
      puts "\n"
      pp '01: Registration modules:', @framework
    end
  end

end

# ### PLATFORM ### #
describe '01: registration.rb platform classes after register' do

  before do 
    set_environment
    load_platform_configs(file: __FILE__, file_ext: '01_*')
    register_framework_and_platform
    @class    = @env.class
    @platform = @class.test_platform
  end

  it '01: should be valid' do 
    assert_kind_of Hash, @class
    assert_equal [:test_platform, :test_framework].sort, @class.keys.sort
  end

  it '01: should be kind of config class' do 
    assert_kind_of class_config_class, @platform
  end

  it '01: has class' do 
    assert @platform.has_class?(:class_1), "Platform should have class_1."
    assert @platform.has_class?(:class_2), "Platform should have class_2."
    assert @platform.has_class?(:class_3), "Platform should have class_3."
  end

  it '01: should have classes' do 
    assert_equal path_to_class('test/platform/main/class_1'), @platform.class_1
    assert_equal path_to_class('test/framework/core/controllers/class_2'), @platform.class_2
    assert_equal path_to_class('test/platform/main/models/class_3'), @platform.class_3
  end

  if debug_on
    it '01: debug' do
      puts "\n"
      pp '01: Registration classes:', @platform
    end
  end

end

describe '01: registration.rb platform modules after register' do

  before do 
    set_environment
    load_platform_configs(file: __FILE__, file_ext: '01_*')
    register_framework_and_platform
    @module   = @env.module
    @platform = @module.test_platform
  end

  it '01: should be valid' do 
    assert_kind_of Hash, @module
    assert_equal [:test_platform, :test_framework].sort, @module.keys.sort
  end

  it '01: should be kind of config class' do 
    assert_kind_of module_config_class, @platform
  end

  it '01: has module' do 
    assert @platform.has_module?(:module_0), "Platform should have module_0."
    assert @platform.has_module?(:module_1), "Platform should have module_1."
    assert @platform.has_module?(:module_2), "Platform should have module_2."
    assert @platform.has_module?(:module_3), "Platform should have module_3."
  end

  it '01: should have inherited framework modules' do
    assert_equal path_to_module('test/platform/main/module_1'), @platform.module_1
    assert_equal path_to_module('test/framework/core/controllers/module_2'), @platform.module_2
    assert_equal path_to_module('test/platform/main/models/module_3'), @platform.module_3
    assert_equal path_to_module('test/framework/core/module_0'), @platform.module_0
  end

  it '01: modules should be returned in order' do 
    expect = [
      path_to_module('test/platform/main/module_1'),
      path_to_module('test/framework/core/controllers/module_2'),
      path_to_module('test/platform/main/models/module_3'),
      path_to_module('test/framework/core/module_0'),
    ]
    assert_equal expect, @platform.get_all
  end

  if debug_on
    it '01: debug' do
      puts "\n"
      pp '01: Registration modules:', @platform
    end
  end

end
