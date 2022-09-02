class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true
    validates :company_name, presence: true
    validates :email, uniqueness: true
    validates :company_name, uniqueness: true
    has_many :user_orders
    has_many :ordered_items, through: :user_orders

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

    def past_orders 
        user_orders = self.user_orders
        ordered_items = self.ordered_items
        # Object that should be sent as an array of objects
        # past_order_info = {
        #     totalPrice: user_order.total_price,
        #     items: items,
        #     orderDate: user_order.created_at
        # };
        # Order Item
        # {
        #     description: order_item.description,
        #     upc: order_item.upc,
        #     item: order_item.item,
        #     price: order_item.price,
        #     costPerUnit: order_item.cost_per_unit,
        #     caseCost: order_item.case_cost,
        #     fiveCaseCost: order_item.five_case_cost,
        # }

        past_orders = user_orders.map do |user_order|
            partitioned
        end

    end


end