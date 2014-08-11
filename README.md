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

To run examples clone this repo, create your applications on Twitter (for [OAuth](http://en.wikipedia.org/wiki/OAuth) example) and Github (for [OAuth2](http://en.wikipedia.org/wiki/OAuth2#OAuth_2.0)), paste necessary keys and secrets into files and execute them like ``luvit example/oauth.lua``:

### OAuth1.0

```lua
local OAuth = require('luvit-oauth').OAuth

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
local OAuth2 = require('luvit-oauth').OAuth2

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

## API

### OAuth1.0

##### Initialize

Create instance of ``OAuth`` class by calling ``:new(options)`` with options table as the only argument.

##### Options

- ``requestUrl``
- ``accessUrl``
- ``consumer_key``
- ``consumer_secret``
- ``signature_method`` - allowed by [spec](http://oauth.net/core/1.0/) signing crypto method. It could be ``HMAC-SHA1``, ``'PLAINTEXT'`` or ``RSA-SHA1``, defaults to ``'HMAC-SHA1'``
- ``authorize_callback``
- ``version`` - specification version, defaults to ``1.0``
- ``oauth_callback``
- ``customHeaders``

##### ``:setClientOptions(options)``

##### Options

- ``requestTokenHttpMethod`` - defaults ``'POST'``
- ``accessTokenHttpMethod`` - defaults ``'POST'``
- ``followRedirects`` - defaults ``true``

##### ``:getOAuthRequestToken(extraParams, callback)``

##### ``:getOAuthAccessToken(requestToken, requestTokenSecret, oauthVerifier, callback)``

##### ``:request(url, options, callback)``

Allows to make OAuth signed requests to provided API ``url``.

##### Options

- ``method`` - http method that will be send, required (also see [shorteners](https://github.com/luvitrocks/luvit-oauth#shorteners))
- ``oauth_token`` required
- ``oauth_token_secret`` required

### Shorteners

These methods allow to skip ``method`` field in request options for OAuth implementations:

- ``:get(url, options, callback)``
- ``:post(url, options, callback)``
- ``:put(url, options, callback)``
- ``:patch(url, options, callback)``
- ``:delete(url, options, callback)``

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
