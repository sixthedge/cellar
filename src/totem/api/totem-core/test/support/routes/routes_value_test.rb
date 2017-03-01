require File.expand_path('../routes_helper', __FILE__)

def routes_common_values(config)
  register_route_engines
  load_platform_configs(file: __FILE__, file_ext: "value/#{config}_*", clear_engines: false)
  register_framework_and_platform
  mock_engine_routes(:platform_one)
  mock_engine_routes(:platform_two)
end

def engine_class_one; @engine_instances[:platform_one].class; end
def engine_class_two; @engine_instances[:platform_two].class; end

def routes_call_and_verify
  @routes.call(@mock_mapper, env: @env, platform_name: 'test_platform')
  @mock_mapper.verify
end

describe 'routes.rb values' do

  before do
    set_environment
    set_mock_mapper
    set_routes_engines
  end

  it 'V01: path routes inherit from platform routes' do
    routes_common_values('01')
    mount_one = [engine_class_one, {at: '/', constraints: {path: /(\/user|\/api\/test\/platform\/one)/}}]
    @mock_mapper.expect(:mount, nil, mount_one)
    match_glob = ['*ember', {to: 'test/platform/one/home#index', via: [:get]}]
    @mock_mapper.expect(:match, nil, match_glob)
    routes_call_and_verify
  end

  it 'V02: multiple path routes' do
    routes_common_values('02')
    mount_one = [engine_class_one, {at: '/', constraints: {path: /(\/user|\/api\/test\/platform\/one)/}}]
    @mock_mapper.expect(:mount, nil, mount_one)
    mount_two = [engine_class_two, {at: '/', constraints: {path: /\/api\/test\/platform\/two/}}]
    @mock_mapper.expect(:mount, nil, mount_two)
    match_glob = ['*ember', {to: 'test/platform/one/home#index', via: [:get]}]
    @mock_mapper.expect(:match, nil, match_glob)
    routes_call_and_verify
  end

  it 'V03: path url override' do
    routes_common_values('03')
    mount_one = [engine_class_one, {at: '/', constraints: {path: /\/path_api\/test\/platform\/one/}}]
    @mock_mapper.expect(:mount, nil, mount_one)
    routes_call_and_verify
  end

  it 'V04: mount at: override' do
    routes_common_values('04')
    mount_one = [engine_class_one, {at: '/one', constraints: {path: /\/api\/test\/platform\/one/}}]
    @mock_mapper.expect(:mount, nil, mount_one)
    mount_two = [engine_class_two, {at: '/main', constraints: {path: /\/api\/test\/platform\/two/}}]
    @mock_mapper.expect(:mount, nil, mount_two)
    routes_call_and_verify
  end

  it 'V05: mount at: override' do
    routes_common_values('05')
    mount_one = [engine_class_one, {at: '/', constraints: {path: /\/api\/test\/platform\/one/}}]
    @mock_mapper.expect(:mount, nil, mount_one)
    match_one_1 = ['test/one/match_one', {constraints: {path: /\/test\/one\/match_1/}, via: [:get]}]
    @mock_mapper.expect(:match, nil, match_one_1)
    match_one_2 = ['test/one/match_another', {to: 'somewhere', via: [:put]}]
    @mock_mapper.expect(:match, nil, match_one_2)
    routes_call_and_verify
  end

  it 'V06: mount and match in order' do
    # The order of the @mock_mapper.expect statements is the order the values are checked.
    routes_common_values('06')

    mount_one = [engine_class_one, {at: '/', constraints: {path: /\/api\/test\/platform\/one/}}]
    @mock_mapper.expect(:mount, nil, mount_one)
    match_one_1 = ['test/one/match_one', {constraints: {path: /\/test\/one\/match_1/}, via: [:get]}]
    @mock_mapper.expect(:match, nil, match_one_1)
    match_one_2 = ['test/one/match_another', {to: 'somewhere', via: [:put]}]
    @mock_mapper.expect(:match, nil, match_one_2)

    mount_two = [engine_class_two, {at: '/mount_two', constraints: {path: /(\/test\/platform\/two\/users|\/api\/test\/platform\/two)/}}]
    @mock_mapper.expect(:mount, nil, mount_two)
    match_two_1 = ['test/two/match_two', {constraints: {path: /\/test\/two\/match_1/}, via: [:get]}]
    @mock_mapper.expect(:match, nil, match_two_1)
    match_two_2 = ['test/two/match_another', {:via=>[:get, :post], :to=>"somewhere/else", :constraints=>{:path=>/\/api\/test\/platform\/two/}}]
    @mock_mapper.expect(:match, nil, match_two_2)

    match_glob = ['*home', {to: 'test/platform/main/home#index', via: [:get]}]
    @mock_mapper.expect(:match, nil, match_glob)

    routes_call_and_verify
  end

  it 'V07: bunches of options' do
    routes_common_values('07')

    mount_one = [engine_class_one, {:at=>"at", :via=>"put", :as=>"as", :constraints=>{:id=>/[A-Z]\d{5}/, :ip=>/192\.168\.\d+\.\d+/, :path=>/\/test\/platform\/one_path/, :format=>"jpg"}, :module=>"mymodule", :to=>"somewhere", :on=>true, :defaults=>"defaults", :anchor=>"anchor", :format=>"format", :controller=>"mycontroller", :action=>"myaction"}]
    @mock_mapper.expect(:mount, nil, mount_one)
    match_one_1 = ['test/one/match_another', {:via=>[:put], :to=>"somewhere", :at=>"at", :constraints=>{:ip=>/192\.168\.\d+\.\d+/, :path=>/\/test\/platform\/one_path/, :format=>"jpg"}, :controller=>"mycontroller", :action=>"myaction", :module=>"mymodule", :as=>"as", :on=>true, :defaults=>"defaults", :anchor=>"anchor", :format=>"format"}]
    @mock_mapper.expect(:match, nil, match_one_1)

    mount_two = [engine_class_two, {:constraints=>{:path=>/\/api\/test\/platform\/two/}, :at=>"/"}]
    @mock_mapper.expect(:mount, nil, mount_two)

    match_glob = ['*home', {to: 'test/platform/main/home#index', via: [:get]}]
    @mock_mapper.expect(:match, nil, match_glob)

    routes_call_and_verify
  end

end
