class AddAvatarsToThinkspaceCommonUsers < ActiveRecord::Migration
  def up
    add_attachment :thinkspace_common_users, :avatar
  end
end