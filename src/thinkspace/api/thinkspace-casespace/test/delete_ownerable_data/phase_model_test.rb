require 'delete_ownerable_data_helper'
module Test; module DeleteOwnerableData; class Phase < ActiveSupport::TestCase

  include Casespace::Models
  include Casespace::Utility

  # 2015-08-06 when changed from delete_all to destroy_all get a lot of warnings (many screens):
  # DEPRECATION WARNING: `serialized_attributes` is deprecated without replacement, and will be removed in Rails 5.0.
  # Assume is a result of some gem (e.g. paper trail?).

  def phase_with_componentable
    components = phase_component_class.where(componentable_type: componentable_class.name)
    raise "Phase component with componentable_type #{componentable_class.name.inspect} not found."  if components.blank?
    components.first.thinkspace_casespace_phase
  end

  def phase_component_class; Thinkspace::Casespace::PhaseComponent; end
  def bucket_class;  Thinkspace::Artifact::Bucket; end
  def content_class; Thinkspace::Html::Content; end
  def list_class;    Thinkspace::ObservationList::List; end

  # # Uncomment to test specific componentables.
  # describe 'delete ownerable data'  do
  #   let (:ownerable1)    {get_user(:read_1)}
  #   let (:ownerable2)    {get_user(:read_2)}
  #   let (:phase)         {phase_with_componentable}
  #   # let (:componentable_class) {bucket_class}
  #   let (:componentable_class) {content_class}
  #   # let (:componentable_class) {list_class}
  #   describe 'phase componentable' do
  #     it "ownerable" do
  #       phase.delete_ownerable_data([ownerable1, ownerable2])
  #       print_log
  #     end
  #     it "all" do
  #       phase.delete_all_ownerable_data!
  #       print_log
  #     end
  #   end
  # end

  describe 'delete ownerable data'  do
    let (:ownerable1)  {get_user(:read_1)}
    let (:ownerable2)  {get_user(:read_2)}
    let (:phase)       {phase_class.first}
    describe 'phase' do
      it "one ownerable" do
        phase.delete_ownerable_data(ownerable1)
        # print_log
      end
      it "two ownerables" do
        phase.delete_ownerable_data([ownerable1,ownerable2])
        # print_log
      end
    end
  end

  describe 'delete all ownerable data'  do
    let (:ownerable1)  {get_user(:read_1)}
    let (:ownerable2)  {get_user(:read_2)}
    let (:phase)       {phase_class.first}
    describe 'phase' do
      it "all" do
        phase.delete_all_ownerable_data!
        # print_log
      end
    end
  end

  phase_class.all.each do |phase|
    describe "phase #{phase.inspect}"  do
      let (:ownerable1)  {get_user(:read_1)}
      let (:ownerable2)  {get_user(:read_2)}
      describe 'delete ownerable' do
        it "one ownerable" do
          phase.delete_ownerable_data(ownerable1)
        end
        it "two ownerables" do
          phase.delete_ownerable_data([ownerable1,ownerable2])
        end
        it "all" do
          phase.delete_all_ownerable_data!
        end
      end
    end
  end

end; end; end
