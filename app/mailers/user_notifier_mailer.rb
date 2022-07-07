class UserNotifierMailer < ApplicationMailer
    def send_code(user)
        @user = user
        mail to: @user.email, subject: "Reset Password Code"
    end
end
