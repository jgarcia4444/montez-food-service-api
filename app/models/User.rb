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

    def format_item(input_item_info)
    if input_item_info[:quantity] == nil and input_item_info[:item_info] == nil
        return {
            quantity: "",
            itemInfo: {
                description: "",
                upc: "",
                item: "",
                price: "",
                costPerUnit: "",
                caseCost: "",
                fiveCaseCost: ""    
            },
        }
    else
        item_info = input_item_info[:item_info]
        quantity = input_item_info[:quantity]
        return {
            quantity: quantity,
            itemInfo: {
                description: item_info.description,
                upc: item_info.upc,
                item: item_info.item,
                price: item_info.price,
                costPerUnit: item_info.cost_per_unit,
                caseCost: item_info.case_cost,
                fiveCaseCost: item_info.five_case_cost    
            },
        }
    end
    end

    def past_orders 
        user_orders = self.user_orders
        ordered_items = self.ordered_items 
        user_past_orders = user_orders.map do |user_order|
            specific_ordered_items = ordered_items.select {|ordered_item| ordered_item.user_order_id == user_order.id}
            past_order = {
                totalPrice: user_order.total_price,
                orderDate: user_order.created_at,
            }
            specific_items = specific_ordered_items.map do |specific_ordered_item|
                puts "SPECIFIC ORDERED ITEM:"
                puts specific_ordered_item
                order_item = OrderItem.find_by(id: specific_ordered_item.order_item_id)
                formatted_item = {}
                info_to_format = {
                    quantity: nil,
                    itemInfo: nil,
                }
                # puts "here is the order item:"
                # puts order_item
                if order_item
                    info_to_format[:quantity] = specific_ordered_item.quantity
                    info_to_format[:item_info] = order_item
                    formatted_item = format_item(info_to_format)
                else
                    formatted_item = format_item(info_to_format)
                end
                formatted_item
            end
            if specific_items.count > 0 
                past_order[:items] = specific_items
            else
                past_order[:items] = []
            end
            past_order  
        end
        user_past_orders.count > 0 ? user_past_orders : []
    end


end