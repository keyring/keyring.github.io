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







-----------------------------------
## Think