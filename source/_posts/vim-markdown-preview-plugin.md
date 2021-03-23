---
title: Vim Markdown Preview Plugin
date: 2021-03-23 16:44:59
tags:
  - Vim
  - Markdown
categories:
  - Vim
---

# vim markdown预览插件

本文主要介绍 markdown 预览插件 vim-markdown-composer 以及 markdown-preview.nvim。

## markdown 预览

vim 没有内置 markdown 预览功能，也没有办法直接在终端预览。现有的 vim markdown 预览插件多是通过浏览器等第三方软件预览由插件渲染好的 markdown 文件。

在笔者的体验中 vim-markdown-composer 以及 markdown-preview.nvim 可以算是其中最好的两款预览插件。

## markdown-preview.nvim

参考其[github 主页](https://github.com/iamcco/markdown-preview.nvim)的安装配置信息，很容易搞定。

该插件的优点很明显。它支持很多内嵌语言的渲染，单文件渲染体验极佳。

这里主要强调一些问题（仅针对本文写成时存在的问题）。

- 目前尚未提供流畅的多文件预览功能。可以通过设置打开文件时预览自动开启和关闭文件时预览自动关闭勉强实现该功能。

> 这里的多文件指的是当在多个 buffer 切换的时候，可以自动切换预览画面。

- 判定文件开关的机制有点问题。主要表现在一旦使用自动开启和关闭预览。你在 vim 中使用的所有浮动窗口、侧边栏都会被判定为不同形式的文件关闭（经笔者试验，大概浮动窗口不会检测到文件关闭，但退出时会认为文件又一次打开，侧边栏会）。当退出这些窗口时，会再次自动渲染。这将使你的浏览器（或标签页）不断工作在开关状态，耗费资源还容易卡住，严重打击使用体验感。

- 无法重新载入资源。举个例子。当你打开预览之后，新截一张图，在文件中调用，预览将无法显示该图片，需要重启预览。

如果你无法忍受这些问题，可以使用下一个插件。

## vim-markdown-composer

该插件需要 rust 语言环境支持。关于如何配置 rust 环境，由于步骤非常简单，提倡自行解决。

参考其[github 主页](https://github.com/euclio/vim-markdown-composer)的配置，使用 vim-plug 的用户可以使用以下配置安装。

```vim
function! BuildComposer(info)
  if a:info.status != 'unchanged' || a:info.force
    if has('nvim')
      !cargo build --release --locked
    else
      !cargo build --release --locked --no-default-features --features json-rpc
    endif
  endif
endfunction

Plug 'euclio/vim-markdown-composer', { 'do': function('BuildComposer') }
```

安装后使用`:help markdown-composer`可以查看其文档。主要有几个配置参数，以及插件命令。这里给出插件提供的命令。

```
:ComposerStart              Start the preview server.
:ComposerUpdate             Send the current buffer to the preview server.
:ComposerOpen               Opens a new browser window containing the markdown preview.
:ComposerJob                Echoes the channel that the plugin is listening on.
```

可以自行配置快捷键。这里给出我的配置。

```vim
" markdown-composer
let g:markdown_composer_external_renderer='pandoc -f markdown -t html'
let g:markdown_composer_autostart = 0

nmap <silent><nowait><leader>ms :<C-u>ComposerStart<CR>
nmap <silent><nowait><leader>mu :<C-u>ComposerUpdate<CR>
nmap <silent><nowait><leader>mo :<C-u>ComposerOpen<CR>
nmap <silent><nowait><leader>mj :<C-u>ComposerJob<CR>

let g:which_key_map2.m = {
      \ 'name' : '+markdown_preview',
      \ 's' : 'start',
      \ 'u' : 'update',
      \ 'o' : 'open another tab',
      \ 'j' : 'echoes the channel that the plugin is listening on'
      \}
```

该插件多文件切换预览效果非常好。但是注意，该插件本身没有内置 latex 语言的渲染功能，其他语言就更不用说了。所以要想或者最佳体验，还需要使用外部渲染器。即上面给出配置中的第一行，使用 pandoc 渲染 markdown 文件。因此还必须安装 pandoc 软件，并确定可以在全局调用 pandoc 命令。

另有一个注意事项。假设有目录 X，内有二级目录 A 和 B。A 中存放 markdown 文件，B 中存放图片。如果在 A 目录内打开 markdown 文件，则还是会出现上一个插件新图片无法载入的问题（如果调用时使用绝对路径可能不会出现该问题）。如果在 X 目录下打开 A 中的 markdown 文件，则不会有上述问题。其他位置打开，应该都有该问题。
