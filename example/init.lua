-- Command-line Twitter OAuth example
local OAuth = require('../init').OAuth

local oauth = OAuth:new({
	requestUrl = 'https://api.twitter.com/oauth/request_token',
	accessUrl = 'https://api.twitter.com/oauth/access_token',
	consumerKey = 'VWJLiBROB4nSjwYYhovKZJlsa',
	consumerSecret = 'lLHPGQ8BJQZGz1KpT6TMlYGO6WvMrHztsc7Q3Ga8hhPU7ANhHu'
})

p('-----> Starting Twitter OAuth')
oauth:getOAuthRequestToken(function (err, requestToken, requestTokenSecret)
	p(err, requestToken, requestTokenSecret)
	p('Go to https://twitter.com/oauth/authorize?oauth_token=<YOUR REQUEST TOKEN> and paste pin here:')

	process.stdout:write('>  ')
	process.stdin:on('data', function (line)
		p('-----> Getting access tokens')

		local pin = line:gsub('\n', '')
		p(pin)
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
