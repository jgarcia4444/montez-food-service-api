class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true
    validates :company_name, presence: true
    validates :email, uniqueness: true
    validates :company_name, uniqueness: true
    has_many :user_orders
    has_many :ordered_items, through: :user_orders
    has_many :temp_carts, dependent: :destroy
    has_many :addresses, dependent: :destroy

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
#
    def create_user_order(order_info)
        items = order_info[:items]
        address_id = order_info[:address_id]
        sum_total = 0.00
        items.each do |item|
            item_price = item["price"].to_f
            quantity = item["quantity"].to_i
            item_total = quantity * item_price
            sum_total += item_total
        end
        user_order = UserOrder.create(user_id: self.id, total_price: sum_total, address_id: address_id)
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
            past_order_address = Address.find_by(id: user_order.address_id)
            order_address = {
                street: past_order_address.street,
                city: past_order_address.city,
                state: past_order_address.state,
                zipCode: past_order_address.zip_code,
            }
            past_order = {
                totalPrice: user_order.total_price,
                orderDate: user_order.created_at,
                orderAddress: order_address,
            }
            specific_items = specific_ordered_items.map do |specific_ordered_item|
                order_item = OrderItem.find_by(id: specific_ordered_item.order_item_id)
                formatted_item = {}
                info_to_format = {
                    quantity: nil,
                    itemInfo: nil,
                }
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

    def calc_item_total_price(order_item, quantity)
        price = order_item.price
        product = (price * quantity.to_i).round(2)
        return product
    end

    def get_latest_cart_setup
        if self.temp_carts.count > 0
            latest_cart_setup = self.temp_carts.order('created_at DESC').first
            if latest_cart_setup.created_at >= 1.day.ago && latest_cart_setup.created_at <= Time.now
                temp_cart_items = latest_cart_setup.temp_cart_items
                if temp_cart_items.count > 0
                    order_items = temp_cart_items.map do |temp_cart_item|
                        order_item = OrderItem.find_by(id: temp_cart_item.order_item_id)
                        if order_item
                            total_price = calc_item_total_price(order_item, temp_cart_item.quantity)
                            {
                                caseCost: order_item.case_cost,
                                costPerUnit: order_item.cost_per_unit,
                                description: order_item.description,
                                fiveCaseCost: order_item.five_case_cost,
                                item: order_item.item,
                                price: order_item.price,
                                quantity: temp_cart_item.quantity,
                                totalPrice: total_price
                            }
                        else
                            {}
                        end
                    end
                    {
                        items: order_items,
                    }
                else
                    puts "Empty object being passed because there are no temp cart items"
                    {}
                end
            else
                puts "Empty object being passed because the latest cart is past 24 hours old."
                {}
            end
        else
            puts "Empty object being passed because there are no temp carts."
            {}
        end
    end

    def calc_total_price(cart_info)
        total = 0.0
        cart_info.as_json.each do |cart_item|
            total += cart_item["quantity"].to_f * cart_item["price"].to_f
        end
        total
    end

    def persist_temp_cart(cart_info)
        if cart_info.count > 0
            total_price = calc_total_price(cart_info)
            temp_cart = TempCart.create(user_id: self.id, total_price: total_price)
            if temp_cart
                cart_info.each do |cart_item|
                    cart_item_id = OrderItem.find_by(description: cart_item[:description]).id
                    temp_cart_item = TempCartItem.create(
                        temp_cart_id: temp_cart.id,
                        quantity: cart_item[:quantity].to_i,
                        order_item_id: cart_item_id,
                    )
                    if !temp_cart.valid?
                        render :json => {
                            success: false,
                            error: {
                                message: "There was an error persisting a temp cart item."
                            }
                        }
                    end
                end
            else
                render :json => {
                    success: false,
                    error: {
                        message: "There was an error persisting the temporary cart."
                    }
                }
            end
        end
    end

    def get_user_locations 
        user_addresses = []
        Address.all.each do |address|
            if address.user_id == self.id
                user_addresses.append({
                    street: address.street,
                    city: address.city,
                    state: address.state,
                    zipCode: address.zip_code,
                    id: address.id,
                })
            end
        end
        user_addresses
    end

end