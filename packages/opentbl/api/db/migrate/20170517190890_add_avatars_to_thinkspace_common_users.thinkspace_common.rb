# This migration comes from thinkspace_common (originally 20161031000001)
class AddAvatarsToThinkspaceCommonUsers < ActiveRecord::Migration
  def up
    add_attachment :thinkspace_common_users, :avatar
  end
end