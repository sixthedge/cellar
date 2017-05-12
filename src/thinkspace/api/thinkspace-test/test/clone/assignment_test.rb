require 'clone_helper'
Test::Casespace::Seed.load(config: :clone)
module Test; module Clone; class Assignment < ActiveSupport::TestCase

  include Casespace::Models
  include Casespace::Utility
  include Casespace::TerminalColors
  include Dictionary
  include Assert
  include Clone

  describe 'clone assignments'  do
    let (:ownerable)  {get_user(:update_1)}
    let (:user)       {get_user(:read_1)}
    let (:record)     {get_assignment(:clone_space_2_assignment)}
    let (:into_space) {get_space(:clone_space_2_into)}

    describe 'single assignment' do
      # let (:print_ids) {true}
      it "clone" do
        cloned_assignment, options = clone_record
        assert_assignment_clone record, cloned_assignment, options.merge(keep_title: false)
      end
    end

    describe 'assignment title override' do
      # let (:print_ids) {true}
      it "clone" do
        cloned_assignment, options = clone_record title: :test_title
        assert_assignment_clone record, cloned_assignment, options.merge(keep_title: false)
      end
    end

    describe 'single assignment into another space' do
      # let (:print_ids)  {true}
      it 'clone into space' do
        cloned_assignment, options = clone_record space: into_space, keep_title: true
        assert_assignment_clone record, cloned_assignment, options.merge(except_attributes: :space_id)
        assert_equal into_space.id, cloned_assignment.space_id, "cloned assignment in the correct space [id: #{into_space.id}]"
      end
    end

    describe 'same assignment cloned twice into another space' do
      # let (:print_ids)  {true}
      it 'clone twice into space' do
        cloned_assignment1, options1 = clone_record space: into_space, keep_title: true
        assert_assignment_clone record, cloned_assignment1, options1.merge(except_attributes: :space_id)
        assert_equal into_space.id, cloned_assignment1.space_id, "cloned assignment in the correct space [id: #{into_space.id}]"
        cloned_assignment2, options2 = clone_record space: into_space, keep_title: true
        assert_assignment_clone record, cloned_assignment2, options2.merge(except_attributes: :space_id)
        assert_equal into_space.id, cloned_assignment2.space_id, "cloned assignment in the correct space [id: #{into_space.id}]"
        assert_equal cloned_assignment1.title, cloned_assignment2.title, "both cloned assignments have same title"
      end
    end

  end

end; end; end
