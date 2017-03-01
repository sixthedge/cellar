class AddSuperuserToThinkspaceCommonUsers < ActiveRecord::Migration

  def up
    change_table :thinkspace_common_users do |t|
      t.boolean :superuser, default: false
    end
    Thinkspace::Common::User.reset_column_information  # user model class loaded via migration to update user states (update the user class)
  end

  def down
    change_table :thinkspace_common_users do |t|
      t.remove :superuser
    end
  end

end
