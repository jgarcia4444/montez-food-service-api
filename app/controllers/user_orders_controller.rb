class UserOrdersController < ApplicationController

    def persist_order
        if params[:user_info]
            if params[:order_info]
                user_info = params[:user_info]
                order_info = params[:order_info]
                if user_info[:email]
                    if order_info[:items]
                        user_email = user_info[:email]
                        items = order_info[:items]
                        user = User.find_by_email(user_email)
                        if user
                            user_order = user.create_user_order(items)
                            orders_persisted = user_order.persist_ordered_items(items)
                            if orders_persisted
                                # Send Confirmation Email
                                past_order_info = {
                                    totalPrice: user_order.total_price,
                                    items: items,
                                    orderDate: user_order.created_at
                                }
                                begin 
                                    UserNotifierMailer.send_order_confirmation(past_order_info, user_email)
                                    render :json => {
                                        success: true,
                                        pastOrder: past_order_info
                                    }
                                rescue StandardError => e
                                    render :json => {
                                        success: false,
                                        error: {
                                            message: "There was an error sending the order confirmation email",
                                            specificError: e.inspect
                                        }
                                    }
                            else 
                                render :json => {
                                    success: false,
                                    error: {
                                        message: "There was an error while persisting ordered items."
                                    }
                                }
                            end
                        else
                            render :json => {
                                success: false,
                                error: {
                                    message: "A user was not found with the given information."
                                }
                            }
                        end
                    else 
                        render :json => {
                            success: false,
                            error: {
                                message: "Items were not sent to the backend."
                            }
                        }
                    end
                else 
                    render :json => {
                        success: false,
                        error: {
                            message: "The users email must be sent in the user_info parameter."
                        }
                    }
                end
            else
                render :json => {
                    success: false,
                    error: {
                        message: "Order info was not sent to backend."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "User info was not sent along with the order."
                }
            }
        end
    end

end