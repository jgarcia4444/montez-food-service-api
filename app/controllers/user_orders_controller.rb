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