# luvit-oauth

[![NPM version](https://badge.fury.io/js/luvit-oauth.svg)](http://badge.fury.io/js/luvit-oauth)

Simple [OAuth](http://en.wikipedia.org/wiki/OAuth) and [OAuth2](http://en.wikipedia.org/wiki/OAuth2#OAuth_2.0) API for [luvit.io](http://luvit.io). It allows users to authenticate against providers and thus act as OAuth consumers. Tested against Twitter (http://twitter.com) and Github (http://github.com).

## Install

```bash
npm install luvit-oauth
```

If you're not familiar with npm check this out:

- https://github.com/voronianski/luvit-npm-example#how-to
- https://github.com/luvitrocks/luvit-module-boilerplate#whats-npm

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

##### ``:new(options)``

Create instance of ``OAuth`` class by calling ``:new(options)`` with options table as the only argument.

##### Options

- ``requestUrl`` - required request token url
- ``accessUrl`` - required oauth token url
- ``consumer_key`` - required public key
- ``consumer_secret`` - required private key
- ``signature_method`` - allowed by [spec](http://oauth.net/core/1.0/) signing crypto method. It could be ``'HMAC-SHA1'`` (default), ``'PLAINTEXT'`` or ``'RSA-SHA1'``
- ``authorize_callback`` - optional authorization callback url, defaults to ``nil``
- ``nonce_size`` - size of unique token your application will generate for each unique request, default ``32``
- ``version`` - [spec](http://oauth.net/core/1.0/) version, defaults to ``1.0``
- ``customHeaders`` - optional table with http headers to be sent in the requests

##### ``:setClientOptions(options)``

Change things like http methods for request token and access token urls.

##### Options

- ``requestTokenHttpMethod`` - default ``'POST'``
- ``accessTokenHttpMethod`` - default ``'POST'``
- ``followRedirects`` - default ``true``

##### ``:getOAuthRequestToken(extraParams, callback)``

Requests an unauthorized request token (http://tools.ietf.org/html/rfc5849#section-2.1). ``extraParams`` is an optional table value which will be sent as querystring or as ``application/x-www-form-urlencoded`` for ``POST`` body.

##### ``:getOAuthAccessToken(requestToken, requestTokenSecret, oauthVerifier, callback)``

Exchanges a request token for an access token (http://tools.ietf.org/html/rfc5849#section-2.3).

##### ``:request(url, options, callback)``

Allows to make OAuth signed requests to provided API ``url`` string.

##### Options

- ``method`` - http method that will be send, required (not necessary with [shorteners](https://github.com/luvitrocks/luvit-oauth#shorteners))
- ``oauth_token`` - required access token
- ``oauth_token_secret`` - required access token secret
- ``post_body`` - body that will be sent with ``POST`` or ``PUT``
- ``post_content_type`` - content type for ``POST`` or ``PUT`` requests, default ``application/x-www-form-urlencoded``
- ``extraParams`` - optional table with values that will be sent as querystring or ``post_body`` for ``POST`` requests if it's not provided 

### OAuth 2.0

##### Initialize

##### ``:new(options)``

Create instance of ``OAuth2`` class by calling ``:new(options)`` with ``options`` table as the only argument.

##### Options

- ``clientID`` - required client id
- ``clientSecret`` - required client secret
- ``baseSite`` - required base OAuth provider url
- ``authorizePath`` - optional, default ``'/oauth/authorize'``
- ``accessTokenPath`` - optional, default ``'/oauth/access_token'``
- ``customHeaders`` - optional table with http headers to be sent in the requests

##### ``:setAccessTokenName(name)``

Change ``access_token`` param name to different one if authorization server waits for another.

##### ``:setAuthMethod(method)``

Change authorization method that defaults to ``Bearer``.

##### ``:setUseAuthorizationHeaderForGET(useIt)``

If you use the ``OAuth2`` exposed ``:get()`` shortener method this will specify whether to use an ``'Authorization'`` header instead of passing the ``access_token`` as a query parameter.

##### ``:getAuthorizeUrl(params)``

Get an authorization url to proceed flow and receive ``code`` that will be used for getting ``access_token``.

##### ``:getOAuthAccessToken(code, params, callback)``

Get an access token from the authorization server.

##### ``:request(url, opts, callback)``

Allows to make OAuth2 signed requests to provided API ``url`` string.

##### Options

- ``method`` - http method that will be send, required (not necessary with [shorteners](https://github.com/luvitrocks/luvit-oauth#shorteners))
- ``access_token`` - required access token
- ``post_body`` - body that will be sent with ``POST`` or ``PUT``
- ``post_content_type`` - content type for ``POST`` or ``PUT`` requests, default ``application/x-www-form-urlencoded``
- ``headers`` - optional table with values that will be sent with request

### Shorteners

These methods allow to skip ``method`` field in request options for both ``OAuth`` and ``OAuth2`` implementations:

- **``:get(url, options, callback)``**
- **``:post(url, options, callback)``**
- **``:put(url, options, callback)``**
- **``:patch(url, options, callback)``**
- **``:delete(url, options, callback)``**

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
