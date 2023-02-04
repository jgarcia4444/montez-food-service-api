class UserNotifierMailer < ApplicationMailer
    
    default from: "montez.food.service.auth@gmail.com"

    def send_code(user)
        @user = user
        mail to: @user.email, subject: "Reset Password Code"
    end

    def send_order_confirmation(order_info, user_email)
        puts "Order info from the send order confirmation mailer action."
        puts order_info
        @order_info = order_info
        @configured_address = "#{@order_info[:orderAddress][:street]}, #{@order_info[:orderAddress][:city]}, #{@order_info[:orderAddress][:state]}, #{@order_info[:orderAddress][:zip_code]}"
        mail to: user_email, subject: "Order Received"
    end

    def send_order_alert(order_info)
        @order_info = order_info
        # mail to: "montezfoodservice@gmail.com" subject: "New Order Received"
        mail to: "jgarciadev4444@gmail.com", subject: "New Order Received"
    end

    def pending_order_confirmation(order_info)
        @order_info = order_info
        mail to: order_info[:email], subject: "Order Confirmed"
    end

    def send_account_verification(user_info)
        @email = user_info.email
        @verification_url = "https://montez-food-service-web.vercel.app/users/account/verifying/#{user_info.email}"
        mail to: @email, subject: "Account Verification"
    end

    def cancel_order_send(user_order_info)
        # order_date, date_cancelled, total_price, address, items, reason_text
        @user_order_info = user_order_info
        mail to: user_order_info[:email], subject: "Order Cancelled"
    end

end
