class CreateThinkspaceLtiv1Contexts < ActiveRecord::Migration
  def change

    create_table :thinkspace_ltiv1_contexts, force: true do |t|
      t.string     :email
      t.string     :key
      t.string     :value
      t.references :ownerable, polymorphic: true
      t.references :contextable, polymorphic: true
      t.timestamps
    end

  end
end
