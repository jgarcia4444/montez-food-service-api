class UsersController < ApplicationController

    def create
        if params[:user_info]
            new_user = User.create(user_params)
            if new_user.valid?
                # if the new user is created properly then they should be sent a verification email.
                
                render :json => {
                    success: true,
                    userInfo: {
                        email: new_user.email,
                        companyName: new_user.company_name
                    }
                }
            else
                render :json => {
                    success: false,
                    error: {
                        message: "There was an error creating a new user with the information sent.",
                        errors: new_user.errors
                    }
                }
            end
        else
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
                    if user_to_send_code.valid?
                        begin
                            UserNotifierMailer.send_code(user_to_send_code).deliver_now
                            render :json => {
                                success: true,
                                userInfo: {
                                    email: user_to_send_code.email
                                }
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

    def check_code
        if params[:user_info]
            user_info = params[:user_info]
            if user_info[:email]
                email = user_info[:email]
                check_code_user = User.find_by(email: email)
                if check_code_user
                    if user_info[:ota_code]
                        ota_code = user_info[:ota_code]
                        if check_code_user.ota_code == ota_code
                            render :json => {
                                success: true,
                                userInfo: {
                                    email: check_code_user.email,
                                    otaCode: check_code_user.ota_code,
                                },
                            }
                        else
                            render :json => {
                                success: false,
                                error: {
                                    message: "Incorrect code."
                                }
                            }
                        end
                    else 
                        render :json => {
                            success: false,
                            error: {
                                message: "The code sent to the users email was not present when checking for the correct code."
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
                        message: "The users email was not sent with the data to check the code."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "User information was sent improperly"
                }
            }
        end
    end

    def change_password
        if params[:user_info]
            user_info = params[:user_info]
            if user_info[:ota_code]
                ota_code = user_info[:ota_code]
                if user_info[:email]
                    email = user_info[:email]
                    user_changing_password = User.find_by(email: email)
                    if user_changing_password
                        if user_changing_password.ota_code == ota_code
                            if user_info[:new_password]
                                new_password = user_info[:new_password]
                                user_changing_password.update(password: new_password)
                                if user_changing_password.valid?
                                    render :json => {
                                        success: true,
                                        userInfo: {
                                            email: user_changing_password.email,
                                            companyName: user_changing_password.company_name
                                        }
                                    }
                                else
                                    render :json => {
                                        success: false,
                                        error: {
                                            message: "There was an error saving the new password."
                                        }
                                    }
                                end
                            else
                                render :json => {
                                    success: false,
                                    error: {
                                        message: "A new password must be sent with the information sent to the backend."
                                    }
                                }
                            end
                        else
                            render :json => {
                                success: false,
                                error: {
                                    message: "Ota code does not match the most recent code persisted."
                                }
                            }
                        end
                    else
                        render :json => {
                            success: false,
                            error: {
                                message: "A user was not found with the email sent."
                            }
                        }
                    end
                else
                    render :json => {
                        success: false,
                        error: {
                            message: "Associated email must be sent to change the users password."
                        }
                    }
                end
            else
                render :json => {
                    success: false,
                    errro: {
                        message: "The users ota code was not sent with information."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "User information was sent improperly."
                }
            }
        end
    end

    def user_params
        params.require(:user_info).permit(:email, :password, :company_name)
    end

end