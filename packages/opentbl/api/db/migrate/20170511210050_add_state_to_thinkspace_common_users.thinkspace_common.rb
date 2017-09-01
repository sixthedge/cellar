# This migration comes from thinkspace_common (originally 20150929231609)
class AddStateToThinkspaceCommonUsers < ActiveRecord::Migration

  def up
    change_table :thinkspace_common_users, force: true do |t|
      t.string   :state
      t.string   :activation_token
      t.datetime :activated_at
      t.datetime :activation_expires_at
    end

    Thinkspace::Common::User.reset_column_information
    Thinkspace::Common::User.update_all(state: 'active')
    Thinkspace::Common::User.all.each { |user| user.activated_at = user.created_at; user.save }
  end
end
