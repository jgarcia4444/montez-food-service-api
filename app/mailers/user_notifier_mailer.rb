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

end
