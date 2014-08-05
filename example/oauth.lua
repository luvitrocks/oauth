-- Command-line Twitter OAuth example
local OAuth = require('../init').OAuth

local oauth = OAuth:new({
	requestUrl = 'https://api.twitter.com/oauth/request_token',
	accessUrl = 'https://api.twitter.com/oauth/access_token',
	consumerKey = '{YOUR CONSUMER KEY}',
	consumerSecret = '{YOUR CONSUMER SECRET}'
})

p('-----> Starting Twitter OAuth')
oauth:getOAuthRequestToken(function (err, requestToken, requestTokenSecret)
	p(err, requestToken, requestTokenSecret)
	p('Go to https://twitter.com/oauth/authorize?oauth_token=' .. requestToken .. ' and paste pin here:')

	process.stdout:write('>  ')
	process.stdin:on('data', function (line)
		p('-----> Getting access tokens')

		local pin = line:gsub('\n', '')
		oauth:getOAuthAccessToken(requestToken, requestTokenSecret, tostring(pin), function (err, accessToken, accessTokenSecret)
			p(err, accessToken, accessTokenSecret)
			process.exit()
		end)
	end)
	process.stdin:on('end', function ()
		process.exit()
	end)
	process.stdin:readStart()
end)
