class CreateUserOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :user_orders do |t|
      t.float :total_price
      t.integer :user_id
      t.timestamps
    end
  end
end
