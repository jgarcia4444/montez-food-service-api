class UserNotifierMailer < ApplicationMailer
    
    default from: "montez.food.service.auth@gmail.com"

    def send_code(user)
        @user = user
        mail to: @user.email, subject: "Reset Password Code"
    end

    def send_order_confirmation(order_info, user_email)
        @order_info = order_info
        @configured_address = "#{@order_info[:address][:street]}, #{@order_info[:address][:city]}, #{@order_info[:address][:state]}, #{@order_info[:address][:zip_code]}"
        mail to: user_email, subject: "Order Received"
    end

    def pending_order_confirmation(order_info)
        @order_info = order_info
        mail to: order_info[:email], subject: "Order Confirmed"
    end

    def send_account_verification(user_info)
        @email = user_info.email
        @verification_url = "http://localhost:3001/users/account/verifying/#{user_info.email}"
        mail to: @email, subject: "Account Verification"
    end

end
