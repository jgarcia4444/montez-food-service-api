class RemoveAndAddColumnToOrderItems < ActiveRecord::Migration[7.0]
  def change
    remove_column :order_items, :cost_per_unit
    add_column :order_items, :units_per_case, :integer, default: 0
  end
end
