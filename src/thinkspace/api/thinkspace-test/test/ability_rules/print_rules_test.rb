require 'ability_helper'
Test::Casespace::Seed.load(config: :ability)
module Test; module Ability; class PrintRules < ActiveSupport::TestCase

  include Casespace::TerminalColors
  include Casespace::Ability
  include Casespace::Models
  include Casespace::Utility
  include Rules

  # set_test_ability_classes File.expand_path('../../ability/ability_files', __FILE__)

  describe 'ability'  do

    let (:owner)    {get_user(:owner_1)}
    let (:updater)  {get_user(:update_1)}
    let (:reader)   {get_user(:read_1)}

    describe 'rules' do
      it "print" do
        # print_ability_rules(reader)
      end
    end

    # describe 'compare rules' do
    #   it "print" do
    #     compare_ability_rules(reader, owner)
    #   end
    # end

    # describe 'cancan rule objects' do
    #   it "print" do
    #     print_cancan_rules(phase_class, reader, updater, owner)
    #   end
    # end

  end

end; end; end
