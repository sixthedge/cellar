class AddStateToThinkspaceTeamTeamSets < ActiveRecord::Migration
  def change
    add_column :thinkspace_team_team_sets, :state, :string
  end
end
