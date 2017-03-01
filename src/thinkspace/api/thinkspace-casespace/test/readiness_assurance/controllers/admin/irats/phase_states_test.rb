require 'readiness_assurance_helper'
module Test; module Controller; class ReadinessAssuranceAdminIratsPhaseStatesTest < ActionController::TestCase
  include ReadinessAssurance::Helpers::All

  def get_params(state=:complete)
    user_ids = ownerables.map(&:id)
    {irat: {user_ids: user_ids, phase_state: state}}
  end

  add_test(Proc.new do |route|
    describe 'phase states' do
      let(:params) {get_params}
      before do; @route = route; end
      it 'completed' do
        assert_authorized(send_route_request)
        assert_phase_state(:completed, irat_phase, read_1)
        assert_phase_state(:completed, irat_phase, read_2)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'phase states' do
      let(:params) {get_params(:lock)}
      before do; @route = route; end
      it 'locked' do
        assert_authorized(send_route_request)
        assert_phase_state(:locked, irat_phase, read_1)
        assert_phase_state(:locked, irat_phase, read_2)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'phase states' do
      let(:params) {get_params(:unlock)}
      before do; @route = route; end
      it 'unlocked' do
        assert_authorized(send_route_request)
        assert_phase_state(:unlocked, irat_phase, read_1)
        assert_phase_state(:unlocked, irat_phase, read_2)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'phase states' do
      def params; get_params(@test_state); end
      let(:ownerables)  {[read_1]}
      before do; @route = route; end
      it 'unlocked -> locked -> completed' do
        @test_state = :unlock
        assert_authorized(send_route_request)
        assert_phase_state(:unlocked, irat_phase, read_1)
        @test_state = :lock
        send_route_request
        assert_phase_state(:locked, irat_phase, read_1)
        @test_state = :complete
        send_route_request
        assert_phase_state(:completed, irat_phase, read_1)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'phase states' do
      def default_message; "IRAT phase set to 'completed'"; end
      let(:params) {Hash(irat: {user_ids: [read_1.id], phase_state: :complete, message: default_message})}
      let(:ownerables)  {[read_1]}
      before do; @route = route; end
      it 'unlocked -> locked -> completed' do
        assert_authorized(send_route_request)
        assert_phase_state(:completed, irat_phase, read_1)
        assert_server_event_message
        assert_admin_server_event_message
        assert_server_event_phase_states(:complete)
      end
    end
  end) # proc

  @co = new_route_config_options(tests: get_tests, test_action: :phase_states)
  @co.only :readiness_assurance, :irats
  include ReadinessAssurance::Helpers::Route::Irats

end; end; end

