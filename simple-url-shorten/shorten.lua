ngx.header.content_type = 'text/json'

local functions = require('short/functions')
-- local cjson = require('cjson')
local args = ngx.req.get_uri_args()

local long_url = args['url']
local short_string = args['short']
local short_url, err = functions.url_create(long_url)
if err then
	functions.show_error(err)
end
ngx.say('{"status":1,"shorturl":"'..short_url..'"}')
