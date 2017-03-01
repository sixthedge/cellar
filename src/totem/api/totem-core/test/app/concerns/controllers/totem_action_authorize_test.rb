require File.expand_path('../../action_authorize_helper', __FILE__)

def assert_mock_no_override_method(method, options, args=[])
  c      = get_no_overrides_aa_controller(options)
  args   = args.collect {|a| a == :controller ? c : a}
  mock   = MiniTest::Mock.new
  mock.expect(:call, nil, args)
  c.stub(method, mock) do
    c.run_before_action(c)
  end
  mock.verify
end

# These tests only verify the class method options are set up correctly, not the implementation (e.g. no database).

describe 'totem action authorize' do

  describe 'controller options'  do

    describe 'auth:' do

      it 'default' do
        method  = 'totem_action_authorize_record_from_params!'
        options = {method: false, ownerable: false, view_type: false, verify_record_ownerable: false}
        assert_mock_no_override_method(method, options)
      end

      it 'method' do
        method  = 'test_override_method_name'
        options = {auth: method}
        c       = get_aa_controller(options)
        e       = assert_raises(rt_error) {c.run_before_action(c)}
        assert_match(/not respond to.*#{method}/i, e.to_s)
      end

      it 'override' do
        method  = 'totem_action_authorize_record_from_params!'
        options = {}
        c       = get_aa_controller(options)
        e       = assert_raises(rt_error) {c.run_before_action(c)}
        assert_match(/#{method}/i, e.to_s)
      end

    end

    describe 'ownerable:' do

      it 'default' do
        method  = 'totem_action_authorize_ownerable_record_from_params!'
        options = {method: false, auth: false, view_type: false, verify_record_ownerable: false}
        assert_mock_no_override_method(method, options)
      end

      it 'method' do
        method  = 'test_override_method_name'
        options = {auth: false, ownerable: method }
        c       = get_aa_controller(options)
        e       = assert_raises(rt_error) {c.run_before_action(c)}
        assert_match(/not respond to.*#{method}/i, e.to_s)
      end

      it 'override' do
        method  = 'totem_action_authorize_ownerable_record_from_params!'
        options = {auth: false}
        c       = get_aa_controller(options)
        e       = assert_raises(rt_error) {c.run_before_action(c)}
        assert_match(/#{method}/i, e.to_s)
      end

    end

    describe 'view_type:' do

      it 'default' do
        method  = 'totem_action_authorize_view_type_from_params!'
        options = {method: false, auth: false, ownerable: false}
        assert_mock_no_override_method(method, options)
      end

      it 'method' do
        method  = 'test_override_method_name'
        options = {auth: false, ownerable: false, view_type: method }
        c       = get_aa_controller(options)
        e       = assert_raises(rt_error) {c.run_before_action(c)}
        assert_match(/not respond to.*#{method}/i, e.to_s)
      end

      it 'override' do
        method  = 'totem_action_authorize_view_type_from_params!'
        options = {auth: false, ownerable: false}
        c       = get_aa_controller(options)
        e       = assert_raises(rt_error) {c.run_before_action(c)}
        assert_match(/#{method}/i, e.to_s)
      end

    end

    describe 'verify_record_ownerable:' do

      it 'default' do
        method  = 'totem_action_authorize_verify_record_ownerable!'
        options = {method: false, ownerable: false, auth: false, view_type: false}
        assert_mock_no_override_method(method, options, [:controller, :ownerable])
      end

      it 'default with polymorphic:' do
        method  = 'totem_action_authorize_verify_record_ownerable!'
        options = {auth: false, ownerable: false, view_type: false, verify_record_ownerable: method, polymorphic: :test_poly}
        c       = get_aa_controller(options)
        e       = assert_raises(rt_error) {c.run_before_action(c)}
        assert_match(/#{method}.*polymorphic :test_poly/i, e.to_s)
      end

      it 'method' do
        method  = 'test_override_method_name'
        options = {auth: false, ownerable: false, view_type: false, verify_record_ownerable: method}
        c       = get_aa_controller(options)
        e       = assert_raises(rt_error) {c.run_before_action(c)}
        assert_match(/not respond to.*#{method}/i, e.to_s)
      end

      it 'override' do
        method  = 'totem_action_authorize_verify_record_ownerable!'
        options = {auth: false, ownerable: false, view_type: false}
        c       = get_aa_controller(options)
        e       = assert_raises(rt_error) {c.run_before_action(c)}
        assert_match(/#{method}.*polymorphic :ownerable/i, e.to_s)
      end

    end

  end

end
