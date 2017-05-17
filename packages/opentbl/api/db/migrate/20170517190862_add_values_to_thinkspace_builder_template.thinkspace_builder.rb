# This migration comes from thinkspace_builder (originally 20160530000000)
class AddValuesToThinkspaceBuilderTemplate < ActiveRecord::Migration

  def change
    change_table :thinkspace_builder_templates do |t|
      t.json :value
    end
  end

end
