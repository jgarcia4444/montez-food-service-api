class OrderItem < ApplicationRecord

    def self.update_items_bulk(items)
        items.each do |item|
            order_item = OrderItem.find_by(description: item[:description])
            if order_item
                order_item.update(price: item[:price].to_f, case_cost: item[:case_cost].to_f, units_per_case: item[:units_per_case].to_i)
                if order_item.valid == false
                    render :json => {
                        success: false,
                        error: {
                            message: "An error occurred while attempting to update an order item. More details in the errors property.",
                            errors: order_item.errors.full_messages,
                        }
                    }
                end
            else
                return {
                    message: "A corresponding order item was not found with the name #{item[:description]}"
                }
            end
        end
        true
    end

end
