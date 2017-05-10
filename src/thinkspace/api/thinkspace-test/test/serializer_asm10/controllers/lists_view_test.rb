require 'serializer_asm10_helper'
Test::Casespace::Seed.load(config: :all, dir: :staging)
module Test; module Controller; class SerializerAsm10ListsViewTest < ActionController::TestCase
  include SerializerAsm10::Helpers::All

  def get_list; Thinkspace::ObservationList::List.order(:id).first; end

  def create_observation
    Thinkspace::ObservationList::Observation.create(list_id: record.id, user_id: user.id, ownerable: user, position: 1, value: 'aaaaaaaa')
  end

  def create_observation_note
    Thinkspace::ObservationList::ObservationNote.create(observation_id: observation.id, value: 'nnnnnnnn')
  end

  add_test(Proc.new do |route|
    describe 'read_1 observation list view' do
      let(:user)   {get_user(:read_1)}
      let(:record) {get_list}

      let(:observation) {create_observation}

      let(:print_params)   {true}
      let(:print_json)     {true}

      before do; @route = route; end
      it 'SerializerAsm10 list' do
        create_observation_note
        json = send_route_request
# pp Thinkspace::ObservationList::List.all
# pp Thinkspace::ObservationList::Observation.all
# pp Thinkspace::ObservationList::ObservationNote.all
        # assert_space_assignment_ids(json, record, user_cases)
      end
    end
  end) # proc

  @co = new_route_config_options(tests: get_tests, test_action: :view)
  @co.only :observation_list, :list, :view

  include SerializerAsm10::Helpers::Route::Controller

end; end; end
