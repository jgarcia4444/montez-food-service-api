class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.string :upc
      t.string :item
      t.string :description
      t.integer :dept
      t.float :price
      t.float :cost_per_unit
      t.float :case_cost
      t.float :five_case_cost

      t.timestamps
    end
  end
end
