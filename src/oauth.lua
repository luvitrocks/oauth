local Object = require('core').Object
local crypto = require('_crypto')
local http = require('http')
local https = require('https')
local os = require('os')
local table = require('table')
local string = require('string')
local math = require('math')

--p(crypto)

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

	self.request_url = opts.request_url
	self.access_url = opts.access_url
	self.consumer_key = opts.consumer_key
	self.consumer_secret = opts.consumer_secret
	self.signature_method = opts.signature_method or 'HMAC-SHA1'
	if (self.signature_method ~= 'HMAC-SHA1' and
		self.signature_method ~= 'PLAINTEXT' and
		self.signature_method ~= 'RSA-SHA1')
	then
		return error('Unsupported signature method: ' .. self.signature_method)
	end
	self.nonce_size = opts.nonce_size or 32
	self.headers = opts.customHeaders or {['Accept']='*/*', ['Connection'] ='close', ['User-Agent'] = 'Luvit authentication'}
end

-- e.g. oauth:request('http://twitter.com/api/update.json', {method='POST', }, function () end)
function OAuth:request (uri, opts, callback)
	if not uri or type(uri) ~= 'string' then
		return error('Request uri is required and should be String value')
	end

	opts = opts or {}

	local method = opts.method:upper() or 'GET'

	local headers, arguments, post_body = self:_buildRequest(method, uri, opts.params, opts.headers)
end

function OAuth:_buildRequest(method, url, arguments, headers)
	assert(type(method) == "string", "'method' must be a string")

	local args = {
		oauth_consumer_key = self.consumer_key,
		oauth_nonce = generateNonce(self.nonce_size),
		oauth_signature_method = self.signature_method,
		oauth_timestamp = generateTimestamp(),
		oauth_version = '1.0'
	}
	local arguments_is_table = (type(arguments) == "table")
	if arguments_is_table then
		args = merge(args, arguments)
	end
	args.oauth_token = (arguments_is_table and arguments.oauth_token) or self.m_oauth_token or error("no oauth_token")
	local oauth_token_secret = (arguments_is_table and arguments.oauth_token_secret) or self.m_oauth_token_secret or error("no oauth_token_secret")
	if arguments_is_table then
		arguments.oauth_token_secret = nil	-- this is never sent
	end
	args.oauth_token_secret = nil	-- this is never sent

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

return OAuth
