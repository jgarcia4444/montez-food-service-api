class PendingOrder < ApplicationRecord
    has_one :user_order

    def confirm_order(order_info, admin_input)
        if self.destroy
            # Send out the email with the order info and the admin's input
        else

        end
    end

    def cancel_order(order_id)
        user_order = UserOrder.find_by(id: order_id)
        if user_order
            user_order.destroy
            self.destroy
            true
        else
            render :json => {
                success: false,
                error: {
                    message: "There was an error finding the user's order."
                }
            }
        end
    end

end
