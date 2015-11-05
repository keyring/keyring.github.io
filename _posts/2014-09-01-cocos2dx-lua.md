---
data: 2014-9-1
layout: post
title: cocos2dx-3.x 导入lua扩展库
categories: lua
tags: lua note
---

使用cocos2dx-lua做开发，免不了需要利用额外的lua扩展库。lua 扩展库一般由 c/c++ 写成，其接口有两种方式生成，一种是手写luaL_register(lua5.1),另一种是利用 tolua++ 工具。这里讨论的是前者，即如何把已经写好的库导入到cocos2dx项目中使用。项目采用的是 cocos2dx-3.x 版本，涉及到的目录文件请对号入座。


-----------------------
##准备所需的库

首先我们要知道，cocos2dx 已经为我们提供不少的扩展库了，在 `cocos2d-x/external/lua` 目录下，我们可以看到已经有诸如 **cjson**,**luasocket**,**filesysytem(lfs)** 等常用库。如果我们要添加其他的库，也是添加在这里的。

我们以添加云风的sproto库来做示例。

首先介绍一下sproto库，该库是云风精心构思后对 Google protobuf 协议的一个精简，更适用于游戏开发。详情请参阅[文档](https://github.com/cloudwu/sproto/blob/master/README.md)

~~但是云风的这个库只支持lua5.2+的版本，而cocos2dx使用的是lua5.1，所以要使用的话，可以试试我的修改版。我所做的修改仅仅在lua层，下层的c核心与原版一致。所做的修改只是用 **bitop** 库来替换lua5.2内置的**bit**库（5.1木有）。~~

首先请下载 [sproto](https://github.com/cloudwu/sproto)。需要的文件为 `sproto.h`,`sproto.c`,`lsproto.c`,`sprotoparser.lua`。

然后我们还需要下载其利用到的相关库 **lpeg**。

文件准备就绪后就是导入到 cocos2dx 中。

---------------------
##导入


在 `cocos2d-x/external/lua` 目录下新建两个文件夹 **sproto**,**lpeg**。然后将各自的文件放入其中，为了符合cocos2dx的规范，需要在**sproto**中建立一个 `lsproto.h` 文件，内容如下。其内容只是为了方便导入，没什么具体意义。

```c
    #ifndef __LUA_SPROTO_H_
    #define __LUA_SPROTO_H_

    #include "lauxlib.h"

    LUALIB_API int luaopen_sproto_core(lua_State *L);

    #endif
```


然后就是修改一些文件，来真正的导入了。

在`cocos2d-x/cocos/scripting/lua-bindings/manual`目录下，搜索 `lua_extensions.c` 文件。在头部包含所需文件。

    #include "lpeg/lptypes.h"
    #include "lpeg/lpcap.h"
    #include "lpeg/lpcode.h"
    #include "lpeg/lpprint.h"
    #include "lpeg/lptree.h"
    #include "lpeg/lpvm.h"
    #include "sproto/lsproto.h"



在 `luax_exts`内，加入下列几行。

        {"lpeg", luaopen_lpeg},
        {"sproto.core", luaopen_sproto_core},

然后。。。。就没有然后了。。。。

----------------------
##Android支持


上述工作完成后，是可以在ios和mac下编译运行成功的。但Android还要多做点事情。


在`cocos2d-x/cocos/scripting/lua-bindings/`目录下，找到 **Android.mk** 文件，在那一长串加载c文件后面，依葫芦画瓢，加入我们需要的c文件，

          ../../../external/lua/lpeg/lpcap.c \
          ../../../external/lua/lpeg/lpcode.c \
          ../../../external/lua/lpeg/lpprint.c \
          ../../../external/lua/lpeg/lptree.c \
          ../../../external/lua/lpeg/lpvm.c \
          ../../../external/lua/sproto/lsproto.c \
          ../../../external/lua/sproto/sproto.c \

然后。。。是真的没有然后了。。。

---------------------
##总结

总得来说还是很简单的，只需三步：

* 文件放到**`cocos2d-x/external/lua`**目录下
* 修改**`lua_extensions.c`**，包含相关文件
* 修改**`Android.mk`**做Android支持

