---
data: 2017-7-21
layout: post
title: VAO 与 VBO 的前世今生
categories: Graphics
tags: note opengles
---

在现代OpenGL（3.0+）的体系里，VAO和VBO已经是个很基本的概念了，是学习GL必须要理解的一个点。昨天，组内的同学在学习[Learn OpenGL](https://learnopengl.com/)的时候，就被这两个概念给拦住了。当然，具体遇到的问题倒不是理解障碍，实质是不清楚这几个概念的**本质**。

我想了一下，空讲概念确实太虚，尤其是OpenGL这种带有历史尘埃的玩意。GL是一个工业上的标准，历史悠久，那么在设计上肯定是推陈出新，每一个新推出的特性概念都是为了解决实际使用中的问题，VAO，VBO也不例外。

-----------------------------------------------------------

### 数据传输与优化

OpenGL作为图形API，制定的是绘图标准，采用的是CS模式。它将自己看作Server端，接收Client端传过来的数据，然后开启流水线，按需绘制出最终结果。所以，我们遇到的第一个阶段就是**数据传输**。

现在假设我们在client端（简单理解成CPU端）内存里定义了三个顶点数据，如何传输至GPU呢？如何高效大量地传输呢？如何高效大量灵活地传输呢？下述几种技术的出现本质就是为了解决这个问题。

```c
    GLfloat vertices[] = {
        0.0f, 0.0f,
        1.0f, 0.0f, 
        0.0f, 1.0f
    }
```

-------------------------------------
#### glVertex*

最简单的传输就是一个个传过去，在glBegin、glEnd（已废弃）之间通过 `glVertex*`逐个传输，每一次调用都会和GPU通讯一次。这种方式概念清晰，做法简洁粗暴，而缺点也明显，每一次绘制，所有顶点数据依次传输，效率瓶颈明显。

```c
    // 每一次绘制都需要传输三次
    glBegin(GL_TRIANGLES);
        glVertex(0.0f, 0.0f);
        glVertex(1.0f, 0.0f);
        glVertex(0.0f, 1.0f);
    glEnd();
```

-----------------------------------
#### Display List

使用glVertex的方式传输数据，数据量膨胀，那么传输效率会迅速降低。早期图形需求简单，每一次绘制传输的数据，多数情况下是完全相同的。那能不能让每一个数据只传一次呢？

`Display List（显示列表）`应运而生。

在glNewList、glEndList（已废弃）之间，将顶点传输过程包裹了起来，意味着它收集好顶点，**统一传输给GPU，并保存在GPU**上，这样在重复绘制的时候可以直接从GPU端取数据，不再重新传输，对传输效率的提升是极大的。

显示列表的局限性也很明显：**没法在绘制时修改顶点数据**，如果要修改顶点数据，只有在CPU端修改再重新传输一份。极端情况下，如果场景顶点数据每帧需要变化，显示列表就完全退化成了 glVertex 模式。

```c
    // 只在初始化的时候传输三次
    GLuint listName = glGenLists (1);
    glNewList (listName, GL_COMPILE);
        glBegin (GL_TRIANGLES);
            glVertex2f (0.0, 0.0);
            glVertex2f (1.0, 0.0);
            glVertex2f (0.0, 1.0);
        glEnd ();
    glEndList ();

    ...

    // 绘制（不传输数据）
    glCallList(listName);     
```

-------------------------------------------------
#### Vertex Array

针对灵活多变的顶点变化需求，VA（顶点数组）加入到了规范里。它**每一次绘制，将收集的顶点通过一次API调用传输给GPU**，俗称打包数据传输。

VA与上述显示列表区别在于，它收集的顶点保存在CPU端，每次绘制都需要重新传一次数据，所以绘制速度上面慢于显示列表。注意：顶点数组是GL内置的，开发者只能选择启用与否。

```c
    // 每次绘制都将 vertices 传输一次
    GLfloat vertices[] = {
        0.0f, 0.0f,
        1.0f, 0.0f, 
        0.0f, 1.0f
    }
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2,GL_FLOAT,0,vertices);
    glDrawArray(GL_TRIANGLES, 0, 3);   
```

-----------------------------------------
#### VBO (Vertex Buffer Object)

VBO出现之前，做OpenGL优化，提高顶点绘制效率的办法一般就两种：

- 显示列表：把常规的绘制代码放置一个显示列表中（通常在初始化阶段完成，顶点数据还是需要一个个传输的），渲染时直接使用这个显示列表。优化点：减少数据传输次数
- 顶点数组：把顶点以及顶点属性数据打包成单个数组，渲染时直接传输该数组。优化点：减少了函数调用次数（弃用glVertex）

VBO的目标就是鱼与熊掌兼得，想将**显示列表的特性（绘制时不传输数据，快）和顶点数组的特性（数据打包传输，修改灵活）**结合起来。

当然最终效果差强人意，效率介于两者之间，拥有良好的数据修改弹性。在渲染阶段，我们可以把该帧到达流水线的顶点数据映射回client端修改（vertex mapping），然后再提交回流水线（vertex unmapping），意味着顶点数据只在VBO里有一份；或者可以用 glBufferData(全部数据)\glBufferSubData(部分数据) 提交更改了的顶点数据，意味着顶点数据在client端和VBO里都有一份。

VBO本质上是一块服务端buffer（缓存），对应着client端的某份数据，在数据传输给VBO之后，client端的数据是可以删除的。系统会根据用户设置的 `target` 和 `usage` 来决定VBO最适合的存放位置（系统内存/AGP/显存）。*当然，GL规范是一回事，显卡厂商的驱动实现又是另一回事了*。

在初始化阶段，VBO是不知道它所存储的是什么数据，而是在渲染阶段（精确说是 glVertexAttribPointer 函数）才确定数据作用类型（顶点位置、float类型、从偏移量0处开始采集数据、2个float算一个采集步长等等）。到真正绘制（glDrawArray/glDrawElement）的时候才从VBO里读取需要的数据进入渲染流水线。

```c
    // 初始化
    GLfloat vertices[] = {
        0.0f, 0.0f,
        1.0f, 0.0f, 
        0.0f, 1.0f
    }

    GLuint vbo;
    glGenBuffer(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STREAM_DRAW);

    ...

    // 绘制
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2, (void*)0);
    glDrawArray(GL_TRIANGLES, 0, 3);

    ...

```

---------------------------------
#### VAO (Vertex Array Object)

重看一遍上面的渲染阶段代码，如果我有两份不同的绘制代码，那就需要频繁的重复 `glBindBuffer()-glEnableVertexAttribArray()-glVertexAttribPointer-glDrawArray()`一套流程，那么本着偷懒的原则，优化方案来了——把这些绘制需要的信息状态在初始化的时候就完整记录下来，真正绘制时只需简单切换一下状态记录。

这就是 VAO 诞生的理由。

VAO 全称 `Vertex Array Object`，翻译过来叫顶点数组对象，但和Vertex Array（顶点数组）毫无联系！

VAO不是 buffer-object，所以不作数据存储；与**顶点的绘制**息息相关，即是说与VBO强相关。如上，VAO本质上是state-object（状态对象）,记录的是一次绘制所需要的信息，包括数据在哪，数据格式之类的信息。如果抽象成数据结构，VAO 的数据结构如下：

```c
    struct VertexAttribute  
    {  
        bool bIsEnabled = GL_FALSE;  
        int iSize = 4; //This is the number of elements in this attribute, 1-4.  
        unsigned int iStride = 0;  
        VertexAttribType eType = GL_FLOAT;  
        bool bIsNormalized = GL_FALSE;  
        bool bIsIntegral = GL_FALSE;  
        void * pBufferObjectOffset = 0;  
        BufferObject * pBufferObj = 0;  
    };  
    
    struct VertexArrayObject  
    {  
        BufferObject *pElementArrayBufferObject = NULL;  
        VertexAttribute attributes[GL_MAX_VERTEX_ATTRIB];  
    }  

```

从这个数据结构可以看出，VAO里面存了**一个EBO的指针**以及**一个顶点属性数组**，意味着上述一串操作的状态可以完全存储于VAO里面，而真正的数据依然在VBO里面。下面举一个示例代码：

```c
    // 初始化
    unsigned int VAO;
    glGenVertexArrays(1, &VAO);  
    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0); 

    ...

    // 绘制
    glBindVertexArray(VAO);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0)
    glBindVertexArray(0);
```

对比不使用VAO的代码可以发现，我们把原先放在**绘制**阶段的 `glEnableVertexAttribArray()-glVertexAttribPointer()`移动到了初始化里面，而在真正绘制的时候，只是简单的绑定了一个VAO（glBindVertexArray(VAO)）就开始绘制了。这样的话，如果要绘制另一个内容，只需绑定另一个VAO就可以了。

所以，你应该看出来，**VAO是用来简化绘制代码**的。

--------------------------------------------------------

### 后记

通过追本溯源，我们可以发现，现代GL里常用的VAO/VBO实质是为了解决**传输效率**而做的优化手段。VBO是为了均衡数据的传输效率与灵活修改性；VAO的本质是储存绘制状态，简化绘制代码。

回到最初，组内的同学在看到下方Learn OpenGL的示例代码时，提出了一个问题：

```c
    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    float vertices[] = {
         0.5f,  0.5f, 0.0f,  // top right
         0.5f, -0.5f, 0.0f,  // bottom right
        -0.5f, -0.5f, 0.0f,  // bottom left
        -0.5f,  0.5f, 0.0f   // top left 
    };
    unsigned int indices[] = {  // note that we start from 0!
        0, 1, 3,  // first Triangle
        1, 2, 3   // second Triangle
    };
    unsigned int VBO, VAO, EBO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);
    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);

    // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
    glBindBuffer(GL_ARRAY_BUFFER, 0); 

    // remember: do NOT unbind the EBO while a VAO is active as the bound element buffer object IS stored in the VAO; keep the EBO bound.
    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    glBindVertexArray(0); 

```

**为什么在VAO里面可以解绑VBO，却不能解绑EBO呢？**

```c
    // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
    glBindBuffer(GL_ARRAY_BUFFER, 0); 

    // remember: do NOT unbind the EBO while a VAO is active as the bound element buffer object IS stored in the VAO; keep the EBO bound.
    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
```

作者用注释解释了原因，懂则懂之，不懂请结合前述**VAO的数据结构**，相信你能豁然开朗。

----------------------------------------------

### 参考

- [AB是一家?VAO与VBO](http://www.zwqxin.com/archives/opengl/vao-and-vbo-stuff.html)
- [学一学，VBO](http://www.zwqxin.com/archives/opengl/learn-vbo.html)
- [Vertex Specification](https://www.khronos.org/opengl/wiki/Vertex_Specification)
- [Hello Triangle](https://learnopengl.com/#!Getting-started/Hello-Triangle)
