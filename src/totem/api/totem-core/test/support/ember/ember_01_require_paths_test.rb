require File.expand_path('../ember_helper', __FILE__)

# Require paths is the merge of the framework and platform require_paths hashes.
# The require paths first level sub-keys are only used for grouping in the yaml file and not kept.
def expect_ember_require_paths
  {
    "test.framework.auth"        => "test/framework/ember/auth/config/initializers/auth",
    "test.framework.ember"       => "test/framework/ember/config/initializers/ember",
    "test.framework.app"         => "test/framework/ember/config/app",
    "test.framework.store"       => "test/framework/ember/config/initializers/data_stores/store",
    "test.framework.logger"      => "test/framework/ember/lib/logger",
    "test.platform.module_1"     => "test/platform/main/lib/module_1",
    "test.platform.module_2"     => "test/platform/main/lib/module_2",
    "test.platform.one.module_1" => "test/platform/one/lib/module_1",
    "test.platform.one.module_2" => "test/platform/one/lib/module_1",
    "test.platform.two.module_1" => "test/platform/two/lib/module_1",
    "platform.locales"           => "test/platform/main/locales/locales",
  }
end

describe '01: ember.rb require paths' do

  before do
    before_ember_common
  end

  it '01: should be valid' do 
    assert_kind_of Hash, @require_paths
    refute_empty @require_paths, 'Ember require paths should be populated.'
  end

  it '01: should be merge of the framework and platform require paths' do 
    assert_equal expect_ember_require_paths, @require_paths
  end

  if debug_on
    it '01: debug' do
      puts "\n"
      pp '01: Ember require paths config:', @require_paths
    end
  end

end

