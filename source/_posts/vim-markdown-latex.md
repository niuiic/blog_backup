---
title: Choose vim to edit markdown and latex files
date: 2020-08-04 12:41:30
tags:
- Vim
- Latex
- Markdown
categories: 
- Vim 
---

# 使用 vim 编写 markdown 和 latex

## 前言

### 主要配置

- 操作系统：arch linux
- 编辑器：neovim（coc-actions 仅支持 neovim），如果使用 vim，请换用另外的补全插件
- 预览：markdown 使用 typora，latex 用 vimtex 调用 MuPDF

### 优缺点

在使用 vim 之前，曾尝试了两种方案，一是 vscode + vim，配置简单，功能都还不错，问题是自动输入法切换延迟有点长，甚至使用方向键都有点卡，二是 jetbrains 系列的 ide，windows 下用来码字是体验最好的（linux 下对中文输入法不友好），但资源消耗太多，且预览不是很理想

下面是这套方案的优缺点

- linux 下 vim 的输入法切换体验远远好于 windows（笔者未使用 mac os，不清楚情况）
- windows 下使用 texlive 安装 latex 相关依赖，编译 latex 文档时出现错误，暂时没能修复，linux 下比较稳定
- neovim 以及 vim 比 vscode + vim 插件更流畅
- 支持 latex 即时编译，缺点是无法正反向搜索，这点在 vscode 中是支持的
- typora 对 markdown 渲染的支持比 vim 以及 vscode 的相关插件好得多，比如支持本地 mp4 视频插入等，缺点是无法正反向搜索

### 注意事项

- 以下步骤全靠回忆，不会有错，但可能有漏，请小心操作，避免掉坑，欢迎留言
- 由于网页的关系，直接从本文复制的内容可能存在非法字符，复制粘贴后应当检查一下
- arch linux 可能帮你避开许多坑，如果想了解并使用 arch，可参考 arch wiki 安装教程，若水平有限，可以在网上搜索视频安装教程，还不行的话直接装 manjaro 吧
- 装好下面提到的软件时注意检查是否可以直接在终端调用

## vim 简单配置

### vim-plug

[github 地址](https://github.com/junegunn/vim-plug)

作者提供的安装方式应该是装不上的，似乎是这个链接本身有问题，不是 GFW 的锅

#### 安装

把项目克隆到本地，将项目中的 plug.vim 放到`~/.local/share/nvim/site/autoload`目录下，如果你使用 vim，可以放到`~/.vim/autoload`目录下

#### 使用

编辑`~/.config/nvim/init.vim`

一个`Plug`对应一个插件，如果你和我一样只是想用 vim 编辑 markdown 和 latex（不包括 markdown 预览），那就直接 copy 吧（注意可以更换第一行`begin`后插件存放的路径）

插件依次为自动补全、文件树、文件浏览器（需要安装 nnn，没有的话就不要它了）、snippets 补全、snippets 补全、状态栏美化、自动格式化、markdown 支持、开始界面、latex 支持

部分本文未涉及的插件的具体用法请自行前往 github 查看，或者放弃使用

```
call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
Plug 'mcchrish/nnn.vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'vim-airline/vim-airline'
Plug 'Chiel92/vim-autoformat'
Plug 'plasticboy/vim-markdown'
Plug 'mhinz/vim-startify'
Plug 'lervag/vimtex'
call plug#end()
```

先别急着装插件，查看[coc.nvim wiki](https://github.com/neoclide/coc.nvim/wiki/Install-coc.nvim)，先把依赖装了，主要是`nodejs`和`yarn`，作者给出的方法再次有点为难了，不过 arch linux 直接用包管理器装就行，其他的可能需要折腾一会儿

另外[vim-autoformat](https://github.com/Chiel92/vim-autoformat)插件需要安装依赖，在 vim-autoformat 的 github 主页下查找，主要是`remark` for markdown 以及`latexindent.pl` for latex，arch 系 linux 可以先尝试从 aur 安装，不行的话可以按照 github 上作者给出的方式安装，大概又是一番折腾，特别注意，如果这两个软件无法在全局调用，需要在配置文件中加上`let g:formatterpath = ['/some/path/to/a/folder', '/home/superman/formatters']`，也可以选择创建符号链接使其可在全局调用（暂时有个问题，格式化 markdown 时会将其中的 latex 公式比如`$\frac{}{}$`变为`$\\frac{}{}$`，不过可以手动替换`\\`为`\`，或者也可以尝试其他的格式化工具，见补充部分）

重新进入 neovim，执行`:PlugInstall`，等待安装结束，退出

### vim 配置

剩余的配置如下，重要的在下面，从`" vim snippets##########################################`开始，前面的除了前两行都是 copy 自`coc.nvim`的基础配置，不想细看就 copy 吧，如果只想编写 markdown 或 latex，则删除对应插件的配置，顺便把前面的插件也给删了

```
set relativenumber
set number

" TextEdit might fail if hidden is not set.
set hidden

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

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

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
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
	inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
	inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
	if (index(['vim','help'], &filetype) >= 0)
		execute 'h '.expand('<cword>')
	else
		call CocAction('doHover')
	endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
	autocmd!
	" Setup formatexpr specified filetype(s).
	autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
	" Update signature help on jump placeholder.
	autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

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

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" vim snippets##########################################
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" autoformat##########################################
noremap <C-L> :Autoformat<CR>

" nerdtree##########################################
map <C-p> :NERDTreeToggle<CR>

" vimtex##########################################
let g:vimtex_view_general_viewer = 'mupdf'
let g:vimtex_view_general_options_latexmk = '-reuse-instance'
let g:vimtex_view_general_options
\ = '-reuse-instance -forward-search @tex @line @pdf'
\ . ' -inverse-search "' . exepath(v:progpath)
\ . ' --servername ' . v:servername
\ . ' --remote-send \"^<C-\^>^<C-n^>'
\ . ':execute ''drop '' . fnameescape(''\%f'')^<CR^>'
\ . ':\%l^<CR^>:normal\! zzzv^<CR^>'
\ . ':call remote_foreground('''.v:servername.''')^<CR^>^<CR^>\""'

set conceallevel=1
let g:tex_conceal='abdmg'
" Prevent that vim detect a file with the tex suffix as a plaintex
let g:tex_flavor='latex'
" Set the viewer method
let g:vimtex_view_method='mupdf'
" Never opened/closed the quickfix window automatically. The quickfix window shows the errors and/or warnings when compile, and we can open the quickfix windows use \le
let g:vimtex_quickfix_mode=0
" 最后两行开启自动隐藏功能,开启了这个功能，除了你光标所在的那一行之外，文本里夹杂的LaTeX代码就都会隐藏或者替换成其他符号
set conceallevel=1

let &t_SI.="\e[5 q" "SI = INSERT mode
let &t_SR.="\e[4 q" "SR = REPLACE mode
let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)

inoremap <C-c> <esc>
```

说明：格式化快捷键设置成了`ctrl + l`，`coc.nvim`可以使用`ctrl + n`选择提示项（只能往下翻，对我来说足够了，需要更好地体验可以自行设置），按`ctrl + p`打开文件树

### 输入法自动切换

这部分很重要，极其影响体验感

首先确保你使用的是 fcitx 输入法，fcitx4 和 fcitx5 都可以

[下载最新版本的 fcitx.vim](https://www.vim.org/scripts/script.php?script_id=3764)

解压后把 plugin 和 so 两个文件夹放到`~/.config/nvim`，或者干脆在这个目录下解压，如果是 vim，则应放到`~/.vim`

这里有个坑，上面已经填了，配置文件最后一行`inoremap <C-c> <esc>`，将`ctrl + c`映射为`esc`，默认情况下两者都可以进入普通模式，但前者不会触发相关事件，这使得插件无效（不知有没有像我一样使用`ctrl + c`的 vimer）

如果你的`ctrl + c`在插入模式下另有用处，请删除该行

注意：作者并不是为 neovim 设计的插件，目前最新版本的 neovim 可以使用，但不意味着一直可以使用

### 相关 python 依赖安装

coc.nvim 需要 python 模块支持，另外 fcitx.vim 也需要 python 的 vim 模块以使用 fcitx.py 来获取更好的体验，不过这和 neovim 就没关系了，也可以装上，还有`autoformat`插件也需要 Python 模块

使用`pip`安装`python-vim`、`neovim`，并`python3 -m pip install pynvim`

对于 gentoo，使用 pip 安装 python 模块需要加--usr 选项，这样安装的模块默认情况下是无法被 python 找到的，需要设置一下。如果不知如何解决，可以直接`emerge dev-python/pynvim`，其他的就无需安装

如果你的 neovim 找不到 Python3，则在 neovim 配置文件中加入`let g:python3_host_prog=/path/to/python/executable/`，路径自己改

### coc.nvim 配置

查看[coc extensions](https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions)，找到 markdown 和 latex 的对应扩展（按需安装），使用`:CocInstall`指令安装

此外，还需要安装`coc-snippets`和`coc-actions`以配合 snippets 相关插件

查看[coc language servers](https://github.com/neoclide/coc.nvim/wiki/Language-servers)，找到 markdown 和 latex，按照指示完成配置，如果遇到困难，继续往下看

这里使用`:CocConfig`指令打开 coc 配置文件，如果你不熟悉 json，特别注意，文件中的所有内容需要用`{}`包起来，直接 copy 作者给的配置会出现语法错误

这里安装`efm-langserver`和`digestif`又有问题了，arch 直接从 aur 安装再次避坑（需要先配置 go 语言环境，GOROOT 在 arch 上为`/usr/lib/go`，如果你上网找的话，可能会被`/usr/local/go`给坑了，go 安裝完毕后 GOROOT 下是有文件的，不确定是哪个可以去查看一下，另外还需要打开`go module`，以及给`go get`设置国内代理，详见[go 语言依赖管理](https://blog.csdn.net/weixin_44690437/article/details/103571558)，试图那啥的可以省省了，`go get`不认这招，或许全系统代理可以），其他的可能需要折腾一会儿

这里附上我的`coc-settings.json`，copy 的时候把两个路径换成自己的，另外特别注意`command`需要使用绝对路径

```
{
          languageserver : {
                   digestif : {
                          command :  /bin/digestif ,
                          filetypes : [ tex ,  plaintex ,  context ]
                 },
                  efm : {
                          command :  /bin/efm-langserver ,
                         args : [ -c ,  /home/yourUsername/.config/efm-langserver/config.yaml ],
                          filetypes : [ vim ,  eruby ,  markdown ]
                 }
        },
          suggest.noselect : false
 }

```

## markdown

markdown 的部分上面已经完成的差不多了，现在先创建一个.md 文件，查看是否可以补全，`nvim test.md`，输入`img`，应该会有提示，如果没有，请检查`coc.nvim`以及两个关于`snippets`的插件

目前还有一个至关重要的问题，markdown 中的 latex 无法补全，极其影响体验感，不过`coc.nvim`可以[自定义 sources](https://github.com/neoclide/coc.nvim/wiki/Create-custom-source)，在`~/.config/nvim/autoload/coc/source`下创建`latex.vim`，写入

```
function! coc#source#latex#init() abort
	return {
				\ 'triggerCharacters': ['\'],
				\'filetype':['markdown']
				\}
endfunction

function! coc#source#latex#complete(opt, cb) abort
	let items = ['dot{}', 'ddot{}', 'bar{}', 'hat{}', 'exp', 'sin', 'cos', 'tan', 'sec', 'csc', 'vec{}', 'cot', 'arcsin', 'arccos', 'arctan', 'sinh', 'cosh', 'tanh', 'coth', 'sh', 'ch', 'th', 'max', 'min', 'partial', 'nabla', 'prime', 'backprime', 'infty', 'eth', 'hbar', 'sqrt{}', 'sqrt[]{}', 'pm', 'mp', 'times', 'div', 'cdot', 'odot', 'bigodot' , '{ \}', 'in', 'not', 'ni', 'cap', 'Cap', 'bigcap', 'cup', 'Cup', 'bigcup', 'subset', 'supset', 'supseteq', 'subseteq', 'subseteqq', 'supseteqq', 'subsetneq', 'supsetneq', 'supsetneqq', 'subsetneqq', 'sim', 'approx', 'leq', 'geq', 'parallel', 'nparallel', 'perp', 'angle', 'Box', 'bigtriangleup', 'bigtriangledown', 'forall', 'therefore', 'because', 'overline{}', 'Rightarrow', 'Leftarrow', 'rightarrow', 'leftarrow', 'leftrightarrow', 'nRightarrow', 'nLeftarrow', 'nleftarrow', 'nrightarrow', 'nleftrightarrow', 'overleftarrow{}', 'overrightarrow{}', 'overset{}', 'underline{}', 'sum', 'prod', 'lim', 'limits', 'int', 'iint', 'oint', 'iiint', 'frac{}{}', 'tfrac{}{}', 'dfrac{}{}', '\begin{matrix}\end{matrix}', '\begin{vmatrix}\end{vmatrix}', '\begin{bmatrix}\end{bmatrix}', '\begin{Bmatrix}\end{Bmatrix}', '\begin{pmatrix}\end{pmatrix}','\begin{cases}\end{cases}', '\begin{aligned}\end{aligned}', '\begin{array}\end{array}', 'alpha', 'psi', 'Delta', 'delta', 'beta', 'lambda', 'rho', 'varepsilon', 'Gamma', 'chi', 'mu', 'sigma', 'Lambda', 'tau', 'varphi', 'varPhi', 'phi', 'Phi', 'eta', 'omega', 'varrho', 'Pi', 'pi', 'gamma', 'xi', 'Psi', 'Sigma', 'varnothing', 'iiiint']
	call a:cb(items)
endfunction
```

关于自定义 source 的具体细节，请前往 github，上面给出的 source 设定在 markdown 文件下加载，使用`\`作为触发符，这里只加入了我常用的几个命令，更多内容可以自行添加

到此，markdown 部分已经完成，可以先检查一下有没有问题

## latex

首先安装 latex 编译环境，这里使用 texlive

参考[arch wiki](<https://wiki.archlinux.org/index.php/TeX_Live_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)，不想折腾的话就把安装部分提到的几个包全装了，应该就问题不大了

如果还有问题，或者是其他 linux 发行版，可以参考[Deepin Linux 安装和搭建 LaTex 环境](https://zhuanlan.zhihu.com/p/40053417)和[Ubuntu18.04 安装 LaTeX 并配置中文环境](https://blog.csdn.net/qq_41814939/article/details/82288145)，不过安装 texlive-full 实在太麻烦了，我装了 3 小时，最后似乎卡住了，手贱中断了，再也装不上了，这个包和前面 arch wiki 中提到的包大部分是冲突的，如果是 arch 系的就不要折腾这个了，如果是 gentoo 的话，如果坚持本地编译的话，建议备好电影小零食~~（窃以为使用 gentoo 的 linux 骨灰级玩家不需要这篇文章，强行 gentoo 的玩家可能还没从坑里爬出来）

安装 MuPDF，当然你也可以选择别的，详见[github](https://github.com/lervag/vimtex)，如果换了的话需要把上面的配置也一并修改

到此结束，测试一下，`nvim test.tex`，写入

```
\documentclass{article}
\begin{document}
你好，world!
\end{document}
```

在普通模式下按`\ll`进行编译，再按`\lv`预览，不要关闭预览窗口，修改成`hello world`，保存，重新编译，看看预览是否同步改变，这里还可以设置保存时自动编译

## 更多

- linux 下没有可以和 FastStone 媲美的截图软件，不过可以用 KolourPaint 快速编辑图片，需要更多操作可以使用 GIMP，不建议使用 Pinta，由于无法输入中文
- markdown 中可以用 html 语法插入 mp4 视频，比起 gif 的好处就不用多说了，缺点是略显臃肿
- 可以再为 vim 配置更多插件，比如 markdown 自动贴图、markdown 预览等等，也可以继续自定义 snippets，这些部分按个人喜好配置，这里不再介绍
- 桌面推荐 i3，i3 配置较为麻烦，可以保留原有桌面，简单配置 i3，仅用来写 markdown 和 latex
- 或许可以在 WSL 中配置，不过暂时折腾到此为止了

## 补充

### 为 markdown 添加大纲显示

#### Excuberant Ctags

首先安装`Excuberant Ctags`，debian 系和 redhat 系应该可以使用包管理工具直接安装，arch 这次似乎进坑了，需要编译源码

访问[Excuberant Ctags 下载页面](http://ctags.sourceforge.net/)，没错，GFW 警告，这个资源可以在网上搜，文件名为 ctags-5.8，csdn 上有，本来想上传一个免费的，结果死活都重复，算了

解压，cd 入目录，`./configure`，继续`make && sudo make install`，正常情况下应该没问题了，如果有问题，请参考[安装 Exuberant Ctags 及 Tag List 插件](https://blog.csdn.net/dream2009gd/article/details/44102227)

#### easytags

使用`vim-plug`安装

```
Plug 'xolox/vim-misc'
Plug 'xolox/vim-easytags'
```

#### [tagbar](https://github.com/majutsushi/tagbar)

```
Plug 'majutsushi/tagbar'
```

注意使用该插件时可能有问题，详情见 github

#### markdown2ctags

```
Plug 'jszakmeister/markdown2ctags'
```

#### 配置

```
" tagbar#####################################
nmap <C-M> :TagbarToggle<CR>

" markdown2ctags#####################################
let g:tagbar_type_markdown = {
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin' : '/home/yourUsername/.vim/plugged/markdown2ctags/markdown2ctags.py',
    \ 'ctagsargs' : '-f - --sort=yes --sro=»',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '»',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }
```

这里给 tagbar 的快捷键设置为`ctrl + m`，`markdown2ctags`的配置中需要注意更换你的`markdown2ctags.py`所在路径，且注意通过`:set filetype`查看你的 markdown 文件的文件类型名称是否是 markdown，若不是，则修改`ctagstype`

### 格式化插件[neoformat](https://github.com/sbdchd/neoformat)

#### 插件安装

```
Plug 'sbdchd/neoformat'
```

#### 依赖安装

##### [prettier](https://github.com/prettier/prettier) for markdown

不要选 remark 作为格式化软件

arch 可以直接从 aur 安装，其他参考[install prettier](https://prettier.io/docs/en/install.html)

##### [latexindent.pl](https://github.com/cmhughes/latexindent.pl) for latex

将项目 clone 到本地

安装`perl`，执行`sudo cpan`

进入`cpan`环境后，执行

```
install Log::Log4perl
install Log::Dispatch::File
install YAML::Tiny
install File::HomeDir
```

再次 GFW 警告

进入项目目录，测试 latexindent.pl 是否可以正常运行，并设置为可全局调用（最简单的方式是写个 sh 文件，`cd youPathToLatexindent.pl && ./latexindent.pl`，然后将其链接到`/bin`或者`/usr/bin`）

#### 插件配置

只需在`init.vim`中添加

```
let g:neoformat_latex_latexindent ={'exe':'latexindent','args':[],'stdin':1}
let g:neoformat_enabled_latex=['latexindent']
```

用 prettier 格式化 markdown 失败，笔者暂时未解决该错误，可以使用[vim-prettier](https://github.com/prettier/vim-prettier)插件代替，或者手动运行`prettier --wirte pathToYourFile`

为不同类型的文件添加格式化快捷键

```
nnoremap <C-l> :Neoformat<CR>
autocmd FileType markdown nnoremap <buffer> <C-l> :Prettier<CR>
```
