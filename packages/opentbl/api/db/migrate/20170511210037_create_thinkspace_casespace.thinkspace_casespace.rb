# This migration comes from thinkspace_casespace (originally 20150501000000)
class CreateThinkspaceCasespace < ActiveRecord::Migration
  def change

    create_table :thinkspace_casespace_assignments, force: true do |t|
      t.references  :space
      t.string      :title
      t.string      :name
      t.string      :bundle_type
      t.text        :description
      t.text        :instructions
      t.boolean     :active, default: false
      t.datetime    :release_at
      t.datetime    :due_at
      t.timestamps
      t.index  [:space_id], name: :idx_thinkspace_casespace_assignments_on_space
    end

    create_table :thinkspace_casespace_case_manager_templates, force: true do |t|
      t.references  :templateable, polymorphic: true
      t.string      :title
      t.string      :description
      t.timestamps
    end

    create_table :thinkspace_casespace_phase_components, force: true do |t|
      t.references  :component
      t.references  :phase
      t.references  :componentable, polymorphic: true
      t.string      :section
      t.timestamps
      t.index  [:component_id],         name: :idx_thinkspace_casespace_phase_components_on_component
      t.index  [:phase_id],             name: :idx_thinkspace_casespace_phase_components_on_phase
    end

    create_table :thinkspace_casespace_phase_scores, force: true do |t|
      t.references  :user
      t.references  :phase_state
      t.decimal     :score, precision: 9, scale: 3
      t.timestamps
      t.index  [:phase_state_id],                 name: :idx_thinkspace_casespace_phase_scores_on_phase_state
      t.index  [:user_id],                        name: :idx_thinkspace_casespace_phase_scores_on_user
    end

    create_table :thinkspace_casespace_phase_states, force: true do |t|
      t.references  :user
      t.references  :phase
      t.references  :ownerable, polymorphic: true
      t.string      :current_state
      t.datetime    :archived_at
      t.timestamps
      t.index  [:ownerable_id, :ownerable_type],  name: :idx_thinkspace_casespace_phase_states_on_ownerable
      t.index  [:phase_id],                       name: :idx_thinkspace_casespace_phase_states_on_phase
      t.index  [:user_id],                        name: :idx_thinkspace_casespace_phase_states_on_user
      t.index  [:archived_at],                    name: :idx_thinkspace_casespace_phase_states_on_archived
    end

    create_table :thinkspace_casespace_phase_templates, force: true do |t|
      t.string      :title
      t.string      :name
      t.string      :description
      t.boolean     :domain, default: false
      t.text        :template
      t.timestamps
    end

    create_table :thinkspace_casespace_phases, force: true do |t|
      t.references  :assignment
      t.references  :phase_template
      t.references  :team_category
      t.string      :title
      t.text        :description
      t.boolean     :active
      t.integer     :position
      t.string      :default_state
      t.timestamps
      t.index  [:assignment_id],      name: :idx_thinkspace_casespace_phases_on_assignment
      t.index  [:phase_template_id],  name: :idx_thinkspace_casespace_phases_on_phase_template
    end

  end
end
