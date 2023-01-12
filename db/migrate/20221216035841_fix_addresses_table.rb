class FixAddressesTable < ActiveRecord::Migration[7.0]
  def change
    remove_column :addresses, :street_name
    remove_column :addresses, :number
    add_column :addresses, :street, :string, default: ""
  end
end
