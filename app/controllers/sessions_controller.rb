class SessionsController < ApplicationController
    def login
        puts "LOGIN ACTION TRIGGERED"
        if params[:user_info]
            puts "USER INFO FOUND"
            user_info = params[:user_info]
            if user_info[:email]
                puts "EMAIL FOUND IN USER INFO"
                email = user_info[:email]
                user = User.find_by(email: email)
                if user
                    puts "USER FOUND WITH EMAIL"
                    if user_info[:password]
                        password = user_info[:password]
                        authenticated_user = user.authenticate(password)
                        if authenticated_user
                            puts "User authenticated!"
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