require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class ModelStatePhases < ActionController::TestCase
  include Casespace::Ability
  include Casespace::Utility
  include Controller
  include Model
  include ModelState

  describe @phases_controller do
    before do; set_current_ability(:phases); end

    let(:user)         {create_model_state_user(role)}
    let(:space)        {create_model_state_space}
    let(:assignment)   {create_model_state_assignment}
    let(:phases)       {create_model_state_phases}
    let(:record)       {assignment}
    let(:action)       {:index}

    describe 'read..phases' do
      let(:role) {:read}
      it 'phases' do; assert_phases; end
    end

    describe 'update..phases' do
      let(:role) {:update}
      it 'phases' do; assert_phases; end
    end

    describe 'owner..phases' do
      let(:role) {:owner}
      it 'phases' do; assert_phases; end
    end

  end # describe controller

end; end; end
