---
title: Vim Fuzzy Search Plugin
date: 2021-03-23 16:48:00
tags:
  - Vim
categories:
  - Vim
---

# vim 模糊搜索

本文主要介绍 vim 高性能模糊查找插件 vim-clap。另外也推荐尝试 coc.nvim 自带的 coc list。

## 插件功能

模糊查找的内容包括编辑文件历史、文件内容、mark、tags、vim 主题、buffers、windows、quickfix 等等。

这些功能在一些 IDE 与 vscode 等编辑器中有直接的集成。而在 vim 中，需要自己扩展。

vim-clap 的效果图可以查看其[github 主页](https://github.com/liuchengxu/vim-clap)。

## vim-clap

vim-clap 是一款后端用 rust 语言开发的模糊查找插件，因此速度非常快。

### vim-clap 安装

首先，最好先配置好 rust 语言环境（不配应该也可以）。使用 rustup 安装 rust 语言编译链及配套工具。这一部分可以参考 rust 官方文档，此处不做介绍。提示一下，官方给的安装 rustup 的链接并没有被墙，无需翻墙。

安装好之后，如果嫌速度慢，可以换上中科大的源。网上教程很多，此处不再介绍。

如果你已经完成了上述所有步骤，则可以按照文档给出的 vim-plug 配置安装插件。如果你没有完成上述步骤，使用`Plug 'liuchengxu/vim-clap', { 'do': { -> clap#installer#force_download() } }`来安装你的插件。vim-plug 将在下载好插件之后继续编译或者下载其 rust 依赖。

### vim-clap 配置

该插件的默认配置已经很完善，你完全可以直接使用。

该插件的默认快捷键在官方文档中有介绍。其命令也很简单，只需要`:Clap xxx`，`xxx`表示你想要搜索的内容。可选的内容在文档中也已经列出。

最后给出笔者的快捷键配置方案，仅供参考。

```vim
" vim-clap
nnoremap <silent><nowait> <space>op  :<C-u>Clap<CR>
nnoremap <silent><nowait> <space>ob  :<C-u>Clap buffers<CR>
nnoremap <silent><nowait> <space>oc  :<C-u>Clap command<CR>
nnoremap <silent><nowait> <space>oh  :<C-u>Clap history<CR>
nnoremap <silent><nowait> <space>of  :<C-u>Clap files ++finder=rg --ignore --hidden --files<CR>
nnoremap <silent><nowait> <space>oq  :<C-u>Clap quickfix<CR>
nnoremap <silent><nowait> <space>oj  :<C-u>Clap jumps<CR>
nnoremap <silent><nowait> <space>om  :<C-u>Clap marks<CR>
nnoremap <silent><nowait> <space>ow  :<C-u>Clap windows<CR>
nnoremap <silent><nowait> <space>ot  :<C-u>Clap tags<CR>
nnoremap <silent><nowait> <space>os  :<C-u>Clap colors<CR>
nnoremap <silent><nowait> <space>og :<C-u>Clap grep2<CR>

let g:which_key_map1.o = {
			\ 'name' : '+clap',
			\ 'p' : 'clap',
			\ 'b' : 'buffers',
			\ 'c' : 'command',
			\ 'h' : 'file history',
			\ 'f' : 'search file',
			\ 'q' : 'quickfix list',
			\ 'j' : 'jumps',
			\ 'm' : 'marks',
			\ 'w' : 'windows',
			\ 't' : 'tags',
			\ 's' : 'colors',
			\ 'g' : 'find word',
			\ }
```

## coc list

coc list 是 coc.nvim 自带的模糊查找功能模块。它不仅可以用于控制补全源、lsp 等的开关，coc 插件的调用，也具有部分模糊查找的功能，不过功能暂时还没有那么强大，并不支持那么多内容的查找。有兴趣的可以自行研究。
