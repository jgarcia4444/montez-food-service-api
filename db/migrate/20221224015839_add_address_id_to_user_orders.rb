class AddAddressIdToUserOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :user_orders, :address_id, :integer, default: ""
  end
end
