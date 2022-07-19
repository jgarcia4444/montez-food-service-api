class UserNotifierMailer < ApplicationMailer
    default from: "montez.food.service.auth@gmail.com"
    def send_code(user)
        @user = user
        mail to: @user.email, subject: "Reset Password Code"
    end
end
