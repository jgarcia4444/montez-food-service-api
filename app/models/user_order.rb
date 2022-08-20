class UserOrder < ApplicationRecord
    has_many :ordered_items
    belongs_to :user

    def persist_ordered_items(items)
        items.each do |item|
            order_item_id = OrderItem.find_by(description: item.description)
            ordered_item = OrderedItem.create(order_item_id: order_item_id, quantity: item.quantity.to_i, user_order_id: self.id)
            if !ordered_item
                render :json => {
                    success: false,
                    error: {
                        message: "There was an error persisting and order item as and ordered item."
                    }
                }
            end
        end
        true
    end

end
