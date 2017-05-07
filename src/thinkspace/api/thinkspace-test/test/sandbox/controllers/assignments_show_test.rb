require 'sandbox_helper'
module Test; module Controller; class SandboxAssignmentsShowTest < ActionController::TestCase
  include Sandbox::Helpers::All

  add_test(Proc.new do |route|
    describe 'is sandbox' do
      let(:user)   {read_1}
      let(:record) {sandbox_assignment}
      before do; @route = route; end
      it 'master-sandbox space id replaced by read_1-sandbox space id' do
        json = send_route_request
        assert_assignment_space_id(json, read_1_space, record)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'NOT sandbox' do
      let(:user)   {read_1}
      let(:record) {not_sandbox_assignment}
      before do; @route = route; end
      it 'space id not changed' do
        space, assignment = create_not_sandbox_models
        json = send_route_request
        assert_assignment_space_id(json, space, assignment)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'is sandbox' do
      let(:user)   {read_2}
      let(:record) {sandbox_assignment}
      before do; @route = route; end
      it 'master-sandbox space id replaced by read_2-sandbox space id' do
        json = send_route_request
        assert_assignment_space_id(json, read_2_space, record)
      end
    end
  end) # proc

  @co = new_route_config_options(tests: get_tests, test_action: :show)
  @co.only :casespace, :assignments, :show

  include Sandbox::Helpers::Route::Controller

end; end; end
