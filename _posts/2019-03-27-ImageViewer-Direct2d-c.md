---
data: 2019-03-27
layout: post
title: C 语言开发 Direct2D
categories: imageviewer
tags: direct2d
---


准备利用巨硬吹嘘了很久的 Direct2D 在Windows下做绘图。开发环境自然是 Windows 10 + Visual Studio 2017 + C语言。

通览了一遍MSDN，不得不说，巨硬的文档越写越好了。下载示例 Demo，编译运行一气呵成，成功的垫脚石已经搭好。撸起袖子，先写个图片浏览器。

很快，第一个坑来了。Direcr2D 相关的示例与文档，全是C++，但我要用C语言开发（为啥非要用C呢，我乐意，我瞎折腾）。好在 D2D 本质算是COM组件，肯定是能对C做兼容的。在 `d2d1.h` 里翻了半天，找到了 `D2D_USE_C_DEFINITIONS` 宏，细细翻阅，喜忧参半。喜得是确实有做C接口兼容，忧的是巨硬貌似没做完。

在 Google 上换着关键字搜索良久，找到[一篇靠谱的回答](https://social.msdn.microsoft.com/Forums/en-US/b557dbb1-79d5-4a2d-b8fc-5dc07ab0637d/is-plain-c-actually-supported-for-direct2d?forum=windowssdk)。原来巨硬在新的 Windows SDK 里删掉了 C 接口（我就记得以前有啊）。


The 14393 version of the Windows SDK did remove the C definitions, but you could target your project to use the 10586 version of the SDK if needed. You can install it through the Visual Studio 2017 installer.

As for whether it is a bug or not, I would imagine not. Using C to program for DirectX related things isn't that popular, and since the C related definitions take up a huge amount of space in the headers, I would imagine that they chose to do this to cut down on work.

Well, anyway, there isn't much difference in the Direct2D headers, between 10586 and 14393. There was ID2D1SvgGlyphStyle, ID2D1Device4, ID2D1DeviceContext4 and ID2D1Factory5. So unless you want/need to use these then just use an older version. If you want to use these, then the only thing I can suggest, after complaining to Microsoft, is to look at the previous versions of the headers and write your own C style definitions. It is still COM so they will still have to be C compatible even if they only provide the C++ definitions.


所以咯，要用C语言写 Direct2D，要么用老版的 SDK（10586，VS2017 Installer 里可以选），要么祈祷哪天巨硬更新又支持了，要么就自己导（比如mingw32就维护了一份）。

我还是老老实实用回旧版SDK吧。

---------------------------------------------------------

图片浏览器基本结构三步走：读取、解码、显示。利用Win32 + D2D + WIC 很快就完成了。

在实现 **显示的图像大小实时跟着窗口大小调整***时遇到个小坑。按常理，这种逻辑只需要监听 `WM_SIZE` 消息即可。可最终发现窗口变大会触发重绘，但缩小（按住鼠标拖动边框）不松开鼠标的情况下不会重绘。这应该是与Windows的窗口无效区域有关，简言之，这种情况下系统不会发送 `WM_PAINT` 消息，也就不会触发重绘。

最后在 `WM_SIZE` 的处理最后手动加上 **RedrawWindow** 或者 **InvalidateRect** 强制重绘。

--------------------------------------------------------------
