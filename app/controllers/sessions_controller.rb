class SessionsController < ApplicationController
    def login
        if params[:user_info]
            user_info = params[:user_info]
            if user_info[:email]
                email = user_info[:email]
                user = User.find_by(email: email)
                if user
                    if user_info[:password]
                        password = user_info[:password]
                        authenticated_user = user.authenticate(password)
                        if authenticated_user
                            if authenticated_user.verified == true
                                users_past_orders = authenticated_user.past_orders
                                user_past_orders = users_past_orders.count > 0 ? users_past_orders : []
                                user_locations = authenticated_user.get_user_locations
                                render :json => {
                                    success: true,
                                    userInfo: {
                                        email: authenticated_user.email,
                                        companyName: authenticated_user.company_name,
                                        pastOrders: user_past_orders,
                                    }
                                }
                            else
                                render :json => {
                                    success: false,
                                    error: {
                                        message: "Account must be verified to be able to login."
                                    }
                                }
                            end
                        else
                            render :json => {
                                success: false,
                                error: {
                                    errorLabel: "password",
                                    message: "Incorrect Password"
                                }
                            }
                        end
                    else
                        render :json => {
                            success: false,
                            error: {
                                message: "Password is required to login"
                            }
                        }
                    end
                else 
                    render :json => {
                        success: false,
                        error: {
                            errorLabel: "email",
                            message: "User not found with the given email."
                        }
                    }
                end
            else
                render :json => {
                    success: false,
                    error: {
                        message: "Email is required to login."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "Login information was sent improperly."
                }
            }
        end
    end

    def root
        render :json => {
            message: "Welcome to the root route of the sessions controller."
        }
    end

end