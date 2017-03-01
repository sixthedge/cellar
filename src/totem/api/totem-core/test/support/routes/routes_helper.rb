require File.expand_path('../../support_helper', __FILE__)

def register_route_engines
  clear_engine_instances
  file = nil
  @engine_instances                  = Hash.new
  @engine_instances[:framework_core] = register_engine(file: file, path: 'test/framework/core', platform_path: 'test/framework')
  @engine_instances[:framework_zero] = register_engine(file: file, path: 'test/framework/zero', platform_path: 'test/framework')
  @engine_instances[:framework_one]  = register_engine(file: file, path: 'test/framework/one',  platform_path: 'test/framework')
  @engine_instances[:framework_two]  = register_engine(file: file, path: 'test/framework/two',  platform_path: 'test/framework')
  @engine_instances[:platform_main]  = register_engine(file: file)
  @engine_instances[:platform_zero]  = register_engine(file: file, path: 'test/platform/zero')
  @engine_instances[:platform_one]   = register_engine(file: file, path: 'test/platform/one')
  @engine_instances[:platform_two]   = register_engine(file: file, path: 'test/platform/two')
end

def mock_engine_routes(name)
  engine = @engine_instances && @engine_instances[name]
  raise "Engine instance with name #{name.inspect} does not exist."  if engine.blank?
  engine.config.paths['config/routes.rb'] = ["#{engine.root}/config/routes.rb"]
  engine.define_singleton_method(:routes) do
    @routes = ::ActionDispatch::Routing::RouteSet.new
    @routes
  end
  engine
end

def set_route_set
  @rs = ::ActionDispatch::Routing::RouteSet.new
end

def set_mock_mapper
  @mock_mapper = MiniTest::Mock.new
end

def set_routes_engines
  @routes = Totem::Core::Routes::Engines.new
end

def set_routes_invalid
  @routes = Totem::Core::Routes::Invalid.new
end

# ###
# Another approach to testing the routes.  However, the downside is
# need to add 'controller: value' and 'action: value' to the route options config
# so the Rails mapper will not error (controller/action values can be anything valid).
  # it 'example with route set' do
  #   set_environment
  #   set_routes_engines
  #   set_route_set
  #   register_route_engines
  #   load_platform_configs(file: __FILE__, file_ext: 'error/xx_*', clear_engines: false)
  #   register_framework_and_platform
  #   mock_engine_routes(:platform_one)
  #   env    = @env
  #   routes = @routes
  #   e = assert_raises(RuntimeError) do
  #     @rs.draw do
  #       concern  :test_framework, routes
  #       concerns :test_framework, env: env, platform_name: 'test_platform'
  #     end
  #   end
  #   assert_match(/error message/i, e.to_s)
  # end
