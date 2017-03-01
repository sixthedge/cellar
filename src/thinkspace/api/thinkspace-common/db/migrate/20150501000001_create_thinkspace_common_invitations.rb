class CreateThinkspaceCommonInvitations < ActiveRecord::Migration
  def change

    create_table :thinkspace_common_invitations, force: true do |t|
      t.references  :invitable, polymorphic: true
      t.references  :user
      t.references  :sender
      t.string      :role
      t.string      :token
      t.string      :email
      t.string      :state
      t.datetime    :expires_at
      t.datetime    :accepted_at
      t.datetime    :sent_at
      t.timestamps
    end

  end
end
