---
data: 2016-9-21
layout: post
title: UE4 Timer
categories: UE4
tags: UE4 doc
---


**Timer**这个东西在游戏开发里太常用了，大到游戏世界的驱动，小到物体的状态变迁，均有timer的身影。游戏世界虽说是个虚拟世界，但总归是需要时间维度的。在UE4中，Timer的基本作用就是**在固定间隔内重复或单次执行某些操作**。具体到应用，常见的就是Delay、固定频率刷新某个操作。

UE4中所有的Timer都是由全局类**FTimerManager**管理。在AActor之外，可以指定任意类型的委托。FTimerManager提供一些函数用来操作Timer，同时这些函数也能用于Timer的委托中，比如可以在一个Timer的委托里新建（删除）另一个Timer。

`AActor::GetWorldTimerManager()`用来获取当前世界的TimerManager实例。然后通过这个实例调用函数就可以控制Timer了。

一般来讲，你可能还需要一个`FTimerHandle`来指定具体的Timer。

- SetTimer

为Timer指定回调函数、间隔时间，是否循环等参数，并启动该Timer，使其开始计时。该函数也可用来重设已有的Timer，此时，计时也将重新开始。

在Blueprint中常见的`Delay`节点在C++就需要用这个函数指定一个一次性的Timer。

- ClearTimer

销毁清理指定的Timer，使其不再计时，当然也不会再回调。将`SetTimer`的间隔时间参数设为<0.f有同样的效果。

- PauseTimer

暂停指定的Timer，此时Timer停止计时但会保存已经过的时间和剩余时间，直到恢复计时。

- UnPauseTimer

激活已暂停的Timer。

- IsTimerActive

获取指定Timer的当前状态（运行/暂停)

- GetTimerRate

获得指定Timer的当前频率（就是时间间隔参数）。
频率不支持直接修改，但可以在Timer的回调里重用TimerHandle重新SetTimer。
函数返回 -1 说明该TimerHandle非法。

- GetTimerElapsed

获得指定Timer的当前间隔内已经计时的时长

- GetTimerRemaining

获得指定Timer当前间隔内的剩余时长

**已经计时的时长 + 剩余时长 = 间隔时间**



常用的接口差不多就这些，更多更详细的可以参阅[API文档](http://api.unrealengine.com/INT/API/Runtime/Engine/FTimerManager/)。比如各种SetTimer的重载，更多Timer的状态信息。
