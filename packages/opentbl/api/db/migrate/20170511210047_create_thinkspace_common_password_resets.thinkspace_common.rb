# This migration comes from thinkspace_common (originally 20150501000002)
class CreateThinkspaceCommonPasswordResets < ActiveRecord::Migration
  def change

    create_table :thinkspace_common_password_resets, force: true do |t|
      t.string :token
      t.string :email
      t.timestamps
    end

  end
end