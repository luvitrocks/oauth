local Object = require('core').Object
local crypto = require('_crypto')
local http = require('http')
local https = require('https')
local qs = require('querystring')
local table = require('table')
local string = require('string')

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

function OAuth:getOAuthAccessToken (code, params, callback)
	-- body
end

function OAuth:request ()
	-- body
end

function OAuth:_createClient ()
	-- body
end

return OAuth
