
class AddressesController < ApplicationController
    def create
        if params[:user_id]
            user_id = params[:user_id]
            user = User.find_by(id: user_id)
            if user
                if user.verified == true
                    if params[:address_info]
                        address_info = params[:address_info]
                        address = Address.new
                        address_info.each {|key, value| address[key] = value}
                        address.user_id = user_id
                        address.save
                        if address.valid?
                            usersAddress = address.format_for_frontend
                            render :json => {
                                success: true,
                                usersAddress: usersAddress
                            }
                        else
                            render :json => {
                                success: true,
                                error: {
                                    message: "There was an error saving the users address."
                                }
                            }
                        end
                    else
                        render :json => {
                            success: false,
                            error: {
                                message: "No address info was sent to be saved."
                            }
                        }
                    end
                else
                    render :json => {
                        success: false,
                        error: {
                            message: "User must be verified to add an address."
                        }
                    }
                end             
            else
                render :json => {
                    success: false,
                    error: {
                        message: "Must be a valid User to add an address."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "User must be signed in to add an address."
                }
            }
        end
    end
end