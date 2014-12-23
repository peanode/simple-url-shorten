ngx.header.content_type = 'text/html'
local config = require('short/config')
local functions = require('short/functions')
local short_string = string.sub(ngx.var.uri, -#config['start_url'])
local long_url, err = functions.get_long_url(short_string)
if err then
	functions.show_err(err)
end
ngx.redirect(long_url)
