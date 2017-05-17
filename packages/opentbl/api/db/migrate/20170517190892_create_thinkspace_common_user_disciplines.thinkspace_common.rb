# This migration comes from thinkspace_common (originally 20161031000003)
class CreateThinkspaceCommonUserDisciplines < ActiveRecord::Migration
  def change
    create_table :thinkspace_common_user_disciplines, force: true do |t|
      t.references :user, polymorphic: true
      t.references :discipline, polymorphic: true
      t.timestamps
    end
  end
end