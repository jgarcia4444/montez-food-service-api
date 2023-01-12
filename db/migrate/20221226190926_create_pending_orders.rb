class CreatePendingOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :pending_orders do |t|
      t.integer :user_order_id

      t.timestamps
    end
  end
end
