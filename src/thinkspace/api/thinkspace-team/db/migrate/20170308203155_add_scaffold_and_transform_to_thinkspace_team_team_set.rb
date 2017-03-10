class AddScaffoldAndTransformToThinkspaceTeamTeamSet < ActiveRecord::Migration[5.0]
  def change
    add_column :thinkspace_team_team_sets, :scaffold,  :jsonb, default: {}
    add_column :thinkspace_team_team_sets, :transform, :jsonb, default: {}
  end
end
