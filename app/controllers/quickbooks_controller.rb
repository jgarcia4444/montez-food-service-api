
class QuickbooksController < ApplicationController

    def authenticate
        oauth_params = {
            site: "https://appcenter.intuit.com/connect/oauth2",
            authorize_url: "https://appcenter.intuit.com/connect/oauth2",
            token_url: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
        }
        oauth2_client = OAuth2::Client.new(ENV['OAUTH2_CLIENT_ID'], ENV['OAUTH2_CLIENT_SECRET'], oauth_params)
        redirect_uri = "https://montez-food-service-web.vercel.app/users/admin"
        # redirect_uri = "https://montez-food-service-api.herokuapp.com/oauth/callback"
        grant_url = oauth2_client.auth_code.authorize_url(redirect_uri: redirect_uri, response_type: "code", state: SecureRandom.hex(12), scope: "com.intuit.quickbooks.accounting")
        redirect_to grant_url, allow_other_host: true
    end

    def oauth_callback
        oauth_params = {
            site: "https://appcenter.intuit.com/connect/oauth2",
            authorize_url: "https://appcenter.intuit.com/connect/oauth2",
            token_url: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
        }
        oauth2_client = OAuth2::Client.new(ENV['OAUTH2_CLIENT_ID'], ENV['OAUTH2_CLIENT_SECRET'], oauth_params)
        puts "Params from the oauth_callback action---------"
        puts params
        redirect_uri = "https://montez-food-service-web.vercel.app/users/admin"
        if resp = oauth2_client.auth_code.get_token(params[:code], redirect_uri: redirect_uri)
            puts "Resp from getting a token"
            puts resp
            render :json => {
                success: true,
                resp: resp,
            }
        else
            render :json => {
                success: false,
                error: {
                    message: "There was an error retrieving the tokens."
                }
            }
        end
    end
end