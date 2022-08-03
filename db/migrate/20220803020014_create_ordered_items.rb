class CreateOrderedItems < ActiveRecord::Migration[7.0]
  def change
    create_table :ordered_items do |t|
      t.integer :user_order_id
      t.integer :quantity
      t.integer :order_item_id

      t.timestamps
    end
  end
end
