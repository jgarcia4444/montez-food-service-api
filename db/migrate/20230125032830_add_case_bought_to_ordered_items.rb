class AddCaseBoughtToOrderedItems < ActiveRecord::Migration[7.0]
  def change
    add_column :ordered_items :case_bought, :boolean, default: false
  end
end
