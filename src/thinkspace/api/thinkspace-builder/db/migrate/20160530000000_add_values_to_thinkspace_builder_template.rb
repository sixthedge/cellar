class AddValuesToThinkspaceBuilderTemplate < ActiveRecord::Migration

  def change
    change_table :thinkspace_builder_templates do |t|
      t.json :value
    end
  end

end
