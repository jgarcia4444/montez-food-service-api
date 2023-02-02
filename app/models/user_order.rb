class UserOrder < ApplicationRecord
    has_many :ordered_items
    belongs_to :user
    has_one :address
    has_one :pending_order, dependent: :destroy

    def persist_ordered_items(items)
        items.each do |item|
            order_item_id = OrderItem.find_by(description: item["description"]).id
            ordered_item = OrderedItem.create(order_item_id: order_item_id, quantity: item["quantity"].to_i, user_order_id: self.id, case_bought: item[:caseBought])
            if ordered_item.valid? == false
                render :json => {
                    success: false,
                    error: {
                        message: "There was an error persisting an order item as and ordered item."
                    }
                }
            end
        end
        
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
                    caseBought: ordered_item.case_bought,
                    caseCost: order_item.case_cost,
                    unitsPerCase: order_item.units_per_case
                }
            }
        end
    end

    def order_items
        
        ordered_items = OrderedItem.all.select{|ordered_item| ordered_item.user_order_id == self.id}
        ordered_items.map do |ordered_item|
            order_item_id = ordered_item.order_item_id
            order_item = OrderItem.find_by(id: order_item_id)
            {
                description: order_item.description,
                upc: order_item.upc,
                item: order_item.item,
                price: order_item.price,
                unitsPerCase: order_item.units_per_case,
                caseCost: order_item.case_cost,
                fiveCaseCost: order_item.five_case_cost,
            }
        end
    end

    def format_date
        self.created_at.to_fs(:long)
    end

end
