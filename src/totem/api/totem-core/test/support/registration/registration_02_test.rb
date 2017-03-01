require File.expand_path('../../support_helper', __FILE__)

describe '02: registration.rb platform overrides framework classes after register' do

  before do 
    set_environment
    load_platform_configs(file: __FILE__, file_ext: '02_*')
    register_framework_and_platform
    @class  = @env.class
    @module = @env.module
  end

  it '02: should have classes' do 
    assert_equal path_to_class('test/platform/main/class_1'), @class.test_platform.class_1
    assert_equal path_to_class('test/platform/main/controllers/class_2'), @class.test_platform.class_2
    assert_equal path_to_class('test/platform/main/models/class_3'), @class.test_platform.class_3
  end

  it '02: should have modules' do
    assert_equal path_to_module('test/platform/main/module_1'), @module.test_platform.module_1
    assert_equal path_to_module('test/platform/main/controllers/module_2'), @module.test_platform.module_2
    assert_equal path_to_module('test/platform/main/models/module_3'), @module.test_platform.module_3
    assert_equal path_to_module('test/framework/core/module_0'), @module.test_platform.module_0
  end

  it '02: modules should be returned in order' do 
    expect = [
      path_to_module('test/platform/main/module_1'),
      path_to_module('test/platform/main/controllers/module_2'),
      path_to_module('test/platform/main/models/module_3'),
      path_to_module('test/framework/core/module_0'),
    ]
    assert_equal expect, @module.test_platform.get_all
  end


  if debug_on
    it '02: debug' do
      puts "\n"
      pp '02: Registration classes:', @class.test_platform
      pp '02: Registration modules:', @module.test_platform
    end
  end

end

