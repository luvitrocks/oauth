local OAuth2 = require('../init').OAuth2

local oauth2 = OAuth2:new({
	clientID = '624b40586646206ffac1',
	clientSecret = '55f5b0d6b8bf524126a843f933a2b9a354e0ad83',
	baseSite = 'https://github.com/login'
})

local authURL = oauth2:getAuthorizeUrl({redirect_uri = 'http://luvit.io/oauth'})
p(authURL)
