require 'readiness_assurance_helper'
module Test; module Controller; class ReadinessAssuranceAdminIratsToTratTimerTest < ActionController::TestCase
  include ReadinessAssurance::Helpers::All

  def default_timer_settings; Hash(type: :countdown, unit: :minute, interval: 2, room_event: :test, title: :error_title, user_id: 1); end

  add_test(Proc.new do |route|
    describe 'to trat timer errors' do
      before do; @route = route; @timer_settings = default_timer_settings.deep_dup; end
      def timer_settings; @timer_settings; end
      let(:timer_start_at) {time_now}
      let(:timer_end_at)   {time_now + 15.minutes}
      let(:due_at)         {time_now + 20.minutes}
      let(:params)         {get_timer_params}
      it 'bad type'     do; timer_settings[:type]     = :xxxx; assert_unauthorized(send_route_request, 'type.*must be'); end
      it 'bad unit'     do; timer_settings[:unit]     = :xxxx; assert_unauthorized(send_route_request, 'unit.*must be'); end
      it 'bad interval' do; timer_settings[:interval] = '1x';  assert_unauthorized(send_route_request, 'interval.*must be'); end
      it 'bad due_at'   do; params_irat.delete(:due_at);          assert_unauthorized(send_route_request, 'due_at.*blank'); end
      it 'bad start_at' do; params_irat.delete(:timer_start_at);  assert_unauthorized(send_route_request, 'timer.*requires.*timer_start_at'); end
      it 'bad interval with start_at' do; timer_settings.delete(:interval); assert_unauthorized(send_route_request, 'timer.*requires.*interval'); end
    end
  end) # proc

  @co = new_route_config_options(tests: get_tests, test_action: :to_trat)
  @co.only :readiness_assurance, :irats
  include ReadinessAssurance::Helpers::Route::Irats

end; end; end
