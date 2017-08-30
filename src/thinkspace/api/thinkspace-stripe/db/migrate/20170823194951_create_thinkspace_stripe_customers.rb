class CreateThinkspaceStripeCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :thinkspace_stripe_customers, force: true do |t|
      t.references :ownerable, polymorphic: true, index: {name: 'index_thinkspace_stripe_customers_on_ownerable'}
      t.string     :customer_id
      t.string     :status
      t.datetime   :current_period_start
      t.datetime   :current_period_end

      t.timestamps
    end

    add_index :thinkspace_stripe_customers, [:ownerable_id, :ownerable_type], unique: true, name: 'ownerable_polymorphic_uniqueness'
  end
end
