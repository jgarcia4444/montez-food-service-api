
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
                        formatted_order_date = user_order.format_date
                        address_record = Address.find_by(id: user_order.address_id)
                        if address_record
                            user = User.find_by(id: user_order.user_id)
                            if user
                                user_order_info = {
                                    order_date: formatted_order_date,
                                    date_cancelled: DateTime.now.to_fs(:long),
                                    total_price: user_order.total_price,
                                    address: address_record.format_address,
                                    items: user_order.get_order_items,
                                    reason_text: reason_text,
                                    email: user.email
                                }
                                if user_order.destroy
                                    begin
                                       UserNotifierMailer.cancel_order_send(user_order_info).deliver_now
                                       render :json => {
                                            success: true,
                                            orderId: order_id,
                                       }
                                    rescue StandardError => e
                                       render :json => {
                                            success: false,
                                            error: {
                                                message: "There was an error sending the cancellation email.",
                                                specificError: e.inspect
                                            }
                                        }
                                    end
                                else
                                    render :json => {
                                        success: false,
                                        error: {
                                            message: "There was an error deleting the user order."
                                        }
                                    }
                                end
                            else
                                render :json => {
                                    success: false,
                                    error: {
                                        message: "No user record was found for this user order."
                                    }
                                }
                            end
                        else
                            render :json => {
                                success: false,
                                error: {
                                    message: "No address record was found for this user order."
                                }
                            }
                        end 
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