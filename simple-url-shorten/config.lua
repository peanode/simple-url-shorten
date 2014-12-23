local mod_name = ...
local M = {}
local base_table = {'e','Q','W','3','s','5','R','J','a','g','M','T','7','n','O','X','8','f','2','o','z','w','G','K','x','D','Z','F','b','u','N','L','S','l','Y','V','I','t','4','q','6','A','y','1','i','B','C','c','P','0','U','r','k','j','m','p','9','h','v','d','E','H'}

-- Base table for short URL string
-- You can use random table as this table
-- local base_table = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}

-- Base string of Base table
local base_str = table.concat( base_table, "")

-- analysis switch
-- local analysis = 1

-- Redis database config
local redis = {}
redis['host'] = '127.0.0.1'
redis['port'] = 6379
redis['password'] = 'passwd'


-- Initial Short URL
-- The first Short URL,will no use
-- The length depens on the table's numbers
-- chars length and the numbers of URL are following
-- 1  ->  62
-- 2  ->  3844
-- 3  ->  238328
-- 4  ->  14776336
-- 5  ->  916132832
-- 6  ->  56800235584
-- 7  ->  3521614606208
-- 8  ->  218340105584896
-- 9  ->  13537086546263552
-- 10 ->  839299365868340224
-- 11 ->  52036560683837093888
-- 12 ->  3226266762397899821056
-- 13 ->  200028539268669788905472
-- 14 ->  12401769434657526912139264
-- 15 ->  768909704948766668552634368
-- 16 ->  47672401706823533450263330816
local start_url = {'0','0','0','0'}

-- Short URL's prefix
-- Default is NULL
local prefix = ''

-- Short URL's suffix
local suffix = ''

-- Domain for short URL
-- if is empty,will return short string
local domain = 'http://192.168.56.201/'

-- White list of domain
-- Host just as:  www.example.com:8081
-- if you set white_host,this tool is only allow the url in the white list host
local white_host = {}
local black_host = {domain}

-- Errors
local err_msg = {}
err_msg[34] = 'URL has existed'
err_msg[41] = 'URL is invalid'
err_msg[42] = 'URL is not allow to shorten'
err_msg[51] = 'Database is out of service'
err_msg[52] = 'Getting data error'
err_msg[53] = 'Larger than maximum numbers of URLs'

M['base_table'] = base_table
M['base_str'] = base_str
M['prefix'] = prefix
M['start_url'] = start_url
M['suffix'] = suffix
M['white_host'] = white_host
M['black_host'] = black_host
M['err_msg'] = err_msg
M['redis'] = redis
M['domain'] = domain


return M
