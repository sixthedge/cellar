class CreateThinkspacePeerAssessment < ActiveRecord::Migration
  def change

    create_table :thinkspace_peer_assessment_assessments, force: true do |t|
      t.references  :authable, polymorphic: true
      t.string      :state
      t.json        :value
      t.timestamps
    end

    create_table :thinkspace_peer_assessment_reviews, force: true do |t|
      t.string :state
      t.json :value
      t.references :reviewable, polymorphic: true
      t.references :review_set
      t.timestamps
    end

    create_table :thinkspace_peer_assessment_review_sets, force: true do |t|
      t.references :ownerable, polymorphic: true
      t.references :team_set
      t.string :state
      t.timestamps
    end

    create_table :thinkspace_peer_assessment_team_sets, force: true do |t|
      t.references :assessment
      t.references :team
      t.string :state
      t.timestamps
    end

    create_table :thinkspace_peer_assessment_overviews, force: true do |t|
      t.references  :authable, polymorphic: true
      t.references  :assessment
      t.timestamps
    end

  end
end
