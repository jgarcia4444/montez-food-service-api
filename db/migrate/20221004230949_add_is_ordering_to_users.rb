class AddIsOrderingToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :is_ordering, :boolean, default: false
  end
end
