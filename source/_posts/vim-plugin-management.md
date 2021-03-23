---
title: Vim Plugin Management
date: 2020-10-19 21:39:32
tags:
  - Vim
categories:
  - Vim
---

# vim插件管理

本文介绍vim插件管理器。主要推荐vim-plug。如果想要更多扩展功能，可以尝试dein.vim。

## vim插件管理器

- 为什么需要插件管理器？

随着你对vim的不断扩展，为vim安装的插件将会越来越多。如果没有插件管理器，一方面，你可能无法高效地更新插件，另一方面，一些插件可能必须手动唤醒或者vim启动时启用的插件过多，导致速度大大降低。

- vim插件管理器能做什么？

提供统一的插件安装、升级、移除指令。调配各插件的启动时机，提高运行vim效率。

## vim-plug

vim-plug是继vundle后新一代的插件管理器。支持并行安装插件、支持外部管理的插件、支持按需加载等等功能。

### vim-plug安装

访问vim-plug [github 主页](https://github.com/junegunn/vim-plug)。下载`plug.vim`，放入`~/.vim/autoload/`或者`~/.local/share/nvim/site/autoload/`目录下。vim启动时会自动加载该目录下的插件。

对于windows和macos可以自行查看说明。

### vim-plug配置

```
call plug#begin('~/.vim/plugged')
" 上一行中括号内的是插件存放的目录
Plug 'junegunn/vim-easy-align'
" 上一行中引号内的是插件在github上的地址，前面是作者用户名，后面是插件名称
call plug#end()
```

### vim-plug使用

配置好插件之后，使用`:PlugInstall`安装插件。使用`PlugUpdate`更新所有插件，使用`PlugClean`清理不在配置内的插件。更多命令可以自行插件`README.md`。

关于按需加载，以及各种功能配置，由于vim-plug已经非常流行，一般不是很老的插件都会给出其`vim-plug`的配置。当然也可以自己根据文档研究。

### dein.vim

这是一个具有更强大的扩展性以及更加快速的插件管理器，但由于配置麻烦的多，且只有少数插件会给出其`dein.vim`的配置，因此笔者个人建议在插件未达到好几百的情况下，使用`vim-plug`足以。

如果你非常想要尝试，也建议搭配`dein-ui.vim`使用，可以大大降低配置难度，并且提供类似`vim-plug`的ui界面。
