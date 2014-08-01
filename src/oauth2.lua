local Object = require('core').Object
local crypto = require('_crypto')
local http = require('http')
local https = require('https')
local qs = require('querystring')
local table = require('table')
local string = require('string')
local JSON = require('json')

local h = require('./_helpers')

local OAuth = Object:extend()

function OAuth:initialize (opts)
	opts = opts or {}

	self.clientID = opts.clientID
	self.clientSecret = opts.clientSecret
	self.baseSite = opts.baseSite
	self.authorizeUrl = opts.authorizePath or '/oauth/authorize'
	self.accessTokenUrl = opts.accessTokenPath or '/oauth/access_token'
	self.customHeaders = opts.customHeaders or {}
	self.accessTokenName = 'access_token'
	self.authMethod = 'Bearer'
	self.useAuthorizationHeaderForGET = false
end

function OAuth:setAccessTokenName (_name)
	self.accessTokenName = _name
end

function OAuth:setAuthMethod (_authMethod)
	self.authMethod = _authMethod
end

function OAuth:setUseAuthorizationHeaderForGET (_useIt)
	self.useAuthorizationHeaderForGET = _useIt
end

function OAuth:getAuthorizeUrl (params)
	params = params or {}
	params['client_id'] = self.clientID
	return self.baseSite .. self.authorizeUrl .. '?' .. h.stringify(params)
end

function OAuth:_getAccessTokenUrl ()
	return self.baseSite .. self.accessTokenUrl
end

function OAuth:getOAuthAccessToken (code, params, callback)
	params = params or {}
	params['client_id'] = self.clientID
	params['client_secret'] = self.clientSecret

	local codeParam = (params.grant_type == 'refresh_token' and 'refresh_token') or 'code'
	params[codeParam] = code

	opts = {
		method = 'POST',
		post_headers = {['Content-Type'] = 'application/x-www-form-urlencoded'},
		post_data = h.stringify(params)
	}

	self:request(self._getAccessTokenUrl(), opts, function (err, data, resp)
		if err then return callback(err) end

		-- As of http://tools.ietf.org/html/draft-ietf-oauth-v2-07
		-- responses should be in JSON
		local parseStatus, results = pcall(json.parse, data)
		if not parseStatus then return callback('JSON parsing error') end

		local access_token = results['access_token']
		local refresh_token = results['refresh_token']
		callback(nil, access_token, refresh_token, results)
	end)
end

function OAuth:request (url, opts, callback)
	if not url or type(url) ~= 'string' then
		return error('Request url is required and should be a String value')
	end

	if type(opts) ~= 'table' then
		return error('Options should be a Table value')
	end

	if type(callback) ~= 'function' then
		return error('Callback function is required')
	end

	opts = opts or {}

	local parsedURL = URL.parse(url)
	if parsedURL.protocol == 'http' and not parsedURL.port then parsedURL.port = 80 end
	if parsedURL.protocol == 'https' and not parsedURL.port then parsedURL.port = 443 end
end

function OAuth:_createClient (port, hostname, method, path, headers, protocol)
	local options = {
		host = hostname,
		port = port,
		path = path,
		method = method,
		headers = headers
	}

	local httpModel
	if (protocol == 'https') then httpModel = https else httpModel = http end
	return httpModel.request(options)
end

return OAuth
