require 'ability_helper'
Test::Casespace::Seed.load(config: :ability)
module Test; module Ability; class BaseModels < ActiveSupport::TestCase

  include Casespace::Models
  include Casespace::Ability
  include Casespace::Assert
  include Casespace::Utility

  models         = [get_space(:ability_space_1), get_assignment(:ability_assignment_1_1), get_phase(:ability_phase_1_1_A)]
  read_actions   = alias_read_actions
  modify_actions = [:update]

  describe 'can read' do
    @models  = models
    @actions = read_actions
    @users   = get_users :read_1, :update_1, :owner_1
    include TestCan
  end

  describe 'can update' do
    @models  = models
    @actions = modify_actions
    @users   = get_users :update_1, :owner_1
    include TestCan
  end

  describe 'cannot read' do
    @models  = models
    @actions = read_actions
    @users   = get_users :read_2, :update_2, :owner_2
    include TestCannot
  end

  describe 'cannot update' do
    @models  = models
    @actions = modify_actions
    @users   = get_users :read_1, :read_2, :update_2, :owner_2
    include TestCannot
  end

end; end; end
