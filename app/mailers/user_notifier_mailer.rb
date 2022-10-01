class UserNotifierMailer < ApplicationMailer
    
    default from: "montez.food.service.auth@gmail.com"

    def send_code(user)
        @user = user
        mail to: @user.email, subject: "Reset Password Code"
    end

    def send_order_confirmation(order_info, user_email)
        @order_info = order_info
        mail to: user_email, subject: "Order Confirmation"
    end

    def send_account_verification(user_info)
        @email = user_info.email
        @user_id = user_info.id
        mail to: @email, subject: "Account Verification"
    end

end
