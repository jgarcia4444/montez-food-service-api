class UserOrder < ApplicationRecord
    has_many :ordered_items
    belongs_to :user
    has_one :address
    has_one :pending_order, dependent: :destroy

    def persist_ordered_items(items)
        items.each do |item|
            order_item_id = OrderItem.find_by(description: item["description"]).id
            ordered_item = OrderedItem.create(order_item_id: order_item_id, quantity: item["quantity"].to_i, user_order_id: self.id, case_bought: item[:caseBought])
            if ordered_item.valid? == false
                render :json => {
                    success: false,
                    error: {
                        message: "There was an error persisting an order item as and ordered item."
                    }
                }
            end
        end
        
    end

    def get_order_items
        ordered_items = OrderedItem.all.select{|ordered_item| ordered_item.user_order_id == self.id}
        ordered_items.map do |ordered_item|
            order_item_id = ordered_item.order_item_id
            order_item = OrderItem.find_by(id: order_item_id)
            {
                quantity: ordered_item.quantity,
                itemInfo: {
                    description: order_item.description,
                    upc: order_item.upc,
                    price: order_item.price,
                    caseBought: ordered_item.case_bought,
                    caseCost: order_item.case_cost,
                    unitsPerCase: order_item.units_per_case,
                    id: order_item.id,
                    quickbooks_id: order_item.quickbooks_id
                },
                caseBought: ordered_item.case_bought
            }
        end
    end

    def order_items
        
        ordered_items = OrderedItem.all.select{|ordered_item| ordered_item.user_order_id == self.id}
        ordered_items.map do |ordered_item|
            order_item_id = ordered_item.order_item_id
            order_item = OrderItem.find_by(id: order_item_id)
            {
                description: order_item.description,
                upc: order_item.upc,
                item: order_item.item,
                price: order_item.price,
                unitsPerCase: order_item.units_per_case,
                caseCost: order_item.case_cost,
                fiveCaseCost: order_item.five_case_cost,
            }
        end
    end

    def format_date
        self.created_at.to_fs(:long)
    end

    def update_total_price 
        ordered_items = self.ordered_items
        sum_total = 0.00
        ordered_items.each do |ordered_item|
            order_item = OrderItem.find_by(id: ordered_item.order_item_id)
            if order_item
                item_price = ordered_item.case_bought == true ? order_item.case_cost : order_item.price
                item_total = item_price * ordered_item.quantity
                sum_total += item_total
            else
                return false
            end
        end
        self.update(total_price: sum_total.round(2))
        if self.valid?
            true
        else
            false
        end
    end

    def previous_delivery_fee(service_info)
        user_id = self.user_id
        user = User.find_by(id: user_id)
        if user
            customer_ref = user.quickbooks_id
            if customer_ref != ""
                access_token = OAuth2::AccessToken.new(OAUTH2_CLIENT, service_info[:access_token], refresh_token: service_info[:refresh_token])
                invoice_service = Quickbooks::Service::Invoice.new
                invoice_service.access_token = access_token
                invoice_service.company_id = service_info[:realm_id]
                invoices = invoice_service.query("Select * From Invoice Where CustomerRef = '#{customer_ref}'")
                address = Address.find_by(id: self.address_id)
                if address
                    invoices_with_same_address = invoices.select do |invoice|
                        # Here we would have to find a line_item.description in the invoice that matches an address. (Deliver To: #{address})
                        # In the checking using the user_order address ensure to add Deliver To: at the beginning of the formatted address
                        # Also ensure that the formatted user_order address is in the same format as the QB description.
                        matching_address_line_items = invoice.line_items.select {|line_item| line_item.description == "Deliver To: #{address.format_address}"}
                        if matching_address_line_items.count > 0
                            true
                        else
                            false
                        end
                    end
                    if invoices_with_same_address.count > 0
                        latest_invoice = invoices_with_same_address[0]
                        latest_invoice.line_items.each do |line_item|
                            if line_item.description == "Deliver To: #{address.format_address}"
                                return line_item.amount.to_s
                            end
                        end
                    else
                        return ""
                    end
                else
                    render :json => {
                        success: false,
                        error: {
                            message: "An address id was not present with the user order."
                        }
                    }
                end
            else
                return ""
            end
        else
            render :json => {
                success: false,
                error: {
                    message: "A user was not found with the order information"
                }
            }
        end
    end

end
