class AddTransformToThinkspaceReadinessAssuranceAssessment < ActiveRecord::Migration[5.0]
  def change

    change_table :thinkspace_readiness_assurance_assessments do |t|
      t.json :transform
    end
    
  end
end
