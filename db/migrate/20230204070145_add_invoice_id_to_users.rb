class AddInvoiceIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :quickbooks_id, :string, default: ""
  end
end
