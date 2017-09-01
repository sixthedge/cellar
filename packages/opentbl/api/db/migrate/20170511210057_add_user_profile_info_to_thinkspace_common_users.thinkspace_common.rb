# This migration comes from thinkspace_common (originally 20161031000000)
class AddUserProfileInfoToThinkspaceCommonUsers < ActiveRecord::Migration
  def up
    change_table :thinkspace_common_users do |t|
      t.boolean  :email_optin, default: true
      t.jsonb    :profile, default: {}
      t.datetime :terms_accepted_at
    end

  end
end