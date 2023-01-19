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
        # oauth_params = {
        #     site: "https://appcenter.intuit.com/connect/oauth2",
        #     authorize_url: "https://appcenter.intuit.com/connect/oauth2",
        #     token_url: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
        # }
        # oauth2_client = OAuth2::Client.new(ENV['OAUTH2_CLIENT_ID'], ENV['OAUTH2_CLIENT_SECRET'], oauth_params)
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
        puts "Test before errror!"

        # puts customer_service.fetch_by_id(user.id.to_s) 
        # if customer_service.fetch_by_id(user.id.to_s)
        #     customer = customer_service.fetch_by_id(user.id.to_s)
        #     address = Quickbooks::Model::PhysicalAddress.new
        #     address.line1 = order_address.street
        #     address.city = order_address.city
        #     address.country_sub_division_code = order_address.state
        #     address.postal_code = order_address.zip_code
        #     customer.billing_address = address
        #     customer_service.update(customer)
        # else
            customer = Quickbooks::Model::Customer.new
            customer.id = user.id
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
        # end

        invoice = Quickbooks::Model::Invoice.new
        invoice.customer_id = customer.id
        invoice.txn_date = DateTime.current
        items = invoice_info[:items]
        invoice_with_line_items = Admin.add_line_items(items, invoice)

        invoice_service = Quickbooks::Service::Invoice.new
        invoice_service.company_id = service_info[:realm_id]
        invoice_service.access_token = access_token
        serviced_invoice = invoice_service.create(invoice_with_line_items)
        sent_invoice = invoice_service.send(serviced_invoice)
        sent_invoice.email_status
    end


    def self.add_line_items(items, invoice)
        items.each do |item|
            item_info = item[:itemInfo]
            quantity = item[:quantity]
            line_item = Quickbooks::Model::InvoiceLineItem.new
            total_amount = item_info[:quantity] * item_info[:price]
            line_item.amount = total_amount
            line_item.description = item_info[:description]
            line_item.sales_item! do |detail|
                detail.unit_price = item_info[:price]
                detail.quantity = quantity
                detail.item_id = item_info[:upc]
            end
            invoice.line_items << line_item
        end
        invoice
    end

 end