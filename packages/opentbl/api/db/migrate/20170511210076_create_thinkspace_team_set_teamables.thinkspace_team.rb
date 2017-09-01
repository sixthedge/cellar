# This migration comes from thinkspace_team (originally 20150901000001)
class CreateThinkspaceTeamSetTeamables < ActiveRecord::Migration
  def change


    create_table :thinkspace_team_team_set_teamables, force: true do |t|
      t.references  :team_set
      t.references  :teamable, polymorphic: true
      t.timestamps
      t.index  [:team_set_id],                  name: :idx_thinkspace_team_team_set_teamables_on_team_set
      t.index  [:teamable_id, :teamable_type],  name: :idx_thinkspace_team_team_set_teamables_on_teamable
    end


  end
end
