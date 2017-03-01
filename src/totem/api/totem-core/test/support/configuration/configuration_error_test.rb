require File.expand_path('../configuration_helper', __FILE__)

describe 'configuration.rb errors' do

  before do 
    set_environment
    @config = @env.config
  end

  it 'no search directory' do
    e = assert_raises(RuntimeError) {load_platform_configs(file: false)}
    assert_match(/directory_search.*not been set/i, e.to_s)
  end

  it 'no file extension' do
    e = assert_raises(RuntimeError) {load_platform_configs(file_ext: false)}
    assert_match(/file_extension.*not been set/i, e.to_s)
  end

  it 'no config files' do
    e = assert_raises(RuntimeError) {load_platform_configs(file_ext: 'bad_ext')}
    assert_match(/no config files found/i, e.to_s)
  end

  it 'E01: path and name mismatch single file' do
    e = assert_raises(RuntimeError) {load_platform_configs(file: __FILE__, file_ext: 'error/01_*')}
    assert_match(/path.*does not match.*name/i, e.to_s)
  end

  it 'E02: path and name mismatch merge files' do
    e = assert_raises(RuntimeError) {load_platform_configs(file: __FILE__, file_ext: 'error/02_*')}
    assert_match(/path mis-match/i, e.to_s)
  end

  it 'E03: duplicate merge order' do
    e = assert_raises(RuntimeError) {load_platform_configs(file: __FILE__, file_ext: 'error/03_*')}
    assert_match(/merge order.*duplicates/i, e.to_s)
  end

  it 'E04: duplicate platform name in different file names' do
    e = assert_raises(RuntimeError) {load_platform_configs(file: __FILE__, file_ext: 'error/04_*')}
    assert_match(/duplicate platform name/i, e.to_s)
  end

  it 'E05: missing path value in paths section' do
    e = assert_raises(RuntimeError) {load_platform_configs(file: __FILE__, file_ext: 'error/05_*')}
    assert_match(/entry does not have a path value/i, e.to_s)
  end

  it 'E06: path has invalid platform reference' do
    e = assert_raises(RuntimeError) {load_platform_configs(file: __FILE__, file_ext: 'error/06_*')}
    assert_match(/path.*can not be resolved/i, e.to_s)
  end

  it 'E07: path has invalid path reference' do
    e = assert_raises(RuntimeError) {load_platform_configs(file: __FILE__, file_ext: 'error/07_*')}
    assert_match(/reference.*test_platform.*bad.*not found.*test_framework/i, e.to_s)
  end

  it 'E08: engine name class is blank' do
    e = assert_raises(RuntimeError) do
      clear_engine_instances
      register_engine
      @env.engine.instance_variable_set("@engine_name_and_class", {})
      load_platform_configs(file: __FILE__, file_ext: 'error/08_*', clear_engines: false)
    end
    assert_match(/engine path.*does not exist/i, e.to_s)
  end

  it 'E09: engine path does not match engine class' do
    e = assert_raises(RuntimeError) do
      clear_engine_instances
      # Must create a new unique class name for this test with a mis-matched engine name since the
      # mock engine methods will not override an existing class's method that provides the correct railtie name.
      register_engine(path: 'test/platform/unique_class_mismatch', engine_name: 'test_platform_engine_path_mismatch')
      @env.engine.instance_variable_set("@engine_name_and_class", {'test_platform_engine_path_mismatch' => 'Test::Platform::Main'})
      load_platform_configs(file: __FILE__, file_ext: 'error/09_*', clear_engines: false)
    end
    assert_match(/engine path.*does not match engine class/i, e.to_s)
  end

  it 'E10: duplicate path' do
    e = assert_raises(RuntimeError) {load_platform_configs(file: __FILE__, file_ext: 'error/10_*')}
    assert_match(/test_platform.*duplicate path/i, e.to_s)
  end

  it 'E11: config_files with bad path' do
    e = assert_raises(RuntimeError) {load_platform_configs(file: __FILE__, file_ext: 'error/10_*')}
    assert_match(/test_platform.*duplicate path/i, e.to_s)
  end

end

