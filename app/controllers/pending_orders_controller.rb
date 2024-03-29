
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

    def update_order
        if params[:admin_info]
            admin_info = params[:admin_info]
            if admin_info[:username]
                username = admin_info[:username]
                admin = Admin.find_by(username: username)
                if admin
                    if params[:user_order_id]
                        user_order_id = params[:user_order_id].to_i
                        user_order = UserOrder.find_by(id: user_order_id)
                        if user_order
                            if params[:order_item_info]
                                order_item_info = params[:order_item_info]
                                if order_item_info[:order_item_id]
                                    order_item_id = order_item_info[:order_item_id].to_i
                                    order_item = OrderItem.find_by(id: order_item_id)
                                    if order_item
                                        if order_item_info[:quantity]
                                            quantity = order_item_info[:quantity].to_i
                                            if order_item_info[:price]
                                                price = order_item_info[:price].to_f
                                                if order_item_info[:case_cost]
                                                    case_cost = order_item_info[:case_cost].to_f
                                                    case_bought = params[:case_bought]
                                                    ordered_item = OrderedItem.find_by(user_order_id: user_order_id, order_item_id: order_item_id)
                                                    if ordered_item
                                                        if ordered_item.quantity != quantity
                                                            ordered_item.update(quanity: quantity)
                                                            if ordered_item.valid? == false
                                                                render :json => {
                                                                    success: false,
                                                                    error: {
                                                                        message: "Something went wrong while trying to update the quantity."
                                                                    }
                                                                }
                                                            end
                                                        end
                                                    else
                                                        render :json => {
                                                            sucess: false,
                                                            error: {
                                                                message: "The record was unavailable to update the quantity."
                                                            }
                                                        }
                                                    end
                                                    order_item.update(price: price, case_cost: case_cost)
                                                    if order_item.valid?
                                                        total_price_updated = user_order.update_total_price
                                                        if total_price_updated
                                                            render :json => {
                                                                success: true,
                                                                totalPrice: user_order.total_price,
                                                                orderItemInfo: {
                                                                    quantity: ordered_item.quantity,
                                                                    itemInfo: {
                                                                        description: order_item.description,
                                                                        upc: order_item.upc,
                                                                        price: order_item.price,
                                                                        caseBought: ordered_item.case_bought,
                                                                        caseCost: order_item.case_cost,
                                                                        unitsPerCase: order_item.units_per_case,
                                                                        id: order_item.id,
                                                                    }
                                                                }
                                                            }
                                                        else
                                                            render :json => {
                                                                success: false,
                                                                error: {
                                                                    message: "There was an error updating the total price of the user order."
                                                                }
                                                            }
                                                        end
                                                    else
                                                        render :json => {
                                                            success: {
                                                                message: "Pricing information was unable to be saved to update the item."
                                                            }
                                                        }
                                                    end
                                                else
                                                    render :json => {
                                                        success: false,
                                                        error: {
                                                            message: "The case cost was not sent with the request."
                                                        }
                                                    }
                                                end
                                            else
                                                render :json => {
                                                    success: false,
                                                    error: {
                                                        message: "The price was not sent along with the request."
                                                    }
                                                }
                                            end
                                        else
                                            render :json => {
                                                success: false,
                                                error: {
                                                    message: "The quantity for the order item was not sent with the request."
                                                }
                                            }
                                        end
                                    else
                                        render :json => {
                                            success: false,
                                            error: {
                                                message: "An order item was not found with the given id."
                                            }
                                        }
                                    end
                                else
                                    render :json => {
                                        success: false,
                                        error: {
                                            message: "The order item id was not sent along with the request."
                                        }
                                    }
                                end

                            else
                                render :json => {
                                    success: false,
                                    error: {
                                        message: "Order item info was not sent to update the order item."
                                    }
                                }
                            end
                        else
                            render :json => {
                                success: false,
                                error: {
                                    message: "A user order was not found with the given id."
                                }
                            }
                        end
                    else
                        render :json => {
                            success: false,
                            error: {
                                message: "The user order id was not sent with the request"
                            }
                        }
                    end
                else
                    render :json => {
                        success: false,
                        error: {
                            message: "The admin was not found with the given information."
                        }
                    }
                end
            else
                render :json => {
                    success: false,
                    error: {
                        message: "The correct admin information was not sent with the request"
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "Admin info was not sent with the request."
                }
            }
        end
    end

end