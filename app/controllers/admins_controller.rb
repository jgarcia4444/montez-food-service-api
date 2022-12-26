
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
end