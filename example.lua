local OAuth = require('./init').OAuth

local oauth = OAuth:new({
	requestUrl = 'https://api.twitter.com/oauth/request_token',
	accessUrl = 'https://api.twitter.com/oauth/access_token',
	consumerKey = 'VWJLiBROB4nSjwYYhovKZJlsa',
	consumerSecret = 'lLHPGQ8BJQZGz1KpT6TMlYGO6WvMrHztsc7Q3Ga8hhPU7ANhHu'
})

oauth:getOAuthRequestToken(function (err, requestToken, requestTokenSecret)
	p(err, requestToken, requestTokenSecret)
	-- oauth:getOAuthAccessToken(requestToken, requestTokenSecret, function (err, accessToken, accessTokenSecret)

	-- end)
end)
