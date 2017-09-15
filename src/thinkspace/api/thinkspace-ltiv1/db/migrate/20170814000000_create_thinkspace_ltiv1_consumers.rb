class CreateThinkspaceLtiv1Consumers < ActiveRecord::Migration
  def change

    create_table :thinkspace_ltiv1_consumers, force: true do |t|
      t.string     :title
      t.string     :consumer_key
      t.string     :encrypted_consumer_secret
      t.string     :encrypted_consumer_secret_iv
      t.references :consumerable, polymorphic: true
      t.timestamps
    end

  end
end
