
class QuickBooksController < ApplicationController
    
    def authenticate
        redirect_uri = "https://montez-food-service-web.vercel.app/users/admin"
        grant_url = oauth2_client.auth_code.authorize_url(redirect_uri: redirect_uri, response_type: "code", state: SecureRandom.hex(12), scope: "com.intuit.quickbooks.accounting")
        redirect_to grant_url
    end
end