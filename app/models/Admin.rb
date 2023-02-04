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

        if user.quickbooks_id == ""
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
            user.update(quickbooks_id: customer.id)
            if user.valid? == false
                render :json => {
                    success: false,
                    error: {
                        message: "There was an error adding the quickbooks_id to the user record."
                    }
                }
            end
        else
            customer = customer_service.fetch_by_id(user.quickbooks_id)
            address = Quickbooks::Model::PhysicalAddress.new
            address.line1 = order_address.street
            address.city = order_address.city
            address.country_sub_division_code = order_address.state
            address.postal_code = order_address.zip_code
            customer.billing_address = address
            customer_service.update(customer)
        end

        invoice = Quickbooks::Model::Invoice.new
        invoice.txn_date = DateTime.current
        invoice.billing_email_address = user.email
        invoice.customer_id = serviced_customer.id
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
            line_item = Quickbooks::Model::InvoiceLineItem.new
            total_amount = quantity * item_info[:price]
            line_item.amount = total_amount
            line_item.description = item_info[:description]
            line_item.sales_item! do |detail|
                detail.unit_price = item_info[:price]
                detail.quantity = quantity
                # detail.item_id = item_info[:upc]
            end
            invoice.line_items << line_item
        end
        invoice
    end

 end