class CreateTempCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :temp_carts do |t|
      t.integer :user_id
      t.float :total_price

      t.timestamps
    end
  end
end
