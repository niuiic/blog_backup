---
title: Vim Tagbar
date: 2020-10-19 12:18:02
tags:
  - Vim
categories:
  - Vim
---

# vim tagbar

本文介绍 vim tagbar 插件替代品，获取更好的 tags 显示体验。

## vista.vim 介绍

vista.vim 插件相比于 tagbar 插件的优势主要在于异步以及 lsp 支持。lsp 支持意味着有可能为各种语言提取 tags。

vista.vim 显示 tags 的方式来自于 universal-ctags、ale、vim-lsp、coc.nvim、LanguageClient-neovim、vim-lsc、nvim-lspconfig 等。提取 tags 的方式来自于 fzf、skim、vim-clap 等。这就意味着该插件需要以上插件或者包的支持。这里，笔者推荐第一部分可以采用 universal-ctags、或 coc.nvim 或 ale，第二部分采用 vim-clap。

## vista.vim 安装配置

vista.vim 的安装很简单，参考其[github 主页](https://github.com/liuchengxu/vista.vim)即可。

配置 vista.vim，可以参考我的配置。

```vim
" vista.vim
function! NearestMethodOrFunction() abort
	return get(b:, 'vista_nearest_method_or_function', '')
endfunction

set statusline+=%{NearestMethodOrFunction()}

" By default vista.vim never run if you don't call it explicitly.
"
" If you want to show the nearest function in your statusline automatically,
" you can add the following line to your vimrc
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]
let g:vista_default_executive = 'ctags'
let g:vista_executive_for = {
			\ 'cpp': 'coc',
			\ 'php': 'coc',
			\ }
let g:vista_ctags_cmd = {
			\ 'haskell': 'hasktags -x -o - -c',
			\ }
let g:vista_fzf_preview = ['right:50%']
let g:vista#renderer#enable_icon = 1
let g:vista#renderer#icons = {
			\   "function": "\uf794",
			\   "variable": "\uf71b",
			\  }
nnoremap <silent><nowait> <space>m :<C-u>Vista!!<cr>
let g:which_key_map1.m = 'open the file tagbar'
```

其中需要注意的有以下几行

```
let g:vista_default_executive = 'ctags'
let g:vista_executive_for = {
			\ 'cpp': 'coc',
			\ 'php': 'coc',
			\ }
nnoremap <silent><nowait> <space>m :<C-u>Vista!!<cr>
```

第一行表示使用的默认显示 tags 工具，其实指的是提取 tags 的工具。不同工具的显示方式不同。笔者在这里使用的是`universal-ctags`，因此设置为 ctags。其余可选项可以参考其 github 主页。

第二行是为特殊文件类型配置特殊工具。

第三行是快捷键设置，只需要为`:Vista!!`命令配置快捷键即可。
