class AddUserProfileInfoToThinkspaceCommonUsers < ActiveRecord::Migration
  def up
    change_table :thinkspace_common_users do |t|
      t.boolean  :email_optin, default: true
      t.jsonb    :profile, default: {}
      t.datetime :terms_accepted_at
    end

  end
end