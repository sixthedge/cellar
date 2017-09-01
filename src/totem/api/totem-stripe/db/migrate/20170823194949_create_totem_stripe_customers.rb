class CreateTotemStripeCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :totem_stripe_customers, force: true do |t|
      t.string    :customer_id
      t.string    :status
      t.timestamp :current_period_start
      t.timestamp :current_period_end

      t.timestamps
    end
  end
end
