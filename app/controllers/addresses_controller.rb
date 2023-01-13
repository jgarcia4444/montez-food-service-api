
class AddressesController < ApplicationController
    def create
        if params[:email]
            email = params[:email]
            user = User.find_by(email: "#{email}.com")
            if user
                if user.verified == true
                    if params[:address]
                        created_address = Address.create(address_params)
                        created_address.user_id = user.id
                        created_address.save
                        if created_address.valid?
                            usersAddress = created_address.format_for_frontend
                            render :json => {
                                success: true,
                                usersAddress: usersAddress
                            }
                        else
                            render :json => {
                                success: false,
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
    
    def destroy
        if params[:email]
            email = params[:email]
            user = User.find_by(email: "#{email}.com")
            if user 
                if params[:address_id]
                    address_id = params[:address_id]
                    address_to_be_destroyed = nil
                    user.addresses.each do |address|
                        if address.id == address_id.to_i
                            address_to_be_destroyed = address
                        end
                    end
                    if address_to_be_destroyed
                        address_destroyed = address_to_be_destroyed.destroy
                        if address_destroyed
                            render :json => {
                                success: true,
                                locations: user.addresses
                            }
                        else
                            render :json => {
                                success: false,
                                error: {
                                    message: "An error occurred while attempting to delete this location."
                                }
                            }
                        end
                    else
                        render :json => {
                            success: false,
                            error: {
                                message: "The location either does not belong to this user or it was not found with the given id."
                            }
                        }
                    end
                else
                    render :json => {
                        success: false,
                        error: {
                            message: "An id for the location must be supplied."
                        }
                    }
                end
            else
                render :json => {
                    success: false,
                    error: {
                        message: "Must be a valid user to delete a location."
                    }
                }
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "User must be logged in to delete a location."
                }
            }
        end
    end

    private
        def address_params
            params.require(:address).permit(:street, :city, :state, :zip_code)
        end

end