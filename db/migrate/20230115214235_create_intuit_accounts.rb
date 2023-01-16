class CreateIntuitAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :intuit_accounts do |t|
      t.text :oauth2_access_token
      t.timestamp :oauth2_access_token_expires_at
      t.text :oauth2_refresh_token
      t.timestamp :oauth2_refresh_token_expires_at
      t.boolean :track_purchase_order_quantity

      t.timestamps
    end
  end
end
