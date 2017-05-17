# This migration comes from thinkspace_common (originally 20151215000000)
class AddParentIdToThinkspaceCommonUsers < ActiveRecord::Migration

  def up
    change_table :thinkspace_common_users do |t|
      t.references :parent
      t.index :parent_id, name: :idx_thinkspace_common_users_on_parent_id
    end
  end

  def down
    remove_index :thinkspace_common_users, :idx_thinkspace_common_users_on_parent_id
    change_table :thinkspace_common_users do |t|
      t.remove :parent_id
    end
  end

end
