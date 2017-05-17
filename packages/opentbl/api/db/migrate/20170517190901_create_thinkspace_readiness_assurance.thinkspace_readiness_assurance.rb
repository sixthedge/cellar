# This migration comes from thinkspace_readiness_assurance (originally 20160601000000)
class CreateThinkspaceReadinessAssurance < ActiveRecord::Migration
  def change

    create_table :thinkspace_readiness_assurance_assessments, force: true do |t|
      t.references  :authable, polymorphic: true
      t.references  :user
      t.string      :title
      t.string      :state
      t.json        :settings
      t.json        :questions
      t.json        :answers
      t.timestamps
      t.index  [:state],                       name: :idx_thinkspace_readiness_assurance_assessments_on_state
      t.index  [:authable_id, :authable_type], name: :idx_thinkspace_readiness_assurance_assessments_on_authable
    end

    create_table :thinkspace_readiness_assurance_responses, force: true do |t|
      t.references  :assessment
      t.references  :ownerable, polymorphic: true
      t.references  :user
      t.decimal     :score, precision: 9, scale: 3
      t.json        :settings
      t.json        :answers
      t.json        :justifications
      t.json        :userdata
      t.json        :metadata
      t.timestamps
      t.index  [:assessment_id],                   name: :idx_thinkspace_readiness_assurance_responses_on_assessment
      t.index  [:ownerable_id, :ownerable_type],   name: :idx_thinkspace_readiness_assurance_responses_on_ownerable
    end

    create_table :thinkspace_readiness_assurance_chats, force: true do |t|
      t.references  :response
      t.json        :messages
      t.timestamps
      t.index  [:response_id],    name: :idx_thinkspace_readiness_assurance_chats_on_response
    end

    create_table :thinkspace_readiness_assurance_statuses, force: true do |t|
      t.references  :response
      t.json        :settings
      t.json        :questions
      t.timestamps
      t.index  [:response_id],    name: :idx_thinkspace_readiness_assurance_statuses_on_response
    end

  end
end
