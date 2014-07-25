local Object = require('core').Object
local crypto = require('_crypto')
local http = require('http')
local https = require('https')
local os = require('os')
local qs = require('querystring')
local URL = require('url')
local table = require('table')
local string = require('string')
local math = require('math')

-- generates a unix timestamp
local function generateTimestamp ()
	return tostring(os.time())
end

-- generates a nonce (number used once)
local NONCE_CHARS = {
	'a','b','c','d','e','f','g','h','i','j','k','l','m','n',
	'o','p','q','r','s','t','u','v','w','x','y','z','A','B',
	'C','D','E','F','G','H','I','J','K','L','M','N','O','P',
	'Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3',
	'4','5','6','7','8','9'
}
local function generateNonce (nonceSize)
	local result = {}

	for i = 1, nonceSize do
		local char_pos = math.floor(math.random() * #NONCE_CHARS)
		result[i] = NONCE_CHARS[char_pos]
	end

	return table.concat(result, '')

	--return crypto.hmac.new('sha1', "keyyyy"):update(nonce):final('hex')
end

local OAuth = Object:extend()

function OAuth:initialize (opts)
	opts = opts or {}

	self.requestUrl = opts.requestUrl
	self.accessUrl = opts.accessUrl
	self.consumer_key = opts.consumerKey
	self.consumer_secret = opts.consumerSecret
	self.signature_method = opts.signature_method or 'HMAC-SHA1'
	if (self.signature_method ~= 'HMAC-SHA1' and
		self.signature_method ~= 'PLAINTEXT' and
		self.signature_method ~= 'RSA-SHA1')
	then
		return error('Unsupported signature method: ' .. self.signature_method)
	end
	self.version = opts.version or '1.0'
	self.nonce_size = opts.nonce_size or 32
	self.authorize_callback = opts.authorize_callback or 'oob'
	self.headers = opts.customHeaders or {['Accept']='*/*', ['Connection'] ='close', ['User-Agent'] = 'Luvit authentication'}
	self.clientOptions = {requestTokenHttpMethod='POST', accessTokenHttpMethod='POST', followRedirects=true}
end

function OAuth:setClientOptions(options)
	if type(options) ~= 'table' then
		return error('Options should be table value')
	end

	for key, value in pairs(options) do
		if self.clientOptions[key] ~= nil then
			self.clientOptions[key] = value
		end
	end
end

function OAuth:getOAuthRequestToken (extraParams, callback)
	if type(extraParams) == 'function' then
		callback = extraParams
		extraParams = {}
	end

	-- callbacks are related to 1.0A
	extraParams['oauth_callback'] = self.authorize_callback

	local opts = {
		method = self.clientOptions.requestTokenHttpMethod,
		params = extraParams
	}

	self:request(self.requestUrl, opts, function (err, data, resp)
		if err then return callback(err) end

		local results = qs.parse(data)
		local oauth_token = results['oauth_token']
		local oauth_token_secret = results['oauth_token_secret']
		callback(nil, oauth_token, oauth_token_secret, results)
	end)
end

function OAuth:getOAuthAccessToken (oauth_token, oauth_token_secret, oauth_verifier, callback)
	-- body
end

---
-- After retrieving an access token, this method is used to issue properly authenticated requests.
-- (see http://tools.ietf.org/html/rfc5849#section-3)
-- @param url - the url to request
-- @parem opts - table of required and optional fields
--  `oauth_token` - required
--  `oauth_token_secret` - required
--  `method` - the http method (defaults to GET)
--  `params` - an optional table whose keys and values will be encoded as "application/x-www-form-urlencoded"
--   (when doing a POST) or encoded and sent in the query string (when doing a GET).
--   It can also be a string with the body to be sent in the request (usually a POST). In that case, you need to supply
--   a valid Content-Type header
-- @param callback - it's called with an (optional) error object and the result of the request.
--
-- e.g. oauth:request('http://twitter.com/api/update.json',
--         {method='POST', oauth_token='12345', oauth_token_secret='secret'},
--         function (err, res) end)
---
function OAuth:request (url, opts, callback)
	if not url or type(url) ~= 'string' then
		return error('Request url is required and should be a String value')
	end

	if type(opts) ~= 'table' then
		return error('Options should be a Table value')
	end

	opts = opts or {}

	local parsedURL = URL.parse(url)
	if parsedURL.protocol == 'http:' and not parsedURL.port then parsedURL.port = 80 end
	if parsedURL.protocol == 'https:' and not parsedURL.port then parsedURL.port = 443 end

	local orderedParams = self:_prepareParams(opts.oauth_token, opts.oauth_token_secret, method, url, parsedURL, opts.extraParams)


	-- local method = opts.method:upper() or 'GET'
	-- local oauth_token = opts.oauth_token or error('No oauth_token property')
	-- local oauth_token_secret = opts.oauth_token_secret or error('No oauth_token_secret property')
	-- local post_content_type = opts.post_content_type or 'application/x-www-form-urlencoded'

	-- local headers, params, post_body = self:_buildRequest(oauth_token, oauth_token_secret, method, url, post_content_type)
	-- local request = self:_createClient(parsedURL.port, parsedURL.hostname, method, headers, parsedURL.protocol)
end

function OAuth:_prepareParams (oauth_token, oauth_token_secret, method, url, parsedURL, extraParams)
	local oauthParams = {
		oauth_consumer_key = self.consumer_key,
		oauth_nonce = generateNonce(self.nonce_size),
		oauth_signature_method = self.signature_method,
		oauth_timestamp = generateTimestamp(),
		oauth_version = self.version
	}

	if oauth_token then oauthParams['oauth_token'] = oauth_token end

	if extraParams and type(extraParams) == 'table' then
		for key, value in pairs(extraParams) do
			oauthParams[key] = value
		end
	end

	if parsedURL.query then
		local extraParameters = qs.parse(parsedURL.query)
		for key, value in pairs(extraParameters) do
			if type(value) == 'table' then
				for key2, value2 in pairs(value) do
					oauthParams[key .. '[' .. key2 .. ']'] = value2
				end
			else
				oauthParams[key] = value
			end
		end
	end

	p(oauthParams)
end

function OAuth:_buildRequest (method, url, opts)
	local args = {
		oauth_consumer_key = self.consumer_key,
		oauth_nonce = generateNonce(self.nonce_size),
		oauth_signature_method = self.signature_method,
		oauth_timestamp = generateTimestamp(),
		oauth_version = self.version
	}

	local headers = {}
	headers['Authorization'] = self:_buildAuthorizationHeader();
	headers['Content-Type'] = opts.post_content_type;


	local oauth_signature, post_body, authHeader = self:Sign(method, url, args, oauth_token_secret)
	local headers = merge({}, headers)
	if self.m_supportsAuthHeader then
		headers["Authorization"] = authHeader
	end

	-- Remove oauth_related arguments
	if type(arguments) == 'table' then
		for k,v in pairs(arguments) do
			if type(k) == 'string' and k:match('^oauth_') then
				arguments[k] = nil
			end
		end
		if not next(arguments) then
			arguments = nil
		end
	end

	return headers, arguments, post_body
end

function OAuth:_createClient (port, hostname, method, path, headers, protocol)
	local options = {
		host = hostname,
		port = port,
		path = path,
		method = method,
		headers = headers
	}

	local httpModel = (protocol == 'https' and https) or http
	return httpModel.request(options);
end

function OAuth:_createSignature ()
	-- body
end

return OAuth
