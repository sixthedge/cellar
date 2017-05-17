# This migration comes from thinkspace_team (originally 20150501000000)
class CreateThinkspaceTeam < ActiveRecord::Migration
  def change

    create_table :thinkspace_team_team_categories, force: true do |t|
      t.string      :title
      t.string      :category
      t.timestamps
      t.index  [:category],                      name: :idx_thinkspace_team_team_categories_on_category
    end

    create_table :thinkspace_team_team_teamables, force: true do |t|
      t.references  :team
      t.references  :teamable, polymorphic: true
      t.timestamps
      t.index  [:team_id],                      name: :idx_thinkspace_team_team_teamables_on_team
      t.index  [:teamable_id, :teamable_type],  name: :idx_thinkspace_team_team_teamables_on_teamable
    end

    create_table :thinkspace_team_team_users, force: true do |t|
      t.references  :user
      t.references  :team
      t.timestamps
      t.index  [:user_id, :team_id],            name: :idx_thinkspace_team_team_users_on_user_team
    end

    create_table :thinkspace_team_team_viewers, force: true do |t|
      t.references  :team
      t.references  :viewerable, polymorphic: true
      t.timestamps
      t.index  [:team_id],                          name: :idx_thinkspace_team_team_viewers_on_team
      t.index  [:viewerable_id, :viewerable_type],  name: :idx_thinkspace_team_team_viewers_on_viewerable
    end

    create_table :thinkspace_team_teams, force: true do |t|
      t.string      :title
      t.text        :description
      t.string      :color
      t.string      :state
      t.references  :authable, polymorphic: true
      t.references  :team_set
      t.timestamps
      t.index  [:authable_id, :authable_type],  name: :idx_thinkspace_team_teams_on_authable
    end

    create_table :thinkspace_team_team_sets, force: true do |t|
      t.string     :title
      t.text       :description
      t.references :space
      t.references :user
      t.boolean    :default
      t.json       :settings
      t.timestamps
      t.index [:space_id], name: :idx_thinkspace_team_team_sets_on_space
    end

  end
end
