# luvit-oauth

[![NPM version](https://badge.fury.io/js/luvit-oauth.svg)](http://badge.fury.io/js/luvit-oauth)

Simple [OAuth](http://en.wikipedia.org/wiki/OAuth) and [OAuth2](http://en.wikipedia.org/wiki/OAuth2#OAuth_2.0) API for [luvit.io](http://luvit.io). It allows users to authenticate against providers and thus act as OAuth consumers. Tested against Twitter (http://twitter.com) and Github (http://github.com).

## Install

```bash
npm install luvit-oauth
```

If you're not familiar with npm check this out:

- https://github.com/voronianski/luvit-npm-example#how-to
- https://github.com/luvitrocks/luvit-utopia#install

## Examples

To run examples clone this repo execute them like ``luvit example/oauth.lua``:

### OAuth1.0

```lua
local OAuth = require('../init').OAuth

local oauth = OAuth:new({
	requestUrl = 'https://api.twitter.com/oauth/request_token',
	accessUrl = 'https://api.twitter.com/oauth/access_token',
	consumerKey = '{{YOUR CONSUMER KEY}}',
	consumerSecret = '{{YOUR CONSUMER SECRET}}'
})

oauth:getOAuthRequestToken(function (err, requestToken, requestTokenSecret)
	p(err, requestToken, requestTokenSecret)

	-- use your flow for verification
	oauth:getOAuthAccessToken(requestToken, requestTokenSecret, '{{YOUR OAUTH VERIFIER}}', function (err, accessToken, accessTokenSecret)
		p(err, accessToken, accessTokenSecret)
	end)
end)
```

and ``luvit example/oauth2.lua``:

### OAuth2.0

```lua
local OAuth2 = require('../init').OAuth2

local oauth2 = OAuth2:new({
	clientID = '{{YOUR CLIENT ID}}',
	clientSecret = '{{YOUR CLIENT SECRET}}',
	baseSite = 'https://github.com/login'
})

local opts = {redirect_uri = 'http://luvit.io/oauth'}

-- go to received URL and copy code
local authURL = oauth2:getAuthorizeUrl(opts)

oauth2:getOAuthAccessToken('{{YOUR CODE}}', opts, function (err, access_token, refresh_token, results)
	p(err, access_token, refresh_token, results)
end)
```

## License

MIT Licensed

Copyright (c) 2014 Dmitri Voronianski [dmitri.voronianski@gmail.com](mailto:dmitri.voronianski@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
