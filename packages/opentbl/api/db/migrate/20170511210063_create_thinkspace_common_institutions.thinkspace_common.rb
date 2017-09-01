# This migration comes from thinkspace_common (originally 20170504000000)
class CreateThinkspaceCommonInstitutions < ActiveRecord::Migration[5.0]
  def change

    create_table :thinkspace_common_institutions, force: true do |t|
      t.string :title
      t.string :description
      t.string :state
      t.json   :info
      t.timestamps
      t.index :title, name: :idx_thinkspace_common_institutions_on_title
      t.index :state, name: :idx_thinkspace_common_institutions_on_state
    end

    create_table :thinkspace_common_institution_users, force: true do |t|
      t.references :user
      t.references :institution
      t.string     :role
      t.string     :state
      t.timestamps
      t.index :state, name: :idx_thinkspace_common_institution_users_on_state
    end

    add_column :thinkspace_common_spaces, :institution_id, :integer
    add_index  :thinkspace_common_spaces, :institution_id

  end
end
