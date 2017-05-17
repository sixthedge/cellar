# This migration comes from thinkspace_common (originally 20161031000002)
class CreateThinkspaceCommonDisciplines < ActiveRecord::Migration
  def change
    create_table :thinkspace_common_disciplines, force: true do |t|
      t.string     :title
      t.timestamps
    end
  end
end