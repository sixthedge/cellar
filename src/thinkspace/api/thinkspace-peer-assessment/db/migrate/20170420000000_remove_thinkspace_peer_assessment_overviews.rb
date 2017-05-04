class RemoveThinkspacePeerAssessmentOverviews < ActiveRecord::Migration
  def change
    drop_table :thinkspace_peer_assessment_overviews, force: true
  end
end
