require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class ModelStateSpaces < ActionController::TestCase
  include Casespace::Ability
  include Casespace::Utility
  include Controller
  include Model
  include ModelState

  def create_spaces
    spaces = Array.new
    spaces.push create_model_state_space(:active)
    spaces.push create_model_state_space(:inactive)
    spaces.push create_model_state_space(:neutral)
    spaces.each do |space|
      create_model_state_space_user(space, user, role, :active)
    end
    spaces
  end

  def assert_spaces
    serializer_options.add_attributes(:state)
    serializer_options.remove_all
    json = serialize
    assert_kind_of Hash, json, "json should be a hash #{json.inspect}"
    sjson = json[space_class.name.underscore.pluralize]
    assert_kind_of Array, sjson, "space json should be an array #{sjson.inspect}"
    states = get_role_states
    actual = sjson.length
    expect = states.length
    assert_equal expect, actual,  "#{role}..should have #{expect} spaces not #{actual} for states #{states}"
    bad_spaces = sjson.select {|s| !states.include?(s[:state])}
    assert_equal 0, bad_spaces.length, "#{role}..should only have spaces in #{states} #{bad_spaces.inspect}"
  end

  describe @spaces_controller do
    before do; set_current_ability(:spaces); end

    let(:user)         {create_model_state_user(role)}
    let(:spaces)       {create_spaces}
    let(:space)        {nil}
    let(:record)       {space_class.where(id: spaces.map(&:id)).accessible_by(get_current_ability, :read)}
    let(:action)       {:index}

    describe 'read..spaces' do
      let(:role) {:read}
      it 'read..spaces' do; assert_spaces; end
    end

    describe 'read..spaces' do
      let(:role) {:update}
      it 'update..spaces' do; assert_spaces; end
    end

    describe 'owner..spaces' do
      let(:role) {:owner}
      it 'owner..spaces' do; assert_spaces; end
    end

  end # describe controller

end; end; end
