---
title: Vim File Tree
date: 2020-10-19 12:00:04
tags:
  - Vim
categories:
  - Vim
---

# Vim 文件树

本文介绍 nerdtree 替代品，全新 vim filetree 解决方案。

## coc-explorer

coc-explorer 是一个 coc 插件。运行于 coc.nvim 提供的插件平台上。相比于nerdtree，不说性能问题，直观上就将提供更多的文件信息以及更流畅的体验。同时也可以配置icons。

关于coc-explorer的效果图及具体配置，请见其[github主页](https://github.com/weirongxu/coc-explorer)。

嫌麻烦的话，直接`CocInstall coc-explorer`。再设置一下快捷键等就可以直接使用了。以下附上我的配置。

```vim
" coc-explorer
nnoremap <leader>p :CocCommand explorer<CR>
let which_key_map2.p ='file tree'
function! s:coc_list_current_dir(args)
	let node_info = CocAction('runCommand', 'explorer.getNodeInfo', 0)
	execute 'cd ' . fnamemodify(node_info['fullpath'], ':h')
	execute 'CocList ' . a:args
endfunction

function! s:init_explorer(bufnr)
	call setbufvar(a:bufnr, '&winblend', 50)
endfunction

function! s:enter_explorer()
	if !exists('b:has_enter_coc_explorer') && &filetype == 'coc-explorer'
		" more mappings
		nmap <buffer> <Leader>fg :call <SID>coc_list_current_dir('-I grep')<CR>
		nmap <buffer> <Leader>fG :call <SID>coc_list_current_dir('-I grep -regex')<CR>
		nmap <buffer> <C-p> :call <SID>coc_list_current_dir('files')<CR>
		let b:has_enter_coc_explorer = v:true
	endif
	" statusline
	setl statusline=coc-explorer
endfunction

augroup CocExplorerCustom
	autocmd!
	autocmd BufEnter call <SID>enter_explorer()
augroup END

" hook for explorer window initialized
function! CocExplorerInited(filetype, bufnr)
	" transparent
	call setbufvar(a:bufnr, '&winblend', 10)
endfunction
```
