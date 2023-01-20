class RemoveColumnFromAddresses < ActiveRecord::Migration[7.0]
  def change
    remove_column :addresses, :formatted_address
    add_column :user_orders, :formatted_address, :string, default: ""
  end
end
