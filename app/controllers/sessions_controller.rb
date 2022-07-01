class SessionsController < ApplicationController
    def login
        if params[:user_info]
            user_info = params[:user_info]
            if user_info[:email]
                email = user_info[:email]
                user = User.find_by(email: email)
                if user
                    if user_info[:password]
                        password = params[:password]
                        authenticated_user = user.authenticate(password)
                        if authenticated_user
                            render :json => {
                                success: true,
                                userInfo: {
                                    email: authenticated_user.email,
                                    companyName: authenticated_user.company_name
                                }
                            }
                        else
                            render :json => {
                                success: false,
                                error: {
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
    def logout
    end

    def root
        render :json => {
            message: "Welcome to the root route of the sessions controller."
        }
    end

end