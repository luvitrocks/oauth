local OAuth2 = require('../init').OAuth2

local oauth2 = OAuth2:new({
	clientID = '624b40586646206ffac1',
	clientSecret = '55f5b0d6b8bf524126a843f933a2b9a354e0ad83',
	baseSite = 'https://github.com/login'
})

local opts = {redirect_uri = 'http://luvit.io/oauth'}

p('-----> Starting Github OAuth2')
local authURL = oauth2:getAuthorizeUrl(opts)
p('Go to this URL and paste code query param here:')
p(authURL)
process.stdout:write('>  ')
process.stdin:on('data', function (line)
	p('-----> Getting access tokens')

	local code = line:gsub('\n', '')
	oauth2:getOAuthAccessToken(code, opts, function (err, access_token, refresh_token)
		p(err, access_token, refresh_token)
	end)
end)
process.stdin:on('end', function ()
	process.exit()
end)
process.stdin:readStart()
