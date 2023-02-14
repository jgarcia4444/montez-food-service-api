class OrderItemsController < ApplicationController

    def fetch_suggestions
        if params[:item_query]
            item_query = params[:item_query]
            suggestions = []
            if params[:email]
                user_email = params[:email]
                user = User.find_by(email: "#{user_email}.com")
                if user != nil
                    user_orders = user.user_orders
                    if user_orders.count > 0
                        previously_ordered_items = []
                        user_orders.each {|user_order| previously_ordered_items = previously_ordered_items + user_order.order_items}
                        previously_ordered_items.each do |order_item|
                            if suggestions.count > 9
                                break
                            else
                                downcased_description = order_item[:description].downcase
                                if downcased_description.include?(item_query.downcase)
                                    suggestions.push(order_item)
                                end
                            end
                        end
                    end
                end
            end
            OrderItem.all.each do |order_item|
                if suggestions.count > 9
                    break
                else
                    downcased_description = order_item.description.downcase
                    if downcased_description.include?(item_query.downcase)
                        suggestions.push(format_order_item(order_item))
                    end
                end
            end
            if suggestions.count > 0
                render :json => {
                    success: true,
                    suggestions: suggestions,
                }
            else
                render :json => {
                    success: false,
                    error: {
                        message: "Unable to find suggestions."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "A search query was not present with the parameters."
                }
            }
        end
    end

    def update_items
        if params[:items]
            items = params[:items]
            if items.count > 0
                order_items_updated = OrderItem.update_items_bulk(items)
                if order_items_updated[:message] == nil
                    items_updated = order_items_updated[:items_updated]
                    render :json => {
                        success: true,
                        itemsUpdated: items_updated,
                    }
                else
                    error_message = order_items_updated[:message]
                    items_updated = order_items_updated[:items_updated]
                    render :json => {
                        success: false,
                        error: {
                            message: error_message,
                        },
                        itemsUpdated: items_updated,
                    }
                end
            else
                render :json => {
                    success: true,
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "No items were sent to be updated."
                }
            }
        end
    end

    

    private
    def format_order_item(order_item)
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