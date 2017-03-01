require 'sandbox_helper'
module Test; module Controller; class SandboxSpacesShowTest < ActionController::TestCase
  include Sandbox::Helpers::All

  add_test(Proc.new do |route|
    describe 'read_1 space show' do
      let(:user)   {read_1}
      let(:record) {read_1_space}
      before do; @route = route; end
      it 'sandbox space' do
        json = send_route_request
        assert_space_assignment_ids(json, record, user_cases)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'phase states' do
      let(:user)   {read_2}
      let(:record) {read_2_space}
      before do; @route = route; end
      it 'completed' do
        json = send_route_request
        assert_space_assignment_ids(json, record, user_cases)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'sandbox and NOT sandbox assignments' do
      let(:user)        {read_1}
      let(:record)      {read_1_space}
      before do; @route = route; end
      it 'master-sandbox assignment space id replaced by read_1-sandbox space id and one NOT sandbox assignment space id unchanged' do
        assignment = create_not_sandbox_assignment(record)
        json       = send_route_request
        assert_space_assignment_ids(json, record, user_cases + [assignment])
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'sandbox and NOT sandbox assignments' do
      let(:user)        {read_1}
      let(:record)      {read_1_space}
      before do; @route = route; end
      it 'master-sandbox assignment space id replaced by read_1-sandbox space id and two NOT sandbox assignment space ids unchanged' do
        assignment_1 = create_not_sandbox_assignment(record)
        assignment_2 = create_not_sandbox_assignment(record)
        json       = send_route_request
        assert_space_assignment_ids(json, record, user_cases + [assignment_1, assignment_2])
      end
    end
  end) # proc

  @co = new_route_config_options(tests: get_tests, test_action: :show)
  @co.only :common, :spaces, :show

  include Sandbox::Helpers::Route::Controller

end; end; end
