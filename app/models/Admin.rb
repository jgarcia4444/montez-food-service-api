 class Admin < ApplicationRecord
    has_secure_password

    oauth_params = {
        site: "https://appcenter.intuit.com/connect/oauth2",
        authorize_url: "https://appcenter.intuit.com/connect/oauth2",
        token_url: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
    }
    oauth2_client = OAuth2::Client.new(ENV['OAUTH2_CLIENT_ID'], ENV['OAUTH2_CLIENT_SECRET'], oauth_params)

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
        access_token = OAuth2::AccessToken.new(oauth2_client, service_info[:access_token], refresh_token: service_info[:refresh_token])

        service = Quickbooks::Service::Invoice.new
        service.company_id = service_info[:realm_id]
        service.access_token = access_token

        invoice = Quickbooks::Model::Invoice.new
        user = customer_info[:user]
        order_address = customer_info[:order_address]
        customer = nil
        if service.fetch_by_id(user.id.to_s)
            customer = service.fetch_by_id(user.id.to_s)
            address = Quickbooks::Model::PhysicalAddress.new
            address.line1 = order_address.street
            address.city = order_address.city
            address.country_sub_division_code = order_address.state
            address.postal_code = order_address.zip_code
            customer.billing_address = address
            service.update(customer)
        else
            customer = Quickbooks::Model.Customer.new
            cusomer.id = user.id
            customer.company_name = user.company_name
            customer.email_address = user.email_address
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
        end

        #set up invoice




    end

 end