
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
        puts "Params from pending order show -------"
        puts params
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
                            items: user_order.get_order_items,
                            orderId: user_order.id
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

    def confirm_pending_order 
        if params[:confirmation_information]
            confirmation_information = params[:confirmation_information]
            if confirmation_information[:delivery_date]
                delivery_date = confirmation_information[:delivery_date]
                if confirmation_information[:invoice_payable_date]
                    invoice_payable_date = confirmation_information[:invoice_payable_date]
                    if confirmation_information[:order_id]
                        order_id = confirmation_information[:order_id]
                        pending_order = PendingOrder.find_by(user_order_id: order_id)
                        if pending_order
                            if pending_order.destroy
                                user_order = UserOrder.find_by(id: order_id)
                                if user_order
                                    order_address = Address.find_by(id: user_order.address_id)
                                    if order_address
                                        formatted_address = order_address.format_address
                                        user_order_items = user_order.get_order_items
                                        user = User.find_by(id: user_order.user_id)
                                        if user
                                            begin
                                                order_info = {
                                                    delivery_date: delivery_date,
                                                    invoice_payable_date: invoice_payable_date,
                                                    total_price: user_order.total_price,
                                                    address: formatted_address,
                                                    items: user_order_items,
                                                    email: user.email,
                                                }
                                                UserNotifierMailer.pending_order_confirmation(order_info).deliver_now
                                                render :json => {
                                                    success: true,
                                                    orderId: user_order.id,
                                                }
                                            rescue StandardError => e
                                                render :json => {
                                                    success: false,
                                                    error: {
                                                        message: "There was an error sending the confirmation email.",
                                                        specificError: e.inspect
                                                    }
                                                }
                                            end
                                        else 
                                            render :json => {
                                                success: false,
                                                error: {
                                                    message: "There was an error finding the user to send the confirmation email to."
                                                }
                                            }
                                        end
                                    else
                                        render :json => {
                                            success: false,
                                            error: {
                                                message: "There was an error finding the associated address with the user order."
                                            }
                                        }
                                    end
                                else
                                    render :json => {
                                        success: false,
                                        error: {
                                            message: "There was an error finding the user order with the given id."
                                        }
                                    }
                                end
                                
                            else
                                render :json => {
                                    success: false,
                                    error: {
                                        message: "There was an error attempting to delete the pending order."
                                    }
                                }
                            end
                        else
                            render :json => {
                                success: false,
                                error: {
                                    message: "There was an error finding the pending order with the given information."
                                }
                            }
                        end
                    else
                        render :json => {
                            success: false,
                            error: {
                                message: "No order id was sent to confirm the pending order."
                            }
                        }
                    end
                else
                    render :json => {
                        success: false,
                        error: {
                            message: "No invoice payable date was sent to confirm the pending order."
                        }
                    }
                end
            else
                render :json => {
                    success: false,
                    error: {
                        message: "No delivery date information was sent to confirm the pending order."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "Information was not sent properly to confirm a pending order."
                }
            }
        end
    end

    def pass_credentials
        client_id = "ABZevbO4SLMjWTElFSGojv0oXFDEQsedj3bnWShuK6PQqpJjDU"
        client_secret = "g8GDQ5BruCDEQmzRraWAmi3zpzxGTSdyX74gbJM9"

        if params[:admin_username]
            username = params[:admin_username]
            admin = Admin.find_by(username: username)
            if admin
                render :json => {
                    success: true,
                    clientDetails: {
                        clientID: client_id,
                        clientSecret: client_secret
                    }
                }
            else
                render :json => {
                    success: false,
                    error: {
                        message: "Incorrect credentials for the admin."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "An admin username must be present with this request."
                }
            }
        end

    end

    def send_tokens
        puts 'PARAMS--------'
        puts params
    end

    def get_tokens
        if params[:token_information]
            token_info = params[:token_information]
            puts token_information
            if token_info[:authorization_code]
                authorization_code = token_info[:authorization_code]
                redirect_uri = "https://montez-food-service-api.herokuapp.com/oauth2/tokens"
                token_uri = "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
                uri = "#{token_uri}?grant_type=authorization_code&code=#{authorization_code}&redirect_uri=#{redirect_uri}"
                response = RestClient.get(uri)
                puts "RESPONSE-----------"
                puts response
                if response.code == 200
                    render :json => {
                        success: true,
                    }
                else
                    render :json => {
                        success: false,
                        error: {
                            message: "There was an error getting the response from the quickbooks server."
                        }
                    }
                end
            else
                render: json => {
                    success: false,
                    error: {
                        message: "The authorization code is needed to gather tokens."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "Not enough data sent to gather tokens."
                }
            }
        end
    end

    # def authenticate
    #     redirect_uri = quickbooks_oauth_callback_url
    #     grant_url = oauth_client.auth_code.authorize_url(redirect_uri: redirect_uri, response_type: "code", state: SecureRandom.hex(12), scope: "com.intuit.quickbooks.accounting")
    #     redirect_to grant_url
    # end

    # def oauth_callback
    #     if params[:state].present?
    #       # use the state value to retrieve from your backend any information you need to identify the customer in your system
    #       redirect_uri = quickbooks_oauth_callback_url
    #       if resp = oauth2_client.auth_code.get_token(params[:code], redirect_uri: redirect_uri)
    #         # save your tokens here. For example:
    #         # quickbooks_credentials.update_attributes(access_token: resp.token, refresh_token: resp.refresh_token, realm_id: params[:realmId])
    #       end
    #     end
    #   end

end