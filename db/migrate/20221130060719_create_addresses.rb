class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :number, default: ""
      t.string :street_name, default: ""
      t.string :city, default: ""
      t.string :state, default: ""
      t.string :zip_code, default: ""
      t.integer :user_id, default: nil

      t.timestamps
    end
  end
end
