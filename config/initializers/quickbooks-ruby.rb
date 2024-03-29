
oauth_params = {
    site: "https://appcenter.intuit.com/connect/oauth2",
    authorize_url: "https://appcenter.intuit.com/connect/oauth2",
    token_url: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
}
OAUTH2_CLIENT = OAuth2::Client.new(ENV['OAUTH2_CLIENT_ID'], ENV['OAUTH2_CLIENT_SECRET'], oauth_params)