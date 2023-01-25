class OrderItemsController < ApplicationController

    def fetch_suggestions
        if params[:item_query]
            item_query = params[:item_query]
            suggestions = []
            if params[:email]
                puts "Email found!"
                user_email = params[:email]
                user = User.find_by(email: "#{user_email}.com")
                if user != nil
                    puts "USER FOUND!"
                    user_orders = user.user_orders
                    puts "USER ORDERS"
                    puts user_orders
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
                        puts "Previously ordered items in suggesstions"
                        puts suggestions
                    end
                else
                    puts "USER NOT FOUND"
                    render :json => {
                        success: false,
                        error: {
                            message: "No user found with the given id."
                        }
                    }
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
            puts "Suggestions after going theough items not previously ordered."
            puts suggestions
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