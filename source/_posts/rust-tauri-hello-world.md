---
title: Rust Tauri "Hello World"
date: 2021-05-11 20:14:05
tags:
		- Rust
		- Tauri
categories:
		- Rust
---

# Rust Tauri "Hello World"

本文介绍如何在 linux 系统上运行第一个 tauri 应用。

> js 开发人员应当可以直接参考官方文档跑通程序。本文旨在为不熟悉此类开发的人士梳理开发流程。

## 什么是 tauri

用一句话回答：tauri 是 electron 的替代品。目前它已经可以做到比 electron 更好。

## Hello World

接下来，来看如何使用 tauri 框架。

### 环境配置

根据[官方文档](https://tauri.studio/en/docs/getting-started/setup-linux)。

在 linux 下使用 tauri 需要 webkit library、nodejs runtime 以及 rust 环境的支持。

> 以下默认以 yarn 作为 js 包管理器。

这部分可以参考文档解决。另外记得给 yarn 和 cargo 换源。

### 初始化项目

1. `yarn init`

一切默认即可。

2. `yarn add @tauri-apps/cli`

在当前项目目录添加 tauri 可执行程序及其依赖。

为了方便使用，在`package.json`中设置如下内容。

```json
  "scripts": {
    "tauri": "tauri"
  }
```

设置完成之后就可以使用`yarn tauri`命令代替`tauri.js`。

3. `yarn tauri init`

初始化 tauri 项目，设置相应信息。

`Where are your web assets (HTML/CSS/JS) located`指的是存放 html、css、js 文件的目录，可以设置为`../dist`。

`What is the url of your dev server`指的是开发服务器的 url。所谓开发服务器，就是开发过程中使用的显示、调试等工具的集合。这里先将其设置为`http://localhost:8080`。

4. `yarn tauri info`

查看一下刚才设置的信息。

5. `yarn tauri dev`

编译项目并运行。

> 如果你在上面的步骤中因为网络问题而中断操作，很有可能在这一步出现报错。最快的解决方案只需简单粗暴的重头再来。

这时，你会发现项目编译完成并运行，但是显示`could not connect to server`。

这是因为没有启动开发服务器。

6. `yarn add webpack-dev-server`

安装开发服务器。

在`package.json`文件中设置如下。

```json
  "scripts": {
    "tauri": "tauri",
    "dev": "webpack serve"
  }
```

继续安装`yarn add webpack`

这时可以使用`yarn dev`来启动开发服务器。

此时，你又会发现有报错。这是因为没有配置开发服务器。

7. 配置开发服务器

在项目根目录下新建`webpack.config.js`。写入以下内容。

```javascript
const path = require("path");
module.exports = {
  entry: path.join(__dirname, "src/js/index.js"),
  output: {
    path: path.join(__dirname, "dist"),
    filename: "bundle.js",
  },
};
```

> 这里只是简单的配置。更多配置可以参考该服务器的文档。

以上配置应当容易理解，只是需要注意各路径必须是绝对路径。

在项目根目录下新建 src 目录，在 src 目录下新建 css、js 目录。在 src 目录下新建一个`index.html`空文件，在 js 目录下新建一个`index.js`空文件。

在项目跟目录下新建 dist 目录。

修改`package.json`如下。

```json
  "scripts": {
    "tauri": "tauri",
    "dev": "webpack serve --config webpack.config.js --mode development"
  },
```

现在先使用`yarn dev`开启语言服务器。等服务器完全启动后，再使用`yarn tauri dev`编译运行项目。

此时可以看到弹出窗口显示为文件浏览器。
