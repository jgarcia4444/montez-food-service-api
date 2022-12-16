class OrderItemsController < ApplicationController

    def fetch_suggestions
        puts "FETCH SUGGESTIONS ACTION TRIGGERED"
        if params[:item_query]
            item_query = params[:item_query]
            suggestions = []
            OrderItem.all.each do |order_item|
                if suggestions.count > 9
                    break
                else
                    downcased_description = order_item.description.downcase
                    if downcased_description.include?(item_query)
                        suggestions.push(format_order_item(order_item))
                    end
                end
            end
            if suggestions.count > 0
                puts suggestions.count
                puts suggestions
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
        end
    end

    

    private
    def format_order_item(order_item)
        {
            description: order_item.description,
            upc: order_item.upc,
            item: order_item.item,
            price: order_item.price,
            costPerUnit: order_item.cost_per_unit,
            caseCost: order_item.case_cost,
            fiveCaseCost: order_item.five_case_cost,
        }
    end

end