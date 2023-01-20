class AddFormattedAddressToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :formatted_address, :string, default: ""
  end
end
