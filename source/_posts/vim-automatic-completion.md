---
title: Vim Automatic Completion
date: 2020-10-19 10:43:22
tags:
  - Vim
categories:
  - Vim
---

本文介绍 vim 自动补全方案。主要采用更强大的 coc.nvim 插件来替代 YCM。

# vim 自动补全

## 前言

自动补全对于任何一个试图取代 IDE 的编辑器的重要性不言而喻。想要将 vim 打造为最契合自己的 IDE，无论如何都不能少了强大的自动补全功能。

## coc.nvim 介绍

coc.nvim 是针对 neovim 开发的的功能非常强大，完全可以替代 YCM，带来更加优越的补全体验。包括语义补全、片段补全、定义跳转、文档查阅、静态检查等等。

同时 coc.nvim 也是一个全新的插件平台，除了其原生插件外，理论上也支持所有纯 JS 实现的 vscode 插件。拥有 coc.nvim，就拥有了一个异步插件平台。

## coc.nvim 安装

coc.nvim 需要`nodejs`支持。安装`nodejs`后，用插件管理器安装 coc.nvim 即可。具体可参考其[github 主页](https://github.com/neoclide/coc.nvim)。

## 使用 coc.nvim 进行补全

coc.nvim 的补全可以采用安装插件或者配置 lsp 实现。

### 语义补全及静态检查

以 rust 语言为例，可以直接使用`:CocInstall`安装`coc-rust-analyzer`插件（会自动安装`rust-analyzer`）。也可以在安装`rust-analyzer`后在 coc.nvim 的配置文件中配置。使用`:CocConfig`打开配置文件，写入

```json
{
  "languageserver": {
    "rust": {
      "command": "rust-analyzer",
      "filetypes": ["rust"],
      "rootPatterns": ["Cargo.toml"]
    }
  }
}
```

注意`command`必须保证可用。

关于 coc 插件以及 lsp 配置的具体内容可以参考[coc.nvim wiki](https://github.com/neoclide/coc.nvim/wiki)。

到此，rust 语言的自动补全已经配置完成，静态检查也同步配置完成。但仅仅如此还不可以使用。coc.nvim 的自动配置在项目工程中才能起作用。如单独编写一个`main.rs`，则不会有语义提示。必须以`cargo new demo`新建一个工程，插件检测到`Cargo.toml`后才会启动语义的自动补全。当然也有可以直接在单文件中提示的特例，如 markdown 语言，本身就不存在工程的概念。

### 片段补全

安装`coc-actions`插件。

再在`coc-snippets`、`coc-ultisnips`中选择一个或全选即可。注意需要同步安装`honza/vim-snippets`、`SirVer/ultisnips`。

### 自定义补全源

coc.nvim 默认的补全源来自当前打开的所有 buffer、插件或 lsp 等。此外也可以自定义补全源。具体可参见[coc.nvim wiki](https://github.com/neoclide/coc.nvim/wiki/Create-custom-source)

下面以补全 markdown 中的 latex 语法为例，展示如何自定义补全源。

创建目录`~/.config/nvim/autoload/coc/source`。这里以 linux 系统为例，其他系统的位置可以自行参考 wiki。

创建`latex.vim`，写入

```vim
function! coc#source#latex#init() abort
	return {
				\'triggerCharacters': ['\'],
				\'filetypes' : ['markdown'],
				\}
endfunction

function! coc#source#latex#complete(opt, cb) abort
	let items = ['kappa', 'theta', 'dot{}', 'ddot{}', 'bar{}', 'hat{}', 'exp', 'sin', 'cos', 'tan', 'sec', 'csc', 'vec{}', 'cot', 'arcsin', 'arccos', 'arctan', 'sinh', 'cosh', 'tanh', 'coth', 'sh', 'ch', 'th', 'max', 'min', 'partial', 'nabla', 'prime', 'backprime', 'infty', 'eth', 'hbar', 'sqrt{}', 'sqrt[]{}', 'pm', 'mp', 'times', 'div', 'cdot', 'odot', 'bigodot' , '{ \}', 'in', 'not', 'ni', 'cap', 'Cap', 'bigcap', 'cup', 'Cup', 'bigcup', 'subset', 'supset', 'supseteq', 'subseteq', 'subseteqq', 'supseteqq', 'subsetneq', 'supsetneq', 'supsetneqq', 'subsetneqq', 'sim', 'approx', 'leq', 'geq', 'parallel', 'nparallel', 'perp', 'angle', 'Box', 'bigtriangleup', 'bigtriangledown', 'forall', 'therefore', 'because', 'overline{}', 'Rightarrow', 'Leftarrow', 'rightarrow', 'leftarrow', 'leftrightarrow', 'nRightarrow', 'nLeftarrow', 'nleftarrow', 'nrightarrow', 'nleftrightarrow', 'overleftarrow{}', 'overrightarrow{}', 'overset{}', 'underline{}', 'sum', 'prod', 'lim', 'limits', 'int', 'iint', 'oint', 'iiint', 'frac{}{}', 'tfrac{}{}', 'dfrac{}{}', '\begin{matrix}\end{matrix}', '\begin{vmatrix}\end{vmatrix}', '\begin{bmatrix}\end{bmatrix}', '\begin{Bmatrix}\end{Bmatrix}', '\begin{pmatrix}\end{pmatrix}','\begin{cases}\end{cases}', '\begin{aligned}\end{aligned}', '\begin{array}\end{array}', 'alpha', 'psi', 'Delta', 'delta', 'beta', 'lambda', 'rho', 'varepsilon', 'Gamma', 'chi', 'mu', 'sigma', 'Lambda', 'tau', 'varphi', 'varPhi', 'phi', 'Phi', 'eta', 'omega', 'varrho', 'Pi', 'pi', 'gamma', 'xi', 'Psi', 'Sigma', 'varnothing', 'iiiint']
	call a:cb(items)
endfunction
```

简单分析一下。配置的主体框架按照 wiki 给出的例子照猫画虎即可。其中`triggerCharacters`表示触发字符，意思就是说当输入该字符时启动补全。`filetypes`表示该补全源作用的文件类型。更多选项参见 wiki。

## 修复定义跳转卡住的问题

使用 coc.nvim 的定义跳转到其他文件时，可能会直接卡死。原因不明，可能是文件太大加载不过来，但也存在小文件被卡住的问题。

修复方案是重启语法分析。

```vim
" 关闭
:syn off
" 开启
:syn enable
```

可以设置进入 Vim 时自动执行该命令，设置如下。

```vim
au VimEnter * :syn off<CR>
au VimEnter * :syn enable<CR>
```

## 其他功能

coc.nvim 提供的其他功能还有很多，包括定义跳转、文档查询等等，下面介绍几个很重要的功能，其他的可以自行研究。

预览窗口翻页，配置如下。

```vim
" scroll preview window
if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-]> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-]>"
    nnoremap <silent><nowait><expr> <C-[> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-[>"
    inoremap <silent><nowait><expr> <C-]> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-[> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-]> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-]>"
    vnoremap <silent><nowait><expr> <C-[> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-[>"
endif
```

跳转到定义等，配置如下。

```vim
nmap <silent><nowait> <space>gy <Plug>(coc-type-definition)
nmap <silent><nowait> <space>gi <Plug>(coc-implementation)
nmap <silent><nowait> <space>gr <Plug>(coc-references)
nmap <silent><nowait> <space>gd <Plug>(coc-definition)
```

变量、函数等重命名，配置如下。

```vim
nmap <silent><nowait> <space>cr <Plug>(coc-rename)
```

跳转到错误或者警告，配置如下。

```vim
" jump to the next or previous error
nmap <silent> ck <Plug>(coc-diagnostic-prev)
nmap <silent> cj <Plug>(coc-diagnostic-next)
```

以下附上我的 coc.nvim 配置。仅供参考。其中`vim-which-key`的部分如果没有安装该插件就不必配置。

```vim
" coc.nvim
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" scroll preview window
if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-]> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-]>"
    nnoremap <silent><nowait><expr> <C-[> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-[>"
    inoremap <silent><nowait><expr> <C-]> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-[> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-]> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-]>"
    vnoremap <silent><nowait><expr> <C-[> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-[>"
endif


" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
    Recently vim can merge signcolumn and number column into one
    set signcolumn=number
else
    set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
else
    inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
    inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
    inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" GoTo code navigation.
nmap <silent><nowait> <space>gy <Plug>(coc-type-definition)
nmap <silent><nowait> <space>gi <Plug>(coc-implementation)
nmap <silent><nowait> <space>gr <Plug>(coc-references)
nmap <silent><nowait> <space>gd <Plug>(coc-definition)

let g:which_key_map1.g = {
    \ 'name': '+coc.goto',
    \ 'y' : 'go to type definition',
    \ 'i' : 'go to implementation',
    \ 'r' : 'go to references',
    \ 'd' : 'go to definition',
    \ }

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocActionAsync('doHover')
    endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <silent><nowait> <space>cr <Plug>(coc-rename)

" Formatting selected code.
nmap <silent><nowait> <space>cm <Plug>(coc-format-selected)
xmap <silent><nowait> <space>cm <Plug>(coc-format-selected)

let g:which_key_map1.c = {
    \ 'name' : '+coc',
    \ 'f' : 'automatically fix errors in current line',
    \ 'm' : 'format selected code',
    \ 'r' : 'rename symbol',
    \ }

augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Apply AutoFix to problem on the current line.
nmap <silent><nowait> <space>cf <Plug>(coc-fix-current)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" jump to the next or previous error
nmap <silent> ck <Plug>(coc-diagnostic-prev)
nmap <silent> cj <Plug>(coc-diagnostic-next)

" Mappings for CoCList
" open CocList
nnoremap <silent><nowait> <leader>ct  :<C-u>CocList<cr>
" Show all diagnostics.
nnoremap <silent><nowait> <leader>ca  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <leader>ce  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <leader>cc  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <leader>co  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <leader>cs  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <leader>cj  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <leader>cz  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <leader>cp  :<C-u>CocListResume<CR>

let g:which_key_map2.c = {
    \ 'name' : '+coc',
    \ 't' : 'open coc list',
    \ 'a' : 'show all diagnostics',
    \ 'e' : 'manage extensions',
    \ 'c' : 'show commands',
    \ 'o' : 'find symbol of current document',
    \ 's' : 'search workspace symbols',
    \ 'j' : 'do default action for next item',
    \ 'z' : 'do default action for previous item',
    \ 'p' : 'resume latest coc list',
    \ }
```
