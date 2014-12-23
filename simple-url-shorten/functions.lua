local mod_name = (...)
local config = require('short/config')
local cjson = require('cjson')
local redis = require ("resty.redis")
local M = {}

function M.find_in_table(table, value)
	if table == ngx.null or #table==0 then
		return false
	end
	for k,v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

-- get url details
function M.get_url_details(long_url)
	if long_url==nil or long_url=='' or #long_url>2048 then
		return nil, 41
	end
	local result = {}
	local matches = ngx.re.match(long_url, '^(http|https|ftp)://([^/]+)(/[^\\\\?#]+)([^#]+)?(.+)')
	if matches[2] then
		result['protocol'] = matches[1]
		result['host'] = matches[2]
	else
		return nil,41
	end
	if #config['white_host'] ~= 0 then
		if M.find_in_table(config['white_host'], result['host']) then
			return result
		else
			return nil, 42
		end
	end
	if M.find_in_table(config['black_host'], result['host']) then
		return nil, 42
	end
	return result
end

-- connect redis database
function M.redis_connect()
	local red = redis:new()
	red:set_timeout(1000)
	local ok, err = red:connect(config['redis']['host'], config['redis']['port'])
	if not ok then
		return nil, 51 
	end
	local res, err = red:auth(config['redis']['password'])
	if not res then
		return nil, 51
	end
	return red
end

function M.get_short_string(last)
	local result = {}
	local str = ''
	if last ~= ngx.null then
		str = string.sub(last, #config['prefix']+1, #last-#config['suffix'])
		for k in string.gmatch(str, "([0-9a-zA-Z])") do
			table.insert(result, k)
		end
	else
		str = table.concat(config['start_url'],'')
		result = config['start_url']
	end
	for i=#str, 1, -1 do
		local char = string.sub(str, i, i)

		local pos = string.find(config['base_str'], char)

		local pos_start = string.find(config['base_str'], config['start_url'][i])

		if pos == #config['base_str'] then
			pos =0
		end

		result[i] = config['base_table'][pos+1]
		if pos_start ~= pos+1 then
			break
		elseif i == 1 then
				return nil, 53
		end
	end

	return config['prefix'].. table.concat(result,'') .. config['suffix']
end

function M.get_long_url(short_string)
	if ngx.re.find(short_string, '[^0-9a-zA-Z]') then
		return false,41
	end
	local red, err = M.redis_connect()
	if err then
		return false, err
	end
	local result, err = red:get('S_' .. short_string)
	if err then
		return nil, 52
	end
	red:set_keepalive(10000, 100)
	if result ~= ngx.null then
		return result
	else
		return nil, 52
	end
end

function M.show_error(err_code, long_url)
	local result = {}
	result['status'] = 0
	result['error'] = err_code
	result['msg'] = config['err_msg'][err_code]
	if long_url then
		result['url'] = long_url
	end
	ngx.say(cjson.encode(result))
	ngx.exit(ngx.HTTP_OK)
end

function M.url_create(long_url, short_string)
	local red, err = M.redis_connect()
	if err then
		return false, err
	end
	local url_md5 = ngx.md5(long_url)
	local result, err = red:get('M_' .. url_md5)
	if err then
		return nil, 52
	end
	if result ~= ngx.null then
		return config['domain']..result
	end
	local url_details, err = M.get_url_details(long_url)
	if err then
		return nil, err
	end
	local last, err = red:get('V_last')
	if err or last==ngx.NULL then
		return nil, 52
	end
	local short_string, err = M.get_short_string(last)
	if err then
		return nil, err
	end
	red:set('M_' .. url_md5, short_string)
	red:set('V_last', short_string)
	red:set('S_' .. short_string, long_url)
	red:set_keepalive(10000, 100)
	return config['domain']..short_string
end


return M
