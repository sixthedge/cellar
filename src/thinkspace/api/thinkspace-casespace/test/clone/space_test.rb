require 'clone_helper'
Test::Casespace::Seed.load(config: :clone)
module Test; module Clone; class Space < ActiveSupport::TestCase

  # Clone options: 
  #  keep_title:   [true|false] whether to keep the existing title in the cloned record
  #  title:        [string] specify a new title for main clone record
  #  space:        [record] assignment clone - specifies the space to clone the assignment into
  #  assignment:   [record] phase clone - specifies the assignment to clone the phase into

  include Casespace::Models
  include Casespace::Utility
  include Casespace::TerminalColors
  include Dictionary
  include Assert
  include Clone

  describe 'clone spaces'  do
    let (:ownerable)  {get_user(:update_1)}
    let (:user)       {get_user(:read_1)}
    let (:record)     {get_space(:clone_space_1)}

    describe 'single space - cloned title' do
      # let (:print_ids) {true}
      it "clone space" do
        cloned_space, options = clone_record
        assert_space_clone record, cloned_space, options.merge(keep_title: false)
      end
    end

    describe 'single space - keep title' do
      # let (:print_ids) {true}
      it "clone space" do
        cloned_space, options = clone_record keep_title: true
        assert_space_clone record, cloned_space, options.merge(keep_title: true)
      end
    end

    describe 'space title override' do
      # let (:print_ids) {true}
      it "clone space" do
        cloned_space, options = clone_record title: :test_title
        assert_space_clone record, cloned_space, options.merge(keep_title: false)
      end
    end

  end

end; end; end
