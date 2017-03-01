require File.expand_path('../../action_serializer_options_helper', __FILE__)

def assert_serializer_options_methods(keys, options, validate_mod=true)
  methods = get_serializer_options_methods(options)
  assert_kind_of Hash, methods, 'serializer options methods is a hash'
  keys = [keys].flatten.sort
  assert_equal keys, methods.keys.sort, 'has the keys'
  keys.each do |key|
    hash = methods[key]
    assert_kind_of Hash, hash, 'each serializer options methods key has a has value'
    inst = hash[:instance]
    refute_nil inst, 'should have an module instance'
    assert_serializer_options_module(inst, key)  if validate_mod
  end
  methods
end

def assert_serializer_options_module(inst, key)
  assert_equal key, inst.module_name, 'is the correct module'
end

def assert_before_action(methods, key, value)
  hash = methods[key]
  assert_equal value, hash[:before_action], 'before filter matches'
end


describe 'totem serializer options' do

  describe 'controller values'  do

    it 'users defaults' do
      options = {}
      methods = assert_serializer_options_methods(:users, options)
      assert_before_action(methods, :users, '[action]')
    end

    it 'users with name' do
      options = {name: :myusers}
      methods = assert_serializer_options_methods(:myusers, options, false)
      assert_before_action(methods, :myusers, '[action]')
      assert_serializer_options_module(methods[:myusers][:instance], :users)
    end

    it 'users with module name' do
      options = {module_name: :another_one}
      methods = assert_serializer_options_methods(:users, options, false)
      assert_serializer_options_module(methods[:users][:instance], :another_one)
    end

    it 'users with module' do
      options = {module: 'Test::SerializerOptions::AnotherOne'}
      methods = assert_serializer_options_methods(:users, options, false)
      assert_serializer_options_module(methods[:users][:instance], :another_one)
    end

    it 'users with before filter' do
      options = {before_action: :test_method}
      methods = assert_serializer_options_methods(:users, options)
      assert_before_action(methods, :users, 'test_method')
    end

    it 'users with before filter replace resource' do
      options = {before_action: '[resource]_test_method'}
      methods = assert_serializer_options_methods(:users, options)
      assert_before_action(methods, :users, 'users_test_method')
    end

    it 'users with module false' do
      options = {module: false}
      methods = get_serializer_options_methods(options)
      assert_equal true, methods.blank?, 'does not add a module'
    end

    it 'users with module false with other values' do
      options = {name: :test, module_name: :another_one, before_action: :test_before_action, module: false}
      methods = get_serializer_options_methods(options)
      assert_equal true, methods.blank?, 'does not add a module'
    end

  end

  describe 'controller with add key'  do

    it 'users default and another one default' do
      options = {add:[{name: :another_one}]}
      methods = assert_serializer_options_methods([:another_one, :users], options)
      assert_before_action(methods, :users, '[action]')
      assert_before_action(methods, :another_one, nil)
    end

    it 'add is array of string and symbol - set as name and module_name' do
      options = {add:['another_one', :another_two]}
      methods = assert_serializer_options_methods([:another_one, :another_two, :users], options)
      assert_before_action(methods, :users, '[action]')
      assert_before_action(methods, :another_one, nil)
      assert_before_action(methods, :another_two, nil)
    end

    it 'add is a symbol - set as name and module_name' do
      options = {add: :another_one}
      methods = assert_serializer_options_methods([:another_one, :users], options)
      assert_before_action(methods, :users, '[action]')
      assert_before_action(methods, :another_one, nil)
    end

    it 'add is a string - set as name and module_name' do
      options = {add: :another_two}
      methods = assert_serializer_options_methods([:another_two, :users], options)
      assert_before_action(methods, :users, '[action]')
      assert_before_action(methods, :another_two, nil)
    end

    it 'users module false and another one default' do
      options = {module: false, add:[{name: :another_one}]}
      methods = assert_serializer_options_methods([:another_one], options)
      assert_before_action(methods, :another_one, nil)
    end

    it 'users module false and another one before filter as hash' do
      options = {module: false, add: {name: :another_one, before_action: true}}
      methods = assert_serializer_options_methods([:another_one], options)
      assert_before_action(methods, :another_one, '[action]')
    end

    it 'users module false and another one before filter as array' do
      options = {module: false, add:[{name: :another_one, before_action: true}]}
      methods = assert_serializer_options_methods([:another_one], options)
      assert_before_action(methods, :another_one, '[action]')
    end

    it 'users, another one, another two default' do
      options = {add:[{name: :another_one}, {name: :another_two}]}
      methods = assert_serializer_options_methods([:another_one, :another_two, :users], options)
      assert_before_action(methods, :users, '[action]')
      assert_before_action(methods, :another_one, nil)
      assert_before_action(methods, :another_two, nil)
    end

    it 'users, another one, another two with values' do
      options = {add:[{name: :another_one, module_name: :another_two}, {name: :another_two}]}
      methods = assert_serializer_options_methods([:another_one, :another_two, :users], options, false)
      assert_serializer_options_module(methods[:users][:instance], :users)
      assert_serializer_options_module(methods[:another_one][:instance], :another_two)
      assert_serializer_options_module(methods[:another_two][:instance], :another_two)
      assert_before_action(methods, :users, '[action]')
      assert_before_action(methods, :another_one, nil)
      assert_before_action(methods, :another_two, nil)
    end

    it 'users, another one, another two module false' do
      options = {add:[{name: :another_one}, {name: :another_two, module: false}]}
      methods = assert_serializer_options_methods([:another_one, :users], options)
      assert_before_action(methods, :users, '[action]')
      assert_before_action(methods, :another_one, nil)
    end

  end

  def assert_before_action_args(action)
    controller = get_controller({action_name: action}, Test::SerializerOptions::ArgsController)
    methods    = controller.tso_method :serializer_options_methods
    rc         = controller.tso.before_action_process(controller)
    refute_nil rc, 'action method was run'
  end

  describe 'instance arg arity' do

    it 'zero' do
      assert_before_action_args :zero_args
    end

    it 'one' do
      assert_before_action_args :one_args
    end

    it 'two' do
      assert_before_action_args :two_args
    end

    it 'three not allowed' do
      e = assert_raises(so_error) {assert_before_action_args :three_args}
      assert_match(/more than 2 arguments/i, e.to_s)
    end

  end

  def assert_mock_module_method(options, key, action)
    controller = get_controller(options)
    methods    = controller.tso_method :serializer_options_methods
    inst       = methods[key][:instance]
    refute_nil inst, "instance for key #{key.inspect}"
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [so])
    inst.stub(action.to_sym, mock) do
      inst.send action, so
    end
    mock.verify
  end

  describe 'manually call' do

    it 'users' do
      options = {}
      assert_mock_module_method(options, :users, :index)
    end

    it 'users and another one' do
      options = {add:[{name: :another_one}]}
      assert_mock_module_method(options, :another_one, :index)
    end

  end

end

