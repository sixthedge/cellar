# This migration comes from thinkspace_peer_assessment (originally 20170420000000)
class RemoveThinkspacePeerAssessmentOverviews < ActiveRecord::Migration
  def change
    drop_table :thinkspace_peer_assessment_overviews, force: true
  end
end
