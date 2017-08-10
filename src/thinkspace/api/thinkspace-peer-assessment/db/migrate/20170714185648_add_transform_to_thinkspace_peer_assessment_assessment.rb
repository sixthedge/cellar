class AddTransformToThinkspacePeerAssessmentAssessment < ActiveRecord::Migration[5.0]
  def change
    change_table :thinkspace_peer_assessment_assessments do |t|
      t.json :transform
    end
  end
end
