---
data: 2020-3-22
layout: post
title: Incredibuild 加速编译 NDK
categories: Android
tags: note
---

直接使用 Android Studio NDK来编译C++实在太慢了。想想用VS搭载 incredibuild 多快乐。同样都是编译CPP，何不用来加速NDK的编译呢。


1. 首先，你需要已经安装好了incredibuild，并且在VS上曾经尝试成功使用过。

2. 找到你的NDK_ROOT指向的路径。使用AS SDK Manager下载的一般在 SDK 目录下（比如AS 3.6在sdk下专门有个 ndk 目录。手动下载的就自己找。下了很多个的就环境变量里指定好。

3. 打开 NDK 路径下的 build/ndk-build.cmd。修改里面的内容。实质就是用 XGConsole（incredibuild） 使用一个 Profile.xml 配置来跑原先的编译脚本。

```
"%PREBUILT_PATH%\bin\make.exe" -f "%NDK_ROOT%\build\core\build-local.mk" SHELL=cmd %***

修改为

XGConsole /COMMAND="%PREBUILT_PATH%\bin\make.exe -f %NDK_ROOT%\build\core\build-local.mk SHELL=cmd %*" /PROFILE=%NDK_ROOT%\Profile.xml
```

4. 然后在 NDK 目录下，新建一个 Profile.xml。其实文件叫啥名，放哪里都可以，只要和上面命令里 /PROFILE= 的路径能对应上就行。Profile.xml里的内容如下，里面最重要的是 clang 那两行。毕竟NDK编译用的这个。

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no" ?>    
<Profile FormatVersion="1">    
    <Tools>    
        <Tool Filename="make" AllowIntercept="true" />    
        <Tool Filename="cl" AllowRemote="true" />    
        <Tool Filename="link" AllowRemote="true" />    
        <Tool Filename="gcc" AllowRemote="true" />    
        <Tool Filename="clang++" AllowRemote="true" />    
        <Tool Filename="clang" AllowRemote="true" />    
        <Tool Filename="gcc-3" AllowRemote="true" />    
        <Tool Filename="arm-linux-androideabi-c++" AllowRemote="true" />  
        <Tool Filename="arm-linux-androideabi-cpp" AllowRemote="true" />  
        <Tool Filename="arm-linux-androideabi-g++" AllowRemote="true" />  
        <Tool Filename="arm-linux-androideabi-gcc" AllowRemote="true" />    
    </Tools>    
</Profile>
```

5. 最后，我们在 AS 工程app里面的 build.gradle 里的 ndkBuild 参数里，-j 200。 200是你想的最大任务数。如果build里面没使用 task 这种方式，可以在 externalNativeBuild 加。

```gradle
externalNativeBuild {
    ndkBuild {
            ……

            arguments '-j 200'  // 200指最大的任务数

            ……
        }
}
```

6. 开始启动编译吧。