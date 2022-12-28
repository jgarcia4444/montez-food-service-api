class UserOrder < ApplicationRecord
    has_many :ordered_items
    belongs_to :user
    has_one :address

    def persist_ordered_items(items)
        items.each do |item|
            order_item_id = OrderItem.find_by(description: item["description"]).id
            puts "Order item id: #{order_item_id}"
            ordered_item = OrderedItem.create(order_item_id: order_item_id, quantity: item["quantity"].to_i, user_order_id: self.id)
            if !ordered_item.valid?
                render :json => {
                    success: false,
                    error: {
                        message: "There was an error persisting an order item as and ordered item."
                    }
                }
            end
        end
        true
    end

    def get_order_items
        ordered_items = OrderedItem.all.select{|ordered_item| ordered_item.user_order_id == self.id}
        ordered_items.map do |ordered_item|
            order_item_id = ordered_item.order_item_id
            order_item = OrderItem.find_by(id: order_item_id)
            {
                quantity: ordered_item.quantity,
                itemInfo: {
                    description: order_item.description,
                    upc: order_item.upc,
                    price: order_item.price,
                }
            }
        end
    end

end
