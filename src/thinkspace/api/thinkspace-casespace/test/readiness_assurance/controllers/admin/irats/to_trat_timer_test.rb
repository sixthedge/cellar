require 'readiness_assurance_helper'
module Test; module Controller; class ReadinessAssuranceAdminIratsToTratTimerTest < ActionController::TestCase
  include ReadinessAssurance::Helpers::All

  add_test(Proc.new do |route|
    describe 'to trat timer' do
      let(:timer_settings) {Hash(type: :countdown, unit: :minute, interval: 2, room_event: :test_down, title: :test_countdown_title, user_id: 1)}
      let(:timer_start_at) {time_now}
      let(:timer_end_at)   {time_now + 15.minutes}
      let(:due_at)         {timer_end_at}
      let(:params)         {get_timer_params}
      before do; @route = route; end
      it 'countdown' do
        assert_authorized(send_route_request)
        assert_server_event_transition_to_phase_with_message
        assert_server_event_timer_transition_to_phase(timer_settings)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'to trat timer' do
      let(:timer_settings) {Hash(type: :countup, unit: :second, interval: 30, room_event: :test_up, title: :test_countup_title, user_id: 1)}
      let(:timer_start_at) {time_now}
      let(:timer_end_at)   {time_now + 15.minutes}
      let(:due_at)         {timer_end_at}
      let(:params)         {get_timer_params}
      before do; @route = route; end
      it 'countup' do
        assert_authorized(send_route_request)
        assert_server_event_transition_to_phase_with_message
        assert_server_event_timer_transition_to_phase(timer_settings)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'to trat timer' do
      let(:timer_settings) {Hash(type: :once, title: :test_once_title, user_id: 2)}
      let(:due_at)         {time_now + 5.minutes}
      let(:params)         {get_timer_params}
      before do; @route = route; end
      it 'once' do
        assert_authorized(send_route_request)
        assert_server_event_transition_to_phase_with_message
        assert_server_event_timer_transition_to_phase(timer_settings)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'to trat timer' do
      let(:timer_settings) {Hash(type: :countdown, unit: :minute, interval: 2, room_event: :test_down, title: :test_countdown_title, user_id: 1)}
      let(:timer_start_at) {time_now}
      let(:timer_end_at)   {time_now + 15.minutes}
      let(:due_at)         {timer_end_at}
      let(:params)         {get_timer_params}
      before do; @route = route; end
      it 'countdown without message' do
        params_irat.delete(:message)
        assert_authorized(send_route_request)
        assert_admin_server_event_message
        assert_no_server_event(:message)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'to trat timer' do
      let(:timer_settings) {Hash(type: :once, title: :test_once_title, user_id: 2)}
      let(:due_at)         {time_now + 5.minutes}
      let(:params)         {get_timer_params}
      before do; @route = route; end
      it 'once without message' do
        params_irat.delete(:message)
        assert_authorized(send_route_request)
        assert_admin_server_event_message
        assert_no_server_event(:message)
      end
    end
  end) # proc

  @co = new_route_config_options(tests: get_tests, test_action: :to_trat)
  @co.only :readiness_assurance, :irats
  include ReadinessAssurance::Helpers::Route::Irats

end; end; end
