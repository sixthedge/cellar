# This migration comes from thinkspace_peer_assessment (originally 20161212000000)
class CreateThinkspacePeerAssessmentTemplates < ActiveRecord::Migration
  def change

    create_table :thinkspace_peer_assessment_assessment_templates, force: true do |t|
      t.references  :ownerable, polymorphic: true
      t.json        :value
      t.string      :title
      t.text        :description
      t.string      :state
      t.timestamps
    end

    change_table :thinkspace_peer_assessment_assessments, force: true do |t|
      t.references :assessment_template
    end

  end
end
