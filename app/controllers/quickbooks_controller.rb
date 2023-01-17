
class QuickbooksController < ApplicationController

    def authenticate
        oauth_params = {
            site: "https://appcenter.intuit.com/connect/oauth2",
            authorize_url: "https://appcenter.intuit.com/connect/oauth2",
            token_url: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
        }
        oauth2_client = OAuth2::Client.new(ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], oauth_params)
        redirect_uri = "https://montez-food-service-web.vercel.app/users/admin"
        grant_url = oauth2_client.auth_code.authorize_url(redirect_uri: redirect_uri, response_type: "code", state: SecureRandom.hex(12), scope: "com.intuit.quickbooks.accounting")
        redirect_to grant_url
    end
end