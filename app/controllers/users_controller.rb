class UsersController < ApplicationController

    def create
        puts "CREATE ACTION TRIGGERED."
        puts params
        if params[:user_info]
            new_user = User.create(user_params)
            if new_user.valid?
                render :json => {
                    success: true,
                    userInfo: {
                        email: new_user.email,
                        companyName: new_user.company_name
                    }
                }
            else
                puts "INVALID USER!!!"
                render :json => {
                    success: false,
                    error: {
                        message: "There was an error creating a new user with the information sent.",
                        errors: new_user.errors
                    }
                }
            end
        else
            puts "USER INFO SENT INCORRECTLY!!"
            render :json => {
                success: false,
                error: {
                    message: "Information to create a new user was sent improperly."
                }
            }
        end
    end

    def show
    end

    def forgot_password
        if params[:user_info]
            user_info = params[:user_info]
            if user_info[:email]
                email = user_info[:email]
                user_to_send_code = User.find_by(email: email)
                if user_to_send_code
                    user_to_send_code.create_ota_code
                    puts "User Validity! #{user_to_send_code.valid?}"
                    if user_to_send_code.valid?
                        begin
                            UserNotifierMailer.send_code(user_to_send_code)
                            render :json => {
                                success: true,
                            }
                        rescue StandardError => e
                            render :json => {
                                success: false,
                                error: {
                                    message: "There was an error sending the email",
                                    specificError: e.inspect
                                }
                            }
                        end
                    else
                        render :json => {
                            success: false,
                            error: {
                                message: "There was an error creating an authentication code."
                            }
                        }
                    end
                else 
                    render :json => {
                        success: false,
                        error: {
                            message: "No user was found with the given email."
                        }
                    }
                end
            else
                render :json => {
                    success: false,
                    error: {
                        message: "Users email is needed to reset the password."
                    }
                }
            end
        else 
            render :json => {
                success: false,
                error: {
                    message: "User information was not sent properly."
                }
            }
        end
    end

    def user_params
        params.require(:user_info).permit(:email, :password, :company_name)
    end

end