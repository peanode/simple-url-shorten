# simple-url-shorten #
## 基于lua-ngx的简单URL缩短系统 ##

simple-url-shorten是一个基于openresty的Lua模块和Redis模块开发的简单、快速的网址缩短“系统”，它能够对提交的网址就行编码，缩短到指定长度的网址。Nginx、Lua、Redis的我这里就不做介绍了，但是他们都有一个共同的优点——性能高。simple-url-shorten具有如下特点：

	1. 使用Nginx+lua+redis，性能非常高；
	2. 具有域名黑名单、白名单，支持简单认证；
	3. 支持自定义短URL长度；
	4. 支持自定义短网址字符前缀、后缀
	5. 使用302方式跳转，302模板可以通过修改Nginx302模板修改
	6. 使用json方式返回数据

既然是简单的URL网址缩短服务，当然也会有不足之处：

	1. 没有计数及分析功能：前期考虑添加计数及分析功能，但是考虑跳转的高效性，省略了计数及统计分析功能，该功能可能在以后的更新中添加；
	2. 需要手工编译安装Openresty，对于不熟悉Linux软件编译安装的用户有一定的难度；

## 安装方法 ##
	1. 编译安装openresty，要启用lua模块。[http://openresty.org/](http://openresty.org/ "Openresty")
	2. 安装并配置redis软件
	3. 下载simple-url-shorten文件，lualib（默认/usr/local/openresty/lualib）目录中新建short目录，将lua代码文件放置于目录中
		[root@localhost ~]# ll /usr/local/openresty/lualib/short
		-rw-r--r--. 1 root root 2434 Dec 22 16:44 config.lua
		-rw-r--r--. 1 root root 3491 Dec 22 16:44 functions.lua
		-rw-r--r--. 1 root root  313 Dec 22 16:13 index.lua
		-rw-r--r--. 1 root root  369 Dec 22 16:35 shorten.lua

	4. 配置nginx.conf（文件默认位置/usr/local/openresty/nginx/conf/nginx.conf）

		server {

			....

			location / {
	    		lua_socket_keepalive_timeout 30s;
	    		content_by_lua_file /usr/local/openresty/lualib/short/index.lua;
			}
			location /short {
	    		lua_socket_keepalive_timeout 30s;
	    		content_by_lua_file /usr/local/openresty/lualib/short/shorten.lua;
			}

			...
		}
	5. 配置simple-url-shorten
	
		...
	
		-- 配置Redis数据库信息
		local redis = {}
		redis['host'] = '127.0.0.1'
		redis['port'] = 6379
		redis['password'] = 'passwd'
	
	
		-- 设置起始的短网址，根据长度可以选择需要多少数量的短网址
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
		
		-- 短网址前缀
		local prefix = ''
		
		-- 短网址后缀
		local suffix = ''
	
		-- 短网址的域名
		local domain = 'http://192.168.56.201/'
	
		-- 接受网址缩短的白名单和黑名单，白名单优先级高于黑名单；
		-- 黑名单中默认包含短网址的域名
		local white_host = {}
		local black_host = {domain}
	
		......


	5. 启动nginx服务


## 使用方法 ##

想要对网址

	https://www.google.com/search?newwindow=1&biw=1600&bih=753&q=simple+url+shorten&oq=simple+url+shorten&gs_l=serp.3..0i19l5j0i30i19j0i5i30i19l4.17382489.17389081.0.17389560.18.18.0.0.0.0.418.2756.0j5j3j2j1.11.0.msedr...0...1c.1.60.serp..7.11.2753.th4LFd5J5uU

进行网址缩短，只需进行GET方式请求即可：

	Request:
	http://XXX.com/short?url=https%3A%2f%2fwww.google.com%2fsearch%3Fnewwindow%3D1%26biw%3D1600%26bih%3D753%26q%3Dsimple%2burl%2bshorten%26oq%3Dsimple%2burl%2bshorten%26gs_l%3Dserp.3..0i19l5j0i30i19j0i5i30i19l4.17382489.17389081.0.17389560.18.18.0.0.0.0.418.2756.0j5j3j2j1.11.0.msedr...0...1c.1.60.serp..7.11.2753.th4LFd5J5uU

	Response:
	{"status":1,"shorturl":"http://XXX.com/Rqo3F"}

访问过程：
	Request：
	http://XXX.com/Rqo3F
	
	Response:

	HTTP/1.1 302 Moved Temporarily
	Server: openresty
	Date: Tue, 23 Dec 2014 06:57:47 GMT
	Content-Type: text/html
	Content-Length: 154
	Connection: keep-alive
	Location: http://www.baidu.com/index.php?xxx=234
	
	<html>
	<head><title>302 Found</title></head>
	<body bgcolor="white">
	<center><h1>302 Found</h1></center>
	<hr><center>nginx</center>
	</body>
	</html>


## 注意事项 ##
1. host白名单优先级高于黑名单，设置了白名单将只能对白名单的host网址进行网址缩短



	