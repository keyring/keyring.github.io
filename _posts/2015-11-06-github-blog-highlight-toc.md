---
data: 2015-11-06
layout: post
title: Github 博客代码高亮与目录生成
categories: others
tags: web note
---

**`本篇内容已失效`**

这个博客是当时Github Jekyll博客模版刚出来的时候搭建的，忘了当时用的谁的模版。整个版面还是比较清爽的，只是少了代码的语法高亮。至于目录生成，一直都是手写标记。前几天重温文章的时候发现没有高亮和浮动的目录还是比较不方便，花了点时间给弄上。

-------------------------

## 代码高亮

在markdown的标准语法里面，文字前输入4个空格就会生成代码块。所以网上用于代码高亮的玩意都是在对这个代码块里面进行处理。翻了一下Github Jekyll的指南，最终用的[highlight.js](https://highlightjs.org)。使用简单，只需在需要用到高亮的html文件头里，加上引用即可

```html
<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/8.4/styles/monokai_sublime.min.css">
<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/8.4/highlight.min.js"></script>
<script type="text/javascript"> hljs.initHighlightingOnLoad(); </script>
```

我这里直接用的cdn的远程代码，懒的下载了，至于主题，我使用的是`monokai_sublime`，更多的主题可以去其官网查看，然后换上相应的名字即可。当然，上面的代码最好还是放在你的post模版html里面。这样Jekyll在解析md文件生成最终的html时会自动加上这段代码。


`highlight.js`会自动检测代码的语言，然后进行高亮，然而，看起来并不是那么智能。而且，即使指定了语言，却貌似并没有什么卵用。或许是我没设置对吧，但也无所谓了。

-----------------------

## 目录生成

目录生成不是标准markdown语法，所以当前各类markdown解析库有的支持，有的不支持，而且写法也不固定。鉴于我仅在Github Jekyll上需要这个玩意，肯定以Jekyll的规范来做。Jekyll支持的多个markdown解析器，我选用了`redcarpet`，然后在`_config.yml`里做了设置

```sh
markdown: redcarpet
redcarpet:
extensions: ["fenced_code_blocks", "autolink", "tables", "strikethrough", "with_toc_data"]
```

最后那个`with_toc_data`就是目录生成的关键。


因为标准语法里没有，所以就只能自己动手了。网上一番搜索，大致明白了点原理。我所需要的自动目录生成，无非是动态的解析markdown里的字段，动态生成一个`div`，然后将这个`div`挂在某个位置上。比如，所谓的一段js代码生成目录

```html
<script type="text/javascript">
$(document).ready(function(){
$("h2,h3,h4,h5,h6").each(function(i,item){
var tag = $(item).get(0).localName;
$(item).attr("id","wow"+i);
$("#toc").append('<a class="new'+tag+'" href="#wow'+i+'">'+$(this).text()+'</a></br>');
$(".newh2").css("margin-left",0);
$(".newh3").css("margin-left",20);
$(".newh4").css("margin-left",40);
$(".newh5").css("margin-left",60);
$(".newh6").css("margin-left",80);
});
});
</script>
```

这段代码就是遍历从markdown生成的html文件，找出`h2,h3,h4,h5,h6`，然后逐个添加至名为`toc`的div里构成列表。最后只需将这个`toc`的div放到你想放的位置即可

```html
<div id="toc"></div>
```

顺着这个思路，将上述js代码独立成文件，再加上一些细节，就可以做出更多的逻辑，更灵活的配置。最终我使用的是Github官方推荐的[jekyll-table-of-contents](https://github.com/ghiculescu/jekyll-table-of-contents)。为了让目录能够浮动，我加了一点代码。本质就是动态的调整`toc`这个div的位置。

```javascript
jQuery.easing['jswing'] = jQuery.easing['swing'];
jQuery.extend( jQuery.easing,
{
def: 'easeOutQuad',
swing: function (x, t, b, c, d) {
//alert(jQuery.easing.default);
return jQuery.easing[jQuery.easing.def](x, t, b, c, d);
},
easeOutQuad: function (x, t, b, c, d) {
return -c *(t/=d)*(t-2) + b;
},
easeOutQuint: function (x, t, b, c, d) {
return c*((t=t/d-1)*t*t*t*t + 1) + b;
}
});

$(window).resize(function () {
var w = $(window).width(),
c = 600,
a = $('#toc').width();
d = 40;
$('#toc').css('right',
(w - c) / 2 - (a + d));
});
$(window).resize();

toplest=$('article').offset().top;
animationSpeed=1500;
animationEasing='easeOutQuint';
$(window).scroll(function(){

var scrollAmount=$(document).scrollTop();
if (scrollAmount < toplest)
scrollAmount = 0;
else
scrollAmount = scrollAmount-50;

var newPosition=toplest+scrollAmount;
$('#toc').stop().animate({top: newPosition}, animationSpeed, animationEasing);
$('#toc').css("top",newPosition)
        });
```

当然了，这段代码基本没做样式美化，看起来是丑了点，但要想美化一个div，网上有大把的代码，这里就不再多说。附上我的弱鸡css美化

```css
#toc{
font-size:1em;
font-family:"Electrolize",sans-serif;
float:right;
/*margin-right:-17em;*/
/*right:0em;*/
width:11em;
text-align:left;
color:#fff;
cursor:pointer;
background:#fff;
border:0;
outline:0;
box-shadow:0 12px 24px rgba(0,0,0,0.35);
position:absolute;
padding:1em .5em;
/*-webkit-transform: translateZ(0);*/

}
#toc ul{-webkit-padding-start: 0px;padding:0px;}
#toc a{display:block;padding:.2em .5em;color:#000000;}
#toc a:hover{background-color:#ff0000;text-decoration:none;color:#f9f9f9;-webkit-transition:color .2s linear;}
#toc li i {
display: inline-block;
width: 1em;
}
```

最终的效果就是你看见的本文所显示的这样了。附上博客的[Github](https://github.com/keyring/keyring.github.io)，直接翻代码可能更爽点。

-------------------

## 最后

写这篇博客的目的不单纯是记录一下这件事。而是在捣鼓这个玩意的时候，我发现css的简易性与灵活性，特别喜欢他的纯粹性。顺着css这个思路，只要加上数据绑定，用于原生UI编程也是可以的。

桌面GUI编程这个领域，一直都在探索UI与逻辑分离。QT、XAML、Cocoa应该是走的最远的。但他们都有一个问题，开发时的便利与维护时的便利永远矛盾。