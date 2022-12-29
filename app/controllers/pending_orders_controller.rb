
class PendingOrdersController < ApplicationController

    def cancel_order
        if params[:order_info]
            order_info = params[:order_info]
            if order_info[:reason_text]
                reason_text = order_info[:reason_text]
                if order_info[:order_id]
                    order_id = order_info[:order_id]
                    user_order = UserOrder.find_by(id: order_id)
                    if user_order
                        # order_date, date_cancelled, total_price, address, items, reason_text
                        formatted_order_date = user_order.format_date
                        user_order_info = {
                            order_date: formatted_order_date,
                        }
                    else 
                        render :json => {
                            success: false,
                            error: {
                                message: "No current user order matches the id sent."
                            }
                        }
                    end
                else 
                    render :json => {
                        success: false,
                        error: {
                            message: "An order id must be present to cancel the pending order."
                        }
                    }
                end
            else 
                render :json => {
                    success: false,
                    error: {
                        message: "A reason or reasons must be given as to why the order was cancelled."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "Insufficient information was sent to cancel the order."
                }
            }
        end
    end

end