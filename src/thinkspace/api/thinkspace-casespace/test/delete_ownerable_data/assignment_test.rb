require 'delete_ownerable_data_helper'
module Test; module DeleteOwnerableData; class Assignment < ActiveSupport::TestCase

  include Casespace::Models
  include Casespace::Utility

  describe 'delete ownerable data'  do
    let (:ownerable1)  {get_user(:read_1)}
    let (:ownerable2)  {get_user(:read_2)}
    let (:assignment)  {assignment_class.first}

    describe 'assignment' do
      it "one ownerable" do
        assignment.delete_ownerable_data(ownerable1)
        # print_log
      end
      it "two ownerables" do
        assignment.delete_ownerable_data([ownerable1,ownerable2])
        # print_log
      end
    end

  end

  describe 'delete all ownerable data'  do
    let (:ownerable1)  {get_user(:read_1)}
    let (:ownerable2)  {get_user(:read_2)}
    let (:assignment)  {assignment_class.first}

    describe 'assignment' do
      it "all" do
        assignment.delete_all_ownerable_data!
        # print_log
      end
    end

  end

end; end; end
