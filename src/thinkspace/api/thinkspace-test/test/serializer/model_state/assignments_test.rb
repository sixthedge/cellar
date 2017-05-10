require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class ModelStateAssignments < ActionController::TestCase
  include Casespace::Ability
  include Casespace::Utility
  include Controller
  include Model
  include ModelState

  describe @assignments_controller do
    before do; set_current_ability(:phases); end

    let(:user)         {create_model_state_user(role)}
    let(:space)        {create_model_state_space}
    let(:assignments)  {create_model_state_assignments}
    let(:phases)       {create_model_state_phases}
    let(:record)       {space}
    let(:action)       {:index}

    describe 'read..assignments' do
      let(:role) {:read}
      it 'assignments' do; assert_assignments; end
    end

    describe 'update..assignments' do
      let(:role) {:update}
      it 'phases' do; assert_assignments; end
    end

    describe 'owner..assignments' do
      let(:role) {:owner}
      it 'phases' do; assert_assignments; end
    end

  end # describe controller

end; end; end
