class CreateThinkspaceLtiv1Consumers < ActiveRecord::Migration
  def change

    create_table :thinkspace_ltiv1_consumers, force: true do |t|
      t.string     :title
      t.string     :consumer_key
      t.string     :consumer_secret
      t.references :consumerable, polymorphic: true
      t.timestamps
    end

  end
end
