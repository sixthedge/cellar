class CreateThinkspaceCommonPasswordResets < ActiveRecord::Migration
  def change

    create_table :thinkspace_common_password_resets, force: true do |t|
      t.string :token
      t.string :email
      t.timestamps
    end

  end
end