---
data: 2014-10-15 
layout: post
title: Game Dev Log
categories: game
tags: game note
---

  纪录一些在游戏开发过程中的tips，简短不足以文，遂散列于此。

  当然，有些纪录思考的深入了，也会提出来独立成文。


-----------------------------------------

## cocos2dx

----------------------

### 字体设置

  在游戏开发中，有时为了统一各个平台的字体表现，我们会自定义一套字体，一般是包含了常用字型的ttf文件。在cocos2dx 2.x版本中，我们一般使用`LabelTTF`接口进行创建。而在3.x版本中，coco2dx意图使用freetype字体引擎，统一各个平台的字体表现，并提升其自定义性和渲染效率。接口为`Label->createWithTTF`。

  然而，我们自定义的字体文件不可能将所有汉字包含其中，总会出现一些生僻字。毕竟康熙字典里几万字，我们自定义的字体文件里不可能完全容纳。这时候，我们的需求肯定是，当我们的自定义字体中找不某个字符时，可以拿**系统字体**中的这个字符来顶替。（我们期望系统字体能尽可能的包含足够多的字符，如果系统字体中也没有，那就真的没有了。这样的话，玩家的怒火可以让系统和游戏共同承受。。。）。

  截止当前版本（coco2dx 3.7），使用`Label->createWithTTF`这个接口是满足不了我们的需求的。因为这个接口在下层查找字符字型的时候使用freetype的接口`FT_Get_Char_Index`查找，如果没找到，返回**空(nullptr)**。

		auto glyphIndex = FT_Get_Char_Index(_fontRef, theChar);
		if(!glyphIndex)
			break;
  
  所以，要解决这个需求，我们还是要回到2.x的做法，使用系统接口，不使用freetype。在3.x中，我们使用`Label->createWithSystemFont`。这个接口接受一个`fontname`，字符字型查找时会优先使用提供的`fontname`字体。如果系统找不到这个字体或者找不到某个字符字型时，会提供系统默认字体和字符字型。

  系统不一，要求不一。 具体到android和iOS上，传递的`fontname`形式也不一样。

  **iOS：** 首先将自定义的字体文件置于某个资源目录下，比如`fonts/fontname.ttf`；然后使用xcode打开`info.plist`文件，增加一项`Fonts provided by application`，然后将自定义的字体文件目录添加到他的子项下面（可以有多个自定义字体哦）。更详细的图文操作请Google之。然后使用cocos2dx的`createWithSystemFont`接口，传递的`fontname`为**fontname**，看清楚哦，是字体名，不是字体文件名，也不要带tff后缀。

		// ios
		Label->createWithSystemFont(text, fontname, size)

  **Android：** android相对就简单了，只需传递文件地址就行了，这个刚好和iOS反过来了。

		// android
		Label->createWithSystemFont(text, “fonts/fontname.ttf", size)

  所以啊，最好还是在游戏启动时判断系统类型，然后设置一个**全局的字体参数**。

  估计后面的版本中，`createWithTTF`接口会实现这个需求的。现在的cocos2dx为了兼容性，废旧代码删除重构还是不敢大跃进。

--------------------

## Lua

-------------------------

### 字符串过滤
  
  对于字符串我们总是有各种各样的过滤要求来满足神奇的需求。lua的模式匹配和table还是简单强大。

---------------
  - **只允许中英文数字**

```lua
	string.find(text,'[^%w\128-\191\194-\239]+')
```

--------------------

  - **敏感词汇过滤**
  
  这个很有特色的功能基本上各个行业都会做。简单的做法就是，将目标字符串在词库中进行查找比较。如果词库简单，而且过滤条件不那么严格的话，使用lua的table就可以。

  思路也简单，将词库做成table，每一条做键。如果目标字符串也很简单，比如玩家的名字，可以将目标字符串的所有字串找出来，塞入一张table中，然后直接哈希查找字串。注意中英文混搭的字符串需要转为UTF8再操作。
		
```lua
	local text_sub_table = {}
	local length = utf8.len(text)
	for i=1,length do
		for j=i,length do
			text_sub_table[#text_sub_table +1] = utf8.sub(text,i,j)
		end
	end

	for k,v in pairs(text_sub_table) do
		if illega_words_table(v) then
			print("你懂的")
			break
		end
	end
```
  
  