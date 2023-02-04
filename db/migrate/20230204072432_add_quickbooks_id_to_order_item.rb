class AddQuickbooksIdToOrderItem < ActiveRecord::Migration[7.0]
  def change
    add_column :order_items, :quickbooks_id, :string, default: ""
  end
end
