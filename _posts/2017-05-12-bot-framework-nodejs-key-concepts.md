---
data: 2017-5-12
layout: post
title: Bot Framework 的 Node.js 实践
categories: DEV
tags: DEV AI
---

**Bot Framework** 是微软2016年提出的智能机器人平台，当然，这个机器人是没有硬件机身的。简单的说，他提供了一系列的工具与服务来简化智能AI的搭建与开发，诸如**语言理解**、**知识扩展**、**语音转换**、**网络搜索**、**图像视频识别**等等服务，所有这些被统称为 **认知服务**。

借助该平台，我们可以忽视AI算法，快速搭建一个类似微软小娜小冰这样的智能AI。Bot Framework 当前提供四种开发方式：`.NET SDK`、`Node.js SDK`、`Azure Bot Service`、`REST`。这里我们介绍 Node.js 的开发方式与其核心概念。

### 准备工作

工欲善其事，必先利其器。准备好开发环境是第一步。

- 安装 [Node.js](https://nodejs.org/en/)
- 为你的机器人创建一个文件夹
- 打开命令行，进入该文件夹
- 运行 npm 命令 `npm init`

成功之后，文件夹下会生成一个**package.json**文件，里面包含了部分模块信息。

### 创建 Bot

1. 在文件夹下新建`app.js`文件。
2. 填入下面的代码：

```javascript

var restify = require('restify');
var builder = require('botbuilder');

// Setup Restify Server
var server = restify.createServer();
server.listen(process.env.port || process.env.PORT || 3978, function () {
   console.log('%s listening to %s', server.name, server.url); 
});

// Create chat connector for communicating with the Bot Framework Service
var connector = new builder.ChatConnector({
    appId: process.env.MICROSOFT_APP_ID,
    appPassword: process.env.MICROSOFT_APP_PASSWORD
});

// Listen for messages from users 
server.post('/api/messages', connector.listen());

// Receive messages from the user and respond by echoing each message back (prefixed with 'You said:')
var bot = new builder.UniversalBot(connector, function (session) {
    session.send("You said: %s", session.message.text);
});

```
3. 保存。准备运行测试。


### 测试 Bot

1. 下载并安装 [Bot Framework Emulator](https://github.com/Microsoft/BotFramework-Emulator/releases)，
2. 启动模拟器，然后在代码文件夹下运行`node app.js`启动Bot。
3. 使用指定的`Microsoft App ID` 和 `Microsoft App Password`（注册Bot时会提供，本地测试可使用默认值）连接模拟器与你的Bot。
4. 可以和你的Bot进行交流了。


### More

现在，bot运行在本地。你可以申请空间，让他运行在服务器上，还可以直接利用微软的Azure运行于云上。当前的bot只是简单的重复你提交的文字，你可以好好残月文档，为他加上更智能的能力。
详情参阅[官方文档](https://docs.microsoft.com/en-us/bot-framework/)

ps: 接入微信公众号就可以做很多有趣的事情。