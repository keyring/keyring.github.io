---
data: 2016-04-18
layout: post
title: OpenGL ES Notes
categories: OpenGLES
tags: note
---

## GLES API

- 所有OpenGLES2.0实现必须至少支持**8**个 vertex attribute。可用 `glGetIntegery(GL_MAX_VERTEX_ATTRIBS, &maxVertexAttribs)` 查询实际数目。
- constant vertex attribute 在一个图元的所有顶点上都是相同的，所以只需要一份。通常使用 `glVertexAttrib*f*` 进行传值。
- vertex array 用于逐顶点指定属性数据，缓存在host的地址空间（client空间）。使用 `glVertexAttribPointer`指定数据读取位置与大小。（本质上是个存于CPU主存的指针）此处可以做的优化有二，一是根据需要合理组织顶点属性数据的结构；而是根据需要尽可能降低数据格式的大小。
- host这边的数据要与shader里面的attribute变量绑定，需使用`glBindAttribLocation(GLuint program, GLuint index, const GLchar *name)`，其中，program指具体某个program对象的名字，index就是`glVertexAttrib`和`glVertexAttribPointer`的第一个参数，name就是shader里面用attribute声明的变量名。
- `glGetAttribLocation(GLuint program, const GLchar *name)`可以通过name查找与之绑定的index。
- 顶点数据起于host内存空间（CPU），每次绘制（glDrawArrays/glDrawElements）时，都会将数据复制到图形内存空间（GPU）。显然，这样会浪费大量的计算力在数据传输上，浪费内存带宽，浪费电。所以，把部分数据缓存在GPU端（显存），可以提高性能，显著降低带宽占用和耗电量。**Vertex Buffer Object(VBO)**应运而生。
- OpenGLES支持两种VBO，`array buffer objects`和`element array buffer objects`，前者用**GL_ARRAY_BUFFER**标识，缓存顶点数据，后者用**GL_ELEMENT_ARRAY_BUFFER**标识，缓存图元的索引。
- VBO三件套：创建-绑定-传数据，`glGenBuffers`-`glBindBuffer`-`glBufferData(glBufferSubData)`
- 对于**静态**几何体，数据传递给GPU之后，host端的数据可以删除释放掉，节省内存。
- OpenGLES三图元：triangle，line，point。相关绘制模式：**GL_POINTS GL_LINES GL_LINE_STRIP GL_LINE_LOOP GL_TRIANGLES GL_TRIANGLE_STRIP GL_TRIANGLE_FAN**。
- OpenGLES图元绘制两方法：**glDrawArrays** 和 **glDrawElements**。
- 别废话了，能用VBO就赶紧上，能用`glDrawElements`就别用`glDrawArrays`。
- **glPixelStorei**设置的打包/解包对齐参数是全局状态，不只是作用某个单独的纹理对象。
- 由于GPU的并行架构，shader中的条件判断最好是**常量表达式**，以防出现结果不一致。
- VS中能利用的uniform变量具有数目限制（>=128，具体限制看实现）。各类常量均会占用计数。有时相同的字面常量会计数多次（比如，多次使用`1.0`，会计数多次，而不是一次）。所以shader中最好将字面常量转为`#define`或`const`形式。
- Texture是一个**Object**，而不仅是一块图像数据。它更像一个容器（结构体），里面包含了用于渲染所需的数据，主要有`图像数据`、`filter模式`、`wrap模式`。


---------------------------------------------

## GLSL

- **uniform**：host传递给着色器的只读值，存储于常量空间，被顶点着色器和片段着色器共享。
- **attribute**：host传递的顶点属性，也是只读值，且只能用于顶点着色器，比如顶点位置、颜色和贴图坐标之类的属性值。
- **varying**：VS的输出，FS的输入；用于VS向FS传递数据，须在两个shader中有一样的声明。
- VS内置变量：`gl_Position`,`gl_PointSize`,`gl_FrontFacing`。
- **gl_Position**：输出顶点的裁剪空间坐标，用于裁剪空间转屏幕空间。是`highp`精度的浮点数。
- **gl_PointSize**：指定point sprite的像素大小。是`mediump`精度的浮点数。
- **glFrontFacing**：这个变量不会在VS里直接赋值。是根据VS生成的position值和渲染的图元类型自动决定的。是个boolean值。
- 默认`float`和`int`的精度都是**highp**。一般在VS里都是用默认的高精度。
- `for`循环里面的索引，不能在循环体里面变化，只能在for()里面。而`while`和`do-while`虽然属于规范，但不一定实现了。


--------------------------------------------

## Optimization

- 对于高级光照与阴影，尽可能将逐像素（per-pixel）计算换成逐顶点（per-vertex）计算，或者直接使用光照贴图；同理，高光、cube light还有反射映射都可以预烘培在原始纹理中。阴影也一样。
- 有些无法完全展示的大场景，最好细分一下三角形，虽然总的三角形增加了，但GPU可以有效的裁剪掉不需要绘制的三角形，可以提升性能。
- 避免不必要的`eglMakeCurrent`调用
- 移动端pixel shader稀缺，实现一个**多级着色(level-of-shading)**显得很有必要；原理和LOD类似，根据离摄像机距离的不同选用不同复杂度的shader进行着色。
- **降低GL状态切换**：1）ES API会分发给驱动在内核态中的那部分，再转发给GPU；所以不要滥用API；2）纹理切换耗性能，所以对于渲染调用，最好先按`texture`排序，再按`state vector`排序。
- **降低Draw call**：进行一次draw call需要太多的前置操作，比如清空上个状态、处理当前绑定的VAO、从主存复制数据到GPU等等。所以，谨记 **没有消耗就没有损失**。
- **分辨率缩放**：利用FBO将场景渲染成小分辨率，然后在post-process阶段进行缩放到设备真实分辨率。UI和HUD可以直接以设备分辨率进行渲染。
- 对于常用的**模糊特效**，一般用的高斯算法，优化点有俩：1）将偏移点的计算从pixel shader移到vertex shader或者CPU中去；2）从低mipmap采样，应用模糊之后再缩放回去。
- 利用纹理fetch的高效性，可以设计精巧的算法来代替直接的算数运算。（这个技巧性太高，需要静心设计数据放置在纹理中，一次纹理采样等于多次普通计算）
- 背面裁剪，特别是不透明物体，非平面（点、线）对象
- 使用LOD，一般在网格的多边形上使用较多，其实在shader effect上使用也是效果明显
- 使用VBO代替VAO，因为VAO会在每一个draw call时复制顶点数据，浪费带宽影响效率
- 下面列出会引起**状态改变**的API，记得不要滥用：



![](/image/gles_01.png)

![](/image/gles_02.png)

![](/image/gles_03.png)

- 对drawcall排序可以有效降低状态切换的次数。可以遵循下面的排序规则：

```
1、按 render target 排序：RT之间的切换消耗太高，一般不要做这种事（调用 `glBindFramebuffer、glFramebuffer*）。如果一个对象需要使用多种program在多个RT上绘制，那顺序肯定是先在program之间切换，在切换RT（逐个RT绘制过去）；
2、按 program 排序：同一个frame buffer里面，尽量降低program的切换。假设一个场景三个物体，两个使用相同的FS，肯定是这两个物体挨着渲染较好；
3、其他：比如纹理切换，顶点数据变化之类的。




-----------------------------------

## Think




----------------------------------------

## Refrence

- OpenGLES 2.0 Programming Guide
- Qualcomm Adreno OpenGL ES Developer Guide
- ARM Mali GPU OpenGL ES Optimization Guide