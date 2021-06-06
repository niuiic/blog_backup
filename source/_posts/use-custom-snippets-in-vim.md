---
title: Use Custom Snippets in Vim
date: 2021-06-05 16:18:12
tags:
  - Vim
categories:
  - Vim
---

# 在 vim 中使用自定义 snippets

本文介绍如何在 vim 中使用自定义 snippets。本文不详解 snippets 语法。

## 插件安装与配置

首先，安装`coc-snippets`插件，该插件依赖`coc.nvim`。安装好`coc.nvim`之后，只需要使用`:CocInstall coc-snippets`命令即可安装。具体设置可以参考其[github 主页](https://github.com/neoclide/coc-snippets)。安装该插件后需要同步安装`honza/vim-snippets`来提供 snippets。`SirVer/ultisnips`需要拆卸掉，因为该插件会对自定义的 snippets 文件报错。

接下来，使用`:CocConfig`打开`coc.nvim`配置文件，设置自定义 snippets 文件路径。如`"snippets.userSnippetsDirectory": "/home/niuiic/.config/nvim/snippets"`。（注意这是个 json 文件，最外层需要花括号）

## 自定义 snippets 文件

然后就可以在该目录下自定义 snippets 文件，文件名称保持和文件类型相同即可。snippets 语法还是比较复杂的，下面给出一个简单例子，足以实现基本功能。更高级的功能请自行学习。（coc.nvim 提供的自动补全筛选能力已经足够强大，即使是简单的设置也可以带来极佳的体验。更复杂的设置个人觉得没有必要。）

`systemverilog.snippets`

```
# nomal always
snippet alw
	always @(${0}) begin

	end
```

`alw`是缩写，也就是当你打出 alw 时可以调用该 snippets。`${0}`的作用比较复杂，最简单也是对新手来说最实用的作用就是当你添加这一项后，补全 snippets 之后光标会自动停留在这个位置。

如果再加一项，如下。

```
# nomal always
snippet alw
	always @(${1}) begin
		${0}
	end
```

此时光标会停留在`${1}`的位置。

按照上述例子继续补充自己想要的 snippets 即可。注意标准写法中应当是用`endsnippet`的，不过这插件似乎不需要这个，而且加上这一句之后反而会出现在补全内容中，因此还是不加为好。
