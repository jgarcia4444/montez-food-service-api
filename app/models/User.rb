class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true
    validates :company_name, presence: true
    validates :email, uniqueness: true
    validates :company_name, uniqueness: true

    def create_ota_code
        ota_string = ""
        6.times do |i|
            random_number = rand(10)
            ota_string += random_number.to_s
        end
        self.update(ota_code: ota_string)
    end

    def self.find_by_email(user_email)
        User.find_by(email: user_email)
    end

    def create_user_order(items)
        sum_total = 0.00
        items.each do |item|
            item_price = item["price"].to_f
            quantity = item["quantity"].to_i
            item_total = quantity * item_price
            sum_total += item_total
        end
        user_order = UserOrder.create(user_id: self.id, total_price: sum_total)
        if user_order.valid?
            user_order
        else
            render :json => {
                success: false,
                error: {
                    message: "There was an error while creating the user order."
                }
            }
        end
    end


end