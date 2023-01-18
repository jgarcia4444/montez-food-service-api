
class QuickbooksController < ApplicationController

    def oauth_callback
        # oauth_params = {
        #     site: "https://appcenter.intuit.com/connect/oauth2",
        #     authorize_url: "https://appcenter.intuit.com/connect/oauth2",
        #     token_url: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
        # }
        # oauth2_client = OAuth2::Client.new(ENV['OAUTH2_CLIENT_ID'], ENV['OAUTH2_CLIENT_SECRET'], oauth_params)
        redirect_uri = "https://montez-food-service-web.vercel.app/users/admin"
        if resp = @oauth2_client.auth_code.get_token(params[:code], redirect_uri: redirect_uri)
            puts "RESP------"
            puts resp
            render :json => {
                success: true,
                refreshToken: resp.refresh_token,
                accessToken: resp.token,
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

    def generate_invoice

    end

    

end