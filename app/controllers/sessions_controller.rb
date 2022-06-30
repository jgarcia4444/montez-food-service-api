class SessionsController < ApplicationController
    def login
    end
    def logout
    end

    def root
        render :json => {
            message: "Welcome to the root route of the sessions controller."
        }
    end

end