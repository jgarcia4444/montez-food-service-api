
class AdminsController < ApplicationController
    def login
        if params[:admin] 
            admin = params[:admin]
            if admin[:username] and admin[:password]
                username = admin[:username]
                password = admin[:password]
                found_admin = Admin.find_by(username: username)
                if found_admin
                    if found_admin.authenticate(password)
                        all_pending_orders = PendingOrder.all.count == 0 ? [] : PendingOrder.all
                        render :json => {
                            success: true,
                            username: username,
                            pendingOrderIds: all_pending_orders
                        }
                    else
                        render :json => {
                            success: false,
                            error: {
                                message: "Incorrect Password."
                            }
                        }
                    end
                else
                    render :json => {
                        success: false,
                        error: {
                            message: "No admin was found with the given username"
                        }
                    }
                end
            elsif admin[:username] == "" or !admin[:username]
                render :json => {
                    success: false,
                    error: {
                        message: "Username information must be sent to login the admin."
                    }
                }
            elsif admin[:password] == "" or !admin[:password]
                redner :json => {
                    success: false,
                    error: {
                        message: "A password must be used to login the admin."
                    }
                }
            else
                render :json => {
                    success: false,
                    error: {
                        message: "There was an unexpected error while logging in the admin."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "Information was not sent to log in the admin."
                }
            }
        end
    end

    def pending_orders_index
        pending_orders = PendingOrder.all
        if pending_orders.count > 0
            pending_user_orders = []
            pending_orders.each do |pending_order|
                order_id = pending_order.user_order_id
                user_order = UserOrder.find_by(id: order_id)
                pending_user_orders.append(user_order)
            end
            puts "Pending Orders Found"
            render :json => {
                success: true,
                pendingOrders: pending_user_orders,
            }
        else 
            puts "No Pending Orders"
            render :json => {
                success: true,
                pendingOrders: []
            }
        end
    end

    def pending_order_show
        if params[:order_id]
            order_id = params[:order_id]
            user_order = UserOrder.find_by(id: order_id)
            if user_order
                user_id = user_order.user_id
                user = User.find_by(id: user_id)
                if user
                    order_address_id = user_order.address_id
                    order_address = Address.find_by(id: order_address_id)
                    formattedAddress = {
                        id: order_address.id,
                        street: order_address.street,
                        city: order_address.city,
                        state: order_address.state,
                        zipCode: order_address.zip_code
                    }
                    render :json => {
                        success: true,
                        pendingOrderDetails: {
                            companyName: user.company_name,
                            createdAt: user_order.created_at,
                            deliveryAddress: formattedAddress,
                            totalPrice: user_order.total_price,
                            items: user_order.get_order_items
                        }
                    }
                else 
                    render :json => {
                        success: false,
                        error: {
                            message: "There is no associated user with this pending order."
                        }
                    }
                end
            else
                render :json => {
                    success: false,
                    error: {
                        message: "An associated user order was not found with the information given."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "No order id was sent to find order information."
                }
            }
        end
    end

end