require 'readiness_assurance_helper'
module Test; module Controller; class ReadinessAssuranceAdminMessagesToUsersTest < ActionController::TestCase
  include ReadinessAssurance::Helpers::All

  add_test(Proc.new do |route|
    describe 'to users' do
      before do; @route = route; end
      let(:authable) {assignment}
      let(:params)   {Hash(message: {message: default_message, user_ids: [read_1.id, read_2.id]})}
      it 'user ids only' do
        assert_authorized(send_route_request)
        assert_server_event_message
        assert_admin_server_event_message
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'to users' do
      before do; @route = route; end
      let(:authable) {assignment}
      let(:params)   {Hash(message: {message: default_message, team_ids: [team_1.id]})}
      it 'team ids only' do
        assert_authorized(send_route_request)
        assert_server_event_message
        assert_admin_server_event_message
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'to users' do
      before do; @route = route; end
      let(:authable)   {assignment}
      let(:ownerables) {[read_1] + team_2_users}
      let(:params)     {Hash(message: {message: default_message, user_ids: [read_1.id], team_ids: [team_2.id]})}
      it 'user_ids and team ids' do
        assert_authorized(send_route_request)
        assert_server_event_message
        assert_admin_server_event_message
      end
    end
  end) # proc

  @co = new_route_config_options(tests: get_tests, test_action: :to_users)
  @co.only :readiness_assurance, :messages
  include ReadinessAssurance::Helpers::Route::Irats

end; end; end
