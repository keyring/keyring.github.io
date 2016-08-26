---
data: 2016-02-09
layout: post
title: UE4中常用的库
categories: UE4
tags: note
---

UE4里面有大量游戏开发相关的C++库，但在如此庞大的代码工程里直接查阅也不是那么简单。这里挑一些常用且值得掌握的介绍一下。要知晓详情，可以查阅[API文档](https://docs.unrealengine.com/latest/INT/API/index.html)里面的`Core`这部分。

--------------------------

## 容器 ##

为了满足合适的存储需求，UE4提供了繁多的容器类，其中很多是直接照搬的C++标准库。所以啊，没啥令人兴奋的。

-----------------------------------

### 通用容器 ###

**TARRAY** 
*(Engine\Source\Runtime\Core\Public\Containers\Array.h)*

**TArray**是个模板动态数组，最通用最易用的UE4容器。拥有你所期望的所有动态数组特性和完备的`UPROPERTY`支持。并且，其API额外提供了将TArray看作栈或者堆的泛型支持。

TArray可以声明为`UPROPERTY`，意味着其能显示在编辑器的属性窗口上而且有资格用于网络复制，还能自动`UPROPERTY`序列化。具备如此酷炫的特性，TArray自然成为游戏逻辑功能实现的最常见选择。

如果你之前常用C++标准库里的`vector`类，**TArray**可取而代之。

**TSET** 
*(Engine\Source\Runtime\Core\Public\Containers\Set.h)*

**TSet**是对数学上**集合**这个概念的模板实现，提供必备的集合运算，比如交集、并集、差集和快速查询元素是否存在某集合（PeopleWhoLoveTSet.Contains(Me);）

*警告*：与`TArray`不同，`TSet`（和`TMap`）不直接支持`UPROPERTY`，因此就没法自动复制、序列化等等。如果一个TSet（或者TMap）用于UObject引用（比如TSet<UObject*>），就需要手动确认这些引用被正确序列化可用于垃圾回收。有的甚至需要手动清理垃圾。

TSet与STL里的`set`类相似，但UE4的实现基于哈希。如果你创建了一个新类型，且需要用在TSet（或TMap）里，那必须实现一个简单的函数来哈希这个类型：` uint32 GetTypeHash(const YourType& TypeVar) `。可以参考代码库里大量的示例。


**TMAP** 
*(Engine\Source\Runtime\Core\Public\Containers\Map.h)*

**TMap**是种数据结构模板，允许一种类型映射另一种（键-值对），具有快速添加、移除、查找元素的特点。在有些语言里，TMap结构也叫`字典（dictionary）`。

与TSet类似，TMap也不能声明成`UPROPERTY`。

TMap与STL库的`map`相比，UE4基于哈希算法实现。


------------------------------

### 迭代器 ###

UE4的容器提供迭代器支持，但用法与STL里的**不**完全相同。你可以逐个查阅容器类，了解各自支持的迭代器。当然，通用的const和非const迭代器肯定是支持滴。

示例：

```c
// Example direct from the engine source:

// Initialize an iterator from the provided array (InPackages)

for (TArray<UPackage*>::TConstIterator PkgIter(InPackages); PkgIter; ++PkgIter)
{

// Access the element at the current position of the iterator with the * operator
	UPackage* CurPackage = *PkgIter;

```

使用C++11的话，也可以用`auto`关键字。

```c

for (auto FileIt = Files.CreateConstIterator(); FileIt; ++FileIt)
{
	const FString FileExtension = FPaths::GetExtension(*FileIt);

```


------------------

### 排序

除了默认的排序选项外，UE4容器排序也允许自定义排序规则。

示例：

```c

// Custom struct written to serve as the predicate for sorting. Given two constant references to elements

// in the data structure (anim notify events), sort them according to their trigger time.

struct FCompareFAnimNotifyEvent
{

	FORCEINLINE bool operator()(const FAnimNotifyEvent& A, const FAnimNotifyEvent& B) const
	{
		return A.GetTriggerTime() < B.GetTriggerTime();
	}

};

// Sort the notifies array (TArray<FAnimNotifyEvent>) with the custom predicate

Notifies.Sort(FCompareFAnimNotifyEvent());

```

------------------------------

### 其他容器

**TArray**、**TSet**、**TMap**是UE4中最常用的容器，但不是仅有的！如果想翻源码瞧瞧所有的容器，可查阅`Engine\Source\Runtime\Core\Public\Containers`代码目录。


---------------------------------------

## 字符串处理

*(Engine\Source\Runtime\Core\Public\Containers\UnrealString.h)*

*(Engine\Source\Runtime\Core\Public\UObject\NameTypes.h)*

*(Engine\Source\Runtime\Core\Public\Internationalization\Text.h)*

UE4为字符串交互提供了三种不同的类：**FString**、**FName**、**FText**。需要清楚知晓他们各自的详细用途和最佳使用场所，可以查阅[文档](https://docs.unrealengine.com/latest/INT/Programming/UnrealArchitecture/StringHandling/index.html)和相关的链接。


----------------------

## 数学计算

*(Engine\Source\Runtime\Core\Public\Math\UnrealMathUtility.h)*

*(Engine\Source\Runtime\Core\Public\GenericPlatform\GenericPlatformMath.h)*

游戏离得开数学吗？当然不行，所以UE4拥有一套非常健壮且跨平台的数学库，在`FMath`里实现了一系列的静态函数。FMath涵盖了由简到难非常大的数学计算集合。涉及到数学的使用时，只需浏览头文件就可以理解早已写好的完整要领。


---------------------------------------

## 结语

希望这篇简单的常用库介绍对你了解UE4有所帮助。不可否认，这些只是皮毛，所幸UE4已然完全开源，其博大精深之处还需细细专研品味。有兴趣交流的可以多联系，还望不吝赐教。


----------------------

## 参阅

- [UE4 Blog](https://www.unrealengine.com/blog/ue4-libraries-you-should-know-about)
- 《Learning C++ by Creating Games with UE4》