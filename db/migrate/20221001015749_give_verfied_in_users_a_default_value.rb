class GiveVerfiedInUsersADefaultValue < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :verified, :boolean, :default => false
  end
end
