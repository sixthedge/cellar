require 'delete_ownerable_data_helper'
module Test; module DeleteOwnerableData; class Space < ActiveSupport::TestCase

  include Casespace::Models
  include Casespace::Utility

  describe 'delete ownerable data'  do
    let (:ownerable1)  {get_user(:read_1)}
    let (:ownerable2)  {get_user(:read_2)}
    let (:space)  {space_class.first}

    describe 'space' do
      it "one ownerable" do
        space.delete_ownerable_data(ownerable1)
        # print_log
      end
      it "two ownerables" do
        space.delete_ownerable_data([ownerable1,ownerable2])
        # print_log
      end
    end

  end

  describe 'delete all ownerable data'  do
    let (:ownerable1)  {get_user(:read_1)}
    let (:ownerable2)  {get_user(:read_2)}
    let (:space)  {space_class.first}

    describe 'space' do
      it "all" do
        space.delete_all_ownerable_data!
        # print_log
      end
    end

  end

end; end; end
