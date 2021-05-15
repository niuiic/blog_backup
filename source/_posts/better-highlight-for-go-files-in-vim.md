---
title: Better Highlight for Go Files in Vim
date: 2021-04-28 21:46:41
tags:
  - Vim
categories:
  - Vim
---

# vim 中更好的 go 语言高亮

本文主要说明如何解决 go 方法在大多数配色方案中无法高亮的问题。

## 问题描述

vim 现有的绝大多数高亮插件都没有对 go 语言方法进行高亮。如`fmt.Printf`。则`Printf`不会被高亮。

## 解决方案

访问[athom/more-colorful.vim](https://github.com/athom/more-colorful.vim/blob/master/after/syntax/go.vim)。将文件内容拷贝到`~/.vim/after/syntax/`。如果是 neovim，则拷贝到`～/.config/nvim/after/syntax/`。

该配置提供了操作符、函数、方法、结构体的高亮。需要取消某一高亮只需要修改以下内容。

```vim
if !exists("go_highlight_operators")
	let go_highlight_operators = 0
endif
```

要给各高亮组换色只需要设置以下内容。

```vim
hi goMethod guifg=#4dffff
```
