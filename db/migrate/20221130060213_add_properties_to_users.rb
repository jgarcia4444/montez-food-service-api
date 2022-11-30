class AddPropertiesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :first_name, :string, default: ""
    add_column :users, :last_name, :string, default: ""
    add_column :users, :phone_number, :string, default: ""
    add_column :users, :address_id, :integer, default: nil
  end
end
