class CreateThinkspaceCommonDisciplines < ActiveRecord::Migration
  def change
    create_table :thinkspace_common_disciplines, force: true do |t|
      t.string     :title
      t.timestamps
    end
  end
end