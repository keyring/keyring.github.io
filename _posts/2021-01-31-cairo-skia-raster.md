---
data: 2021-1-31
layout: post
title: Cairo 和 Skia 的raster绘制
categories: Graphics
tags: note
---

Cairo 和 Skia 算是目前 2D 开源绘图库的代表。他们现在的架构都是前端API收集绘图指令，根据配置调用不同的后端 做真正的绘制。在硬件加速的大环境下，我这几天好奇他们内部软光栅是怎么实现的，遂下载源码跟了一下，跟的过程中顺便学到了2D绘图的抽象表达。


两者对 draw 的抽象差不多，分成 绘制对象（drawline/lineto ）、绘制行为（fill/strke)。这些也是直接提供给用户的 API，比较直观。而在内部，对于绘制对象，都转成了 path 来表达（cairo-path / SkPath）。然后在需要的时候根据不同的backend，将path转义为该后端接受的 图元。

在内存中，都有个绘制容器（cairo-surface / SkCanvas）的东西来承载用户提交的绘图指令，然后交给不同的backend处理。比如，针对软光栅后端，cairo这边是 `cairo-image-surface`，skia这边叫 `SkBitmapDevice`。

在软光栅后端里，对于真正的光栅化实现，cairo其实自己没有处理，而是交给了 **pixman** 这个像素处理的库。在 cairo-image-surface 里可以看到很多直接使用pixman的函数。而在 pixman 里，也有抽象一些 box，edge，rectangle的概念，但最重要的就是 **pixman-edge**，这里面介绍了怎么把线条变成像素（光栅化）。

skia对于软光栅化是在 `SkDraw` 里实现的，统一 drawpath，然后 path 转 `SkEdge`，然后使用 `SkScan-Path` 的 walk_edges，遍历所有edge，使用扫描线算法，将edge离散出来的 point 集合，通过 `SkBlitter` 里面不同的 blit 函数最终转成像素值。


以上就是大致思路，记录一下，方便以后有需要查阅时能快速回忆起来。

PS: cairo是用纯C写的，为了一些抽象和泛型，函数指针用的飞起，看的脑壳疼。相较而言，skia就好太多了。

PPS：我还是不确定他们到底用了 breseham 算法没有。