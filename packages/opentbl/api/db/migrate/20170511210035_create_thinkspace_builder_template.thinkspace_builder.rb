# This migration comes from thinkspace_builder (originally 20160501000000)
class CreateThinkspaceBuilderTemplate < ActiveRecord::Migration

  def change
    create_table :thinkspace_builder_templates, force: true do |t|
      t.string     :title
      t.text       :description
      t.references :user
      t.references :templateable, polymorphic: true
      t.boolean    :domain, default: false
      t.timestamps
    end
  end

end
