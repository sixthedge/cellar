require File.expand_path('../../action_serializer_options_helper', __FILE__)

describe 'totem serializer options errors' do

  describe 'controller module'  do

    it 'module not defined' do
      options = {module_name: 'xxxxx'}
      e = assert_raises(so_error) {get_controller(options)}
      assert_match(/cannot.*constantize/i, e.to_s)
    end

    it 'module not string or symbol' do
      options = {module: so_error}
      e = assert_raises(so_error) {get_controller(options)}
      assert_match(/be a string or symbol/i, e.to_s)
    end

    it 'module name not string or symbol' do
      options = {module_name: so_error}
      e = assert_raises(so_error) {get_controller(options)}
      assert_match(/be a string or symbol/i, e.to_s)
    end

    it 'module and module name' do
      options = {module: :test, module_name: :test}
      e = assert_raises(so_error) {get_controller(options)}
      assert_match(/use both/i, e.to_s)
    end

  end

  describe 'name'  do

    it 'not string or symbol' do
      options = {name: so_error}
      e = assert_raises(so_error) {get_controller(options)}
      assert_match(/be a string or symbol/i, e.to_s)
    end

    it 'blank' do
      options = {add: [{module: 'test'}]}
      e = assert_raises(so_error) {get_controller(options)}
      assert_match(/is blank/i, e.to_s)
    end

    it 'duplicate' do
      options = {add: [{name: :users}]}
      e = assert_raises(so_error) {get_controller(options)}
      assert_match(/exists/i, e.to_s)
    end

  end

  describe 'before filter'  do

    it 'not string or symbol' do
      options = {before_action: so_error}
      e = assert_raises(so_error) {get_controller(options)}
      assert_match(/be a string or symbol/i, e.to_s)
    end

  end

  describe 'invalid options'  do

    it 'not hash, string, symbol' do
      options = {add: so_error}  # so_error is a class not a hash, string or symbol
      e = assert_raises(so_error) {get_controller(options)}
      assert_match(/not a hash, string or symbol/i, e.to_s)
    end

    it 'not array of hashes' do
      options = {add: [so_error]}
      e = assert_raises(so_error) {get_controller(options)}
      assert_match(/not a hash, string or symbol/i, e.to_s)
    end

  end

  describe 'invalid options'  do

    it 'instance blank' do
      options    = {action_name: :index}
      controller = get_controller(options)
      methods    = controller.tso_method :serializer_options_methods
      methods[:users][:instance] = nil
      e = assert_raises(so_error) {controller.tso.before_action_process(controller)}
      assert_match(/instance is blank/i, e.to_s)
    end

    it 'missing method' do
      options    = {action_name: :xxxxxxx}
      controller = get_controller(options)
      methods    = controller.tso_method :serializer_options_methods
      e = assert_raises(so_error) {controller.tso.before_action_process(controller)}
      assert_match(/not respond to/i, e.to_s)
    end


  end

end
