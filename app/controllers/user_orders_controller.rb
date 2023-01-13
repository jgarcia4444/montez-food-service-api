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
                            if params[:address_info]
                                address_info = params[:address_info]
                                address_id = address_info[:address_id]
                                order_info = {
                                    items: items,
                                    address_id: address_id
                                }
                                user_order = user.create_user_order(order_info)
                                orders_persisted = user_order.persist_ordered_items(items)
                                pending_order = PendingOrder.create(user_order_id: user_order.id)
                                if !pending_order
                                    render :json => {
                                        success: false,
                                        error: {
                                            message: "There was an error setting this order as a pending order."
                                        }
                                    }
                                end
                                #
                                if orders_persisted
                                    address = Address.find_by(id: user_order[:address_id])
                                    puts "Address -------"
                                    puts address
                                    order_address = {
                                        id: address.id,
                                        street: address.street,
                                        city: address.city,
                                        state: address.state,
                                        zipCode: address.zip_code,
                                    }
                                    past_order_info = {
                                        totalPrice: user_order.total_price,
                                        items: items,
                                        orderDate: user_order.created_at,
                                        orderAddress: address,
                                    }
                                    puts "Past order info -------"
                                    puts past_order_info
                                    begin 
                                        UserNotifierMailer.send_order_confirmation(past_order_info, user_email).deliver_now
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
                                    end
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
                                        message: "An order must have an address selected."
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