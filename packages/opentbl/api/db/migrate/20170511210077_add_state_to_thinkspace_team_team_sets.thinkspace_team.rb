# This migration comes from thinkspace_team (originally 20150918000001)
class AddStateToThinkspaceTeamTeamSets < ActiveRecord::Migration
  def change
    add_column :thinkspace_team_team_sets, :state, :string
  end
end
