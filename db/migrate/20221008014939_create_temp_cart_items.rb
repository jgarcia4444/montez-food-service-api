class CreateTempCartItems < ActiveRecord::Migration[7.0]
  def change
    create_table :temp_cart_items do |t|
      t.integer :temp_cart_id
      t.integer :order_item_id
      t.integer :quantity

      t.timestamps
    end
  end
end
