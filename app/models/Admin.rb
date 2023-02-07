 class Admin < ApplicationRecord
    has_secure_password

    def verify(password)
        if self.authenticate(password)
            true
        else
            false
        end
    end

    def self.send_invoice(info_for_invoice)
        service_info = info_for_invoice[:service_info]
        customer_info = info_for_invoice[:customer_info]
        invoice_info = info_for_invoice[:invoice_info]
        access_token = OAuth2::AccessToken.new(OAUTH2_CLIENT, service_info[:access_token], refresh_token: service_info[:refresh_token])

        customer_service = Quickbooks::Service::Customer.new
        customer_service.company_id = service_info[:realm_id]
        customer_service.access_token = access_token

        user = customer_info[:user]
        order_address = customer_info[:order_address]
        customer = nil

        puts "Here is the user.quickbooks_id"
        puts user.quickbooks_id
        if user.quickbooks_id == ""
            puts "NO QUICKBOOKS_ID FOUND"
            customer = Quickbooks::Model::Customer.new
            customer.company_name = user.company_name
            customer.email_address = user.email
            customer.family_name = user.last_name
            customer.given_name = user.first_name
            phone1 = Quickbooks::Model::TelephoneNumber.new
            phone1.free_form_number = user.phone_number
            customer.mobile_phone = phone1
            address = Quickbooks::Model::PhysicalAddress.new
            address.line1 = order_address.street
            address.city = order_address.city
            address.country_sub_division_code = order_address.state
            address.postal_code = order_address.zip_code
            customer.billing_address = address
            serviced_customer = customer_service.create(customer)
            puts "HERE IS THE SERVICED CUSTOMER ID"
            puts serviced_customer.id
            user.update(quickbooks_id: serviced_customer.id)
            if user.valid? == false
                render :json => {
                    success: false,
                    error: {
                        message: "There was an error adding the quickbooks_id to the user record."
                    }
                }
            end
        else
            puts "USER QUICKBOOK_ID FOUND!!!"
            customer = customer_service.fetch_by_id(user.quickbooks_id)
            address = Quickbooks::Model::PhysicalAddress.new
            address.line1 = order_address.street
            address.city = order_address.city
            address.country_sub_division_code = order_address.state
            address.postal_code = order_address.zip_code
            customer.billing_address = address
            customer_service.update(customer)
            puts "quickbooks id from user model"
            puts user.quickbooks_id
        end

        invoice = Quickbooks::Model::Invoice.new
        invoice.txn_date = DateTime.current
        invoice.billing_email_address = user.email
        invoice.customer_id = user.quickbooks_id
        items = invoice_info[:items]
        invoice_with_line_items = Admin.add_line_items(items, invoice)

        invoice_service = Quickbooks::Service::Invoice.new
        invoice_service.company_id = service_info[:realm_id]
        invoice_service.access_token = access_token
        serviced_invoice = invoice_service.create(invoice_with_line_items)
        if serviced_invoice
            true
        else
            false
        end
    end


    def self.add_line_items(items, invoice)
        items.each do |item|
            item_info = item[:itemInfo]
            quantity = item[:quantity]
            case_bought = item[:case_bought]
            line_item = Quickbooks::Model::InvoiceLineItem.new
            price = case_bought == true ? item_info[:case_cost] : item_info[:price]
            total_amount = quantity * price
            line_item.amount = total_amount
            name = case_bought == true ? "#{item_info[:description]} #{item_info[:unitsPerCase] units}" : item_info[:description]
            line_item.description = name
            line_item.sales_item! do |detail|
                detail.unit_price = price
                detail.quantity = quantity
            end
            invoice.line_items << line_item
        end
        invoice
    end

 end