---
data: 2014-8-15
layout: post
title: LuaSocket 初探
categories: lua
tags: lua note
---

**LuaSocket** 是一个 Lua 网络扩展库，它由两部分组成：一个用C写的核心和一些Lua模块，前者提供TCP和UDP传输层支持，后者为上层应用提供网络处理的功能接口。


----------------------------------------
##下载安装
------------------
通过搜索引擎得到的结果是作者的[官方网站](http://w3.impa.br/~diego/software/luasocket/)，上面提供的最新版本为[2.0.2](http://files.luaforge.net/releases/luasocket/luasocket)。而实际上，作者早已把项目搬上了[他的Github](https://github.com/diegonehab/luasocket),当前最新版为[3.0-rc1](https://github.com/diegonehab/luasocket/releases)，支持lua5.1和lua5.2。

下载下来的当然是源码包，支持macosx、linux、win32和mingw四种平台编译。在makefile文件中可以选择平台。打开makefile文件，可以看见下面的语句：

    PLAT?= linux
    PLATS= macosx linux win32 mingw

可以看见，默认是linux编译，改成你所需的平台，保存。然后编译安装：

    make && make install

如果出现权限问题，记得加上**sudo**。

------------------------------------
## LuaSocket 小试
------------------------

使用LuaSocket与使用其他Lua库方式一样，require 加载即可。

**_1、版本检测_**

    local socket = require("socket")
    print(socket._VERSION)

**_2、socket.http_**

LuaSocket支持多种协议，HTTP肯定不在话下。使用模块内置http访问度娘

    local http = require("socket.http")
    local response = http.request("http://www.baidu.com/")
    print(response)

**_3、socket client_**

下面是一个简易的客户端，接收用户的输入，发送至服务器，然后接收服务器的返回数据并打印出来。

    local socket = require("socket")
    local host = "127.0.0.1"
    local port = 11111
    local sock = assert(socket.connect(host, port))
    sock:settimeout(0)

    print("Press enter after input something:")

    while true do
        input = io.read()
        if #input > 0 then
            assert(sock:send(input .. "\n"))
        end
        local recvt, sendt, status = socket.select({sock}, nil, 1)
        while #recvt > 0 do
            local response, receive_status = sock:receive()
			if receive_status ~= "closed" then
				if response then
					print("-------------")
					print(response)
					recvt, sendt, status = socket.select({sock}, nil, 1)
				end
			else
				break
			end
		end
	end

> 服务器端的代码可以随意，lua，Python，GO都可以，测试的时候只需监听端口，并返回数据即可。但需要注意几点：

* `send`函数发送的是string，最后的换行符`\n`不是必须的
* `receive`函数默认是接收一行数据即返回，判断条件为接收的字符串中的`\n`，如果找不到会报 **timeout** 的错误
* `receive`的返回状态码是字符串形式的，错误状态只有 **closed** 和 **timeout**

---------------------
## 更多参考
---------------
* [LuaSocket的Github仓库](https://github.com/diegonehab/luasocket)
* [官方参考手册](http://w3.impa.br/~diego/software/luasocket/reference.html)

------------------
## 题外话
-------------------------
* cocos2dx-3.x版本已经将LuaSocket放入了扩展库中，采用的版本也是3.0-rc1，但至今还没有示例，也未做集成封装。
* quick-cocos2d-x 到是做了封装，所以如果要在自己的项目中集成封装LuaSocket，可以参考之。[请看这](http://zengrong.net/post/1980.htm)