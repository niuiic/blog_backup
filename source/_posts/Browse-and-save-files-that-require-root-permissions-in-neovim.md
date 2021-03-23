---
title: Browse and Save Files that Require Root Permissions In Neovim
date: 2020-10-18 21:14:07
tags:
  - Vim
categories:
  - Vim
---

# Neovim浏览及保存需要root权限的文件

## vim保存时获取root权限

vim可以在保存文件时使用`:w !  sudo  tee  %`获取权限。但neovim暂不支持该命令，或者说无法输入密码。

## 解决方案

安装[`suda.vim`插件](https://github.com/lambdalisue/suda.vim)。

接着在`init.vim`设置`let g:suda_smart_edit = 1`即可。插件会自动检测文件权限。当保存需要权限时，会自动提示输入密码。
