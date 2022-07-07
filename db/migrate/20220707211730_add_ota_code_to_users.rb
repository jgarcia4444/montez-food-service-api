class AddOtaCodeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :ota_code, :string
  end
end
