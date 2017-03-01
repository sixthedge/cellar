require File.expand_path('../routes_helper', __FILE__)

describe 'routes.rb errors' do

  before do
    set_environment
    set_mock_mapper
    set_routes_engines
  end

  it 'no platform name' do
    e = assert_raises(RuntimeError) do
      @routes.call(@mock_mapper)
    end
    assert_match(/no platform.*for routes/i, e.to_s)
  end

  it 'E01: mount options not blank or a hash' do
    e = assert_raises(RuntimeError) do  # raised by configuration.rb
      load_platform_configs(file: __FILE__, file_ext: 'error/01_*')
    end
    assert_match(/path.*not blank.*hash/i, e.to_s)
  end

  it 'E02: match options not blank or a hash' do
    e = assert_raises(RuntimeError) do  # raised by configuration.rb
      load_platform_configs(file: __FILE__, file_ext: 'error/02_*')
    end
    assert_match(/path.*not blank.*hash/i, e.to_s)
  end

  it 'E03: no platform paths' do
    load_platform_configs(file: __FILE__, file_ext: 'error/03_*')
    e = assert_raises(RuntimeError) do
      @routes.call(@mock_mapper, platform_name: 'test_platform')
    end
    assert_match(/no.*paths.*for platform/i, e.to_s)
  end

  it 'E04: no engine with name' do
    register_route_engines
    load_platform_configs(file: __FILE__, file_ext: 'error/04_*', clear_engines: false)
    register_framework_and_platform
    @env.engine.instance_variable_set('@engine_name_and_engine', {})
    e = assert_raises(RuntimeError) do
      @routes.call(@mock_mapper, env: @env, platform_name: 'test_platform')
    end
    assert_match(/no engine.*with name.*_one/i, e.to_s)
  end

  it 'E04: path mount options not a hash' do
    register_route_engines
    load_platform_configs(file: __FILE__, file_ext: 'error/04_*', clear_engines: false)
    register_framework_and_platform
    mock_engine_routes(:platform_one)
    @env.config.paths('test_platform').first.routes.mount = 'not_a_hash'
    e = assert_raises(RuntimeError) do
      @routes.call(@mock_mapper, env: @env, platform_name: 'test_platform')
    end
    assert_match(/mount options.*hash/i, e.to_s)
  end

  it 'E04: path match not a hash' do
    register_route_engines
    load_platform_configs(file: __FILE__, file_ext: 'error/04_*', clear_engines: false)
    register_framework_and_platform
    mock_engine_routes(:platform_one)
    @env.config.paths('test_platform').first.routes.match = 'not_a_hash'
    e = assert_raises(RuntimeError) do
      @mock_mapper.expect(:mount, nil, [Class, Hash])
      @routes.call(@mock_mapper, env: @env, platform_name: 'test_platform')
    end
    assert_match(/matches.*hash/i, e.to_s)
  end

  it 'E04: path match match-options not a hash' do
    register_route_engines
    load_platform_configs(file: __FILE__, file_ext: 'error/04_*', clear_engines: false)
    register_framework_and_platform
    mock_engine_routes(:platform_one)
    @env.config.paths('test_platform').first.routes.match[:test_match] = 'not_a_hash'
    e = assert_raises(RuntimeError) do
      @mock_mapper.expect(:mount, nil, [Class, Hash])
      @routes.call(@mock_mapper, env: @env, platform_name: 'test_platform')
    end
    assert_match(/test_match.*options.*hash/i, e.to_s)
  end

  it 'E04: platform match not a hash' do
    register_route_engines
    load_platform_configs(file: __FILE__, file_ext: 'error/04_*', clear_engines: false)
    register_framework_and_platform
    mock_engine_routes(:platform_one)
    @env.config.routes('test_platform')[:match] = 'not_a_hash'
    e = assert_raises(RuntimeError) do
      @mock_mapper.expect(:mount, nil, [Class, Hash])
      @routes.call(@mock_mapper, env: @env, platform_name: 'test_platform')
    end
    assert_match(/routes: match:.*hash/i, e.to_s)
  end

  it 'E05: no route constraints generated' do
    register_route_engines
    load_platform_configs(file: __FILE__, file_ext: 'error/05_*', clear_engines: false)
    register_framework_and_platform
    mock_engine_routes(:platform_one)
    e = assert_raises(RuntimeError) do
      @routes.call(@mock_mapper, env: @env, platform_name: 'test_platform')
    end
    assert_match(/not generate.*constraints/i, e.to_s)
  end

  it 'E06: bad constraint key' do
    register_route_engines
    load_platform_configs(file: __FILE__, file_ext: 'error/06_*', clear_engines: false)
    register_framework_and_platform
    mock_engine_routes(:platform_one)
    e = assert_raises(RuntimeError) do
      @routes.call(@mock_mapper, env: @env, platform_name: 'test_platform')
    end
    assert_match(/unknown.*bad_key/i, e.to_s)
  end

end
