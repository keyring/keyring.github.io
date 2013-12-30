---
data: 2013-12-29
layout: post
title: Simple Ray Tracer(1)
categories: Ray Tracing
tags: 源码 光线追踪
---

最近研究光线追踪，看了一些资料后觉得理论性太强。自己想实现一个光线追踪器却发现无从下手。遂上网搜寻一些现有源码，希望通过对源码的解析来理清光线追踪器。

下面这个简单光线追踪器来自 [`Andrew Kensler`](http://www.cs.utah.edu/~aek/code/card.cpp)，他在 [Hacker News](https://news.ycombinator.com/item?id=6425965) 对自己代码有过一点说明。该 Ray tracer 的完整代码如下：

	#include <stdlib.h>   // card > aek.ppm
	#include <stdio.h>
	#include <math.h>
	typedef int i;
	typedef float f;
	struct v {
	    f x, y, z; v operator+(v r){ return v(x + r.x, y + r.y, z + r.z); }
	    v operator*(f r){ return v(x * r, y * r, z * r); }
	    f operator%(v r){ return x * r.x + y * r.y + z * r.z; }
	    v() {}
	    v operator^(v r){ return v(y * r.z - z * r.y, z * r.x - x * r.z, x * r.y - y * r.x); }
	    v(f a, f b, f c){ x = a; y = b; z = c; }
	    v operator!(){ return*this * (1 / sqrt(*this % *this)); }
	};
	i G[] = {247570, 280596, 280600, 249748, 18578, 18577, 231184, 16, 16}; 
	f R(){ return (f)rand() / RAND_MAX;}
	i T(v o, v d, f &t, v &n){
		t = 1e9; i m = 0; f p = -o.z / d.z;
		if (.01 < p)
			t = p, n = v(0, 0, 1), m = 1;
		for (i k = 19; k--;)
		    for (i j = 9; j--;)
		    	if (G[j] & 1 << k) {
		    	   	v p = o + v(-k, 0, -j - 4);
		    	   	f b = p % d, c = p % p - 1, q = b * b - c;
		    	   	if (q > 0) {
		    	   		f s = -b - sqrt(q);
		    	   			if (s < t && s > .01)
		    	   				t = s, n = !(p + d * t), m = 2;
		    	   	}
		    	}
		return m;
	}
	v S(v o, v d){
		f t; v n; i m = T(o, d, t, n); 
		if (!m)return v(.7,.6, 1) * pow(1 - d.z, 4); 
		v h = o + d * t, l = !(v(9 + R(), 9 + R(), 16) + h * -1), r = d + n * (n % d * -2);
		f b = l % n; 
		if (b < 0 || T(h, l, t, n))
			b = 0; f p = pow(l % r * (b > 0), 99); 
		if (m & 1) {
			h = h * .2; 
			return ((i)(ceil(h.x) + ceil(h.y)) & 1 ? v(3, 1, 1) : v(3, 3, 3)) * (b * .2 + .1);
		}
		return v(p, p, p) + S(h, r) * .5;
	} 
	i main(){
		printf("P6 512 512 255 "); 
		v g = !v(-6, -16, 0), a = !(v(0, 0, 1)^g) * .002, b = !(g ^ a) * .002, c = (a + b) * -256 + g; 
		for (i y = 512; y--;)
			for (i x = 512; x--;) {
				v p(13, 13, 13); 
				for (i r = 64; r--;) {
					v t = a * (R() - .5) * 99 + b * (R() - .5) * 99; 
					p = S(v(17, 16, 8) + t, !(t * -1 + (a * (R() + x) + b * (y + R()) + c) * 16)) * 3.5 + p;
				}
				printf("%c%c%c", (i)p.x, (i)p.y, (i)p.z);
			}
	}

编译后，以命令模式启动，传入的参数可以是 `> card.ppm`。等待几十秒后会生成 `card.ppm` 文件，这个文件就是光线追踪器生成的图像。打开后就是这样的：

![](/image/raytracer_01_01.png)


这个简单的 Ray tracer 其实具备不少的特性：

- 场景里的球体是精心排列的
- 带纹理的地板
- 有渐进度的天空
- 软阴影
- 好像还有景深效果

看完了效果就该分析一下代码了。

##向量类（Vector class）
-----------------------------------------------------------

计算机图形里面最重要的类估计就是 vector类了。它负责描述场景以及各种计算。为了缩短代码长度，这里将 `int` 和 `float` 进行了 `typedef`。当然，除非为了故意缩短代码，一般咱们还是不要这样用为好。

    #include <stdlib.h>   // card > aek.ppm
    #include <stdio.h>
    #include <math.h>

    typedef int i;       // 用 i 代替 int，只为单纯地缩短代码
    typedef float f;     // 用 f 代替 float，也只是为了缩短代码

    // 定义 vector 类 'v'
    struct v{
      f x,y,z;  // vector 的三个 float 变量
      v operator+(v r){return v(x+r.x,y+r.y,z+r.z);} // 加
      v operator*(f r){return v(x*r,y*r,z*r);}       // 乘
      f operator%(v r){return x*r.x+y*r.y+z*r.z;}    // 点乘
      v(){}                                  // 空的构造函数
      v operator^(v r){return v(y*r.z-z*r.y,z*r.x-x*r.z,x*r.y-y*r.x);} // 叉乘
      v(f a,f b,f c){x=a;y=b;z=c;}            // 构造函数
      v operator!(){return *this*(1 /sqrt(*this%*this));} // normalize
    };

## 随机数与场景描述（Random and Scene）
----------------------------------------------------------------------

代码中定义了一个 `R()` 函数来生成[0.0f-1.0f]之间的随机数。随机数用于随机采样，对模糊和软阴影效果非常有用。

`G`数组就是我们的场景描述，里面是一堆球的位置，搭起来后就是最终效果图里面的三个字母。

	// 一系列的球体位置描述构建成整个场景世界。
	// 这些整数事实上是位向量。
	i G[]={247570,280596,280600,249748,18578,18577,231184,16,16};
	
	/*
	
	16                    1    
	16                    1    
	231184   111    111   1    
	18577       1  1   1  1   1
	18578       1  1   1  1  1 
	249748   1111  11111  1 1  
	280600  1   1  1      11   
	280596  1   1  1      1 1  
	247570   1111   111   1  1 
	
	可以看出来这些数字摆成的是 aek 三个字母吧
	*/
	
	// 随机数生成器，返回一个[0-1]的 float 值
	f R(){return(f)rand()/RAND_MAX;}

##追踪器（Tracer）
--------------------------------------------

光线追踪之所以叫这个名字，就是因为需要对光线进行追踪以获得光线与场景物体间的所有相交点。
光线一般用 `起点（Origin o）` 和 `方向（Direction d）`进行描述。相交点表示为 `0=碰天空,1=碰地面, 2=碰球体`。如果碰到了球体，就需要更新 `t（光线与相交点的距离）` 和 `n（衰减50%后的光线）` 。
  
	// 射线[o,v]的相交测试。
	// 有一个相交点则返回 2 (还要返回距离 t 和新光线 n)。
	// 没有相交点且光线向上则返回 0 （射向天空）。
	// 没有相交点且光线向下则返回 1 （射向地面）。
	i T(v o,v d,f& t,v& n){ 
		t=1e9;
		i m=0;
		f p=-o.z/d.z;
		if(.01<p)
			t=p,n=v(0,0,1),m=1;
		
		// 整个场景由 G 数组编码而成，有9行19列
		for(i k=19;k--;)  // 每列
		for(i j=9;j--;)   // 每行
		
			if(G[j]&1<<k){ // 判断第 j 行 k 列上是否有球体
			
				// 判断该球体是否与光线相交
				
				v p=o+v(-k,0,-j-4);
				f b=p%d,c=p%p-1,q=b*b-c;
				
				// 是否相交？
				if(q>0){
					// 是！ 计算摄像机与球体间的距离
					f s=-b-sqrt(q);
				
					if(s<t && s>.01)	// 保存最短距离，同时计算衰减后的光线 n 。  
						t=s, n=!(p+d*t), m=2;
				}
			}
				
		return m;
	}
	

##采样器（Sampler）
---------------------------------------------------------------------
采样器函数`S()`用于返回所给光线的像素值。如果光线与球体相交则会递归计算。如果没有相交则要么返回天空的渐进色，要么返回地面棋盘纹理色。

注意这里计算光线的方向时调用了`R()`函数：用于模拟软阴影。

	// 采样场景，返回所给光线（起点o，方向d）的像素值
	v S(v o,v d){
      f t;
      v n;
    
      // 搜索场景中的一条相交光线
      i m=T(o,d,t,n);

    
      if(!m) // m==0
      // 没有与球体相交，光线向上：产生天空色  
      return v(.7,.6,1)*pow(1-d.z,4);

      //可能与一个球体相交
    
      v h=o+d*t,                    // h 代表相交坐标
      l=!(v(9+R(),9+R(),16)+h*-1),  // l 代表光线的方向，随机偏移量用于软阴影
      r=d+n*(n%d*-2);               // r 代表半向量
 
      // 计算兰伯特系数（lambertian factor）
      f b=l%n;
    
      // 计算光照系数（illumination factor）：lambertian系数大于0或者处于阴影?
      if(b<0||T(h,l,t,n))
         b=0;
   
      // 计算带漫反射和高光的颜色值 p 
      f p=pow(l%r*(b>0),99);
    
      if(m&1){   //m == 1
         h=h*.2; // 没有与球体相交，光线向下：产生地板色
         return((i)(ceil(h.x)+ceil(h.y))&1?v(3,1,1):v(3,3,3))*(b*.2+.1);
      }
   
      //m == 2 与一个球体相交。在球体表面投射一条新光线
      return v(p,p,p)+S(h,r)*.5; // 递归采样。这儿乘0.5表示新光线的颜色衰减50%
	}

##主函数（Main）
-------------------------------------------
主函数里面主要使用了一个简单的图像格式 `PPM`。文件是纯文本的，以 `P6 [WIDTH] [HEIGHT] [MAX_VALUE]`开头，后面跟着每个像素的RGB值。

本文的光线追踪器生成一张 512×512 大小的图像，每像素采样64条光线，最终结果由 `stdout` 输出。

对于每条光线的起点和方向都会使用一小点随机偏移量，这样可以造成景深效果。

	// 主函数，用stdout生成 PPM 图像。
	// 程序使用方法：命令行运行，参数为 > out.ppm
	i main(){
    
		printf("P6 512 512 255 "); // PPM 文件头
		
		// '!' 操作符用于 normalizing 每个向量 
		v g=!v(-6,-16,0),       // 摄像机朝向
		a=!(v(0,0,1)^g)*.002, // 摄像机上方
		b=!(g^a)*.002,        // 摄像机右方，叉乘求出来的
		c=(a+b)*-256+g;       // 这个东西还是去看作者的解释吧 https://news.ycombinator.com/item?id=6425965 
		
		for(i y=512;y--;)    // （图像）每列
		for(i x=512;x--;){   // （图像）每行
		
		// 重用 vector 类，但不是存储XYZ，而是RGB像素颜色
		v p(13,13,13);     // 默认像素颜色近似黑色
		
		// 每个像素投射64条光线，用于模糊（随机采样）和软阴影 
		for(i r=64;r--;){ 
		  
		    // 作用于观察点的偏移量（造成景深效果）
		    v t=a*(R()-.5)*99+b*(R()-.5)*99; // 一点上/下和左/右偏移量
		                                   
		    // 将摄像机焦点设为 v(17,16,8) 然后投射光线 
		    // 累积变量 p 返回的颜色值
		    p=S(v(17,16,8)+t, // 光线起点
		        !(t*-1+(a*(R()+x)+b*(y+R())+c)*16) // 带随机偏移量的光线方向，用于随机采样
		        )*3.5+p; // 不断加 p 来累积颜色
		}
		
		printf("%c%c%c",(i)p.x,(i)p.y,(i)p.z);
		
		}
	}


##总结
---------------------------------
从这份代码来看，一个光线追踪器必需的因素有**向量类（Vector）**，**相交测试（Intersection）**，**追踪器（Tracer）**，**采样器（Sampler）**【当然也可以不要采样器，颜色值的计算放到追踪器里进行】。为了更逼真的效果与更快的速度，如今的 Ray Tracer 引入了诸如蒙特卡洛积分，辐射度，KD树之类高级特性与算法，但其本质与本文的迷你版并无差别。

既然我们知道了麻雀的五脏，那么亲手构造一只雄鹰也绝非不可能。