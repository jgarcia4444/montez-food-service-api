class UsersController > ApplicationController

    def create
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

    def user_params
        params.require(:user_info).permit(:email, :password, :company_name)
    end

end