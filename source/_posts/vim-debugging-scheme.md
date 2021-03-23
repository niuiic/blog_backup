---
title: Vim Debugging Scheme
date: 2020-10-20 10:29:48
tags:
  - Vim
categories:
  - Vim
---

# vim 调试方案

本文介绍在 vim 中使用 vimspector 插件扩展 IDE 式调试功能，获取极致体验。

## 调试

- 为什么需要扩展调试功能？

虽然传统上与 vim 更匹配的调试方案是在命令行中使用 gdb、lldb 等调试器，但这就不得不暂时离开 vim。虽然有诸如 tmux、内置 terminal 等工具可以使得命令行调试变得更加方便，但具有 ui 界面，且就在 vim 中的调试无疑会更加直观。

- vimspector 插件的调试能力

可以查看其[github 主页](https://github.com/puremourning/vimspector)。包括可调试的语言、调试输出的信息、调试的主要界面等等均可以看到。可以说 vimspector 是一个相当专业的调试插件。

## vimspector 安装

可以参考官方提供的安装方式，也可以按照以下笔者推荐的方式安装。

首先，该插件需要被安装在`pack/x/opt`的目录下，如果想使用插件管理器安装，必须将安装目录修改为`xxx/pack/x/opt`。其中`xxx`是前一段的路径，可以不止一级，可以自定义，`x`是一级目录，可以为任意名称。然后在 vim 配置文件中，声明`set packpath= the_path_to_your_pack_directory`，只需要到`pack`的前一级目录即可。然后直接使用包管理器安装即可。至此，插件本身安装完毕。

## vimspector 配置

使用`:VimspectorInstall`来安装调试需要的适配器，如`:VimspectorInstall --enable-c`，具体参数可以在其主页找到。使用`:VimspectorUpdate`更新所有适配器。

安装好所需适配器之后，可以继续配置快捷键。可以使用官方提供的两套快捷键，也可以自定义。

使用官方快捷键可以设置`let g:vimspector_enable_mappings = 'HUMAN'`或者`let g:vimspector_enable_mappings = 'VISUAL_STUDIO'`。

如果要自定义，以下配置仅供参考。

```vim
nmap <silent><nowait><space>dn <Plug>VimspectorStepOver
nmap <A-n> <Plug>VimspectorStepOver
nmap <silent><nowait><space>db <Plug>VimspectorToggleBreakpoint
nmap <A-b> <Plug>VimspectorToggleBreakpoint
nmap <silent><nowait><space>ds <Plug>VimspectorContinue
nmap <silent><nowait><space>dr <Plug>VimspectorRestart
nmap <silent><nowait><space>dp <Plug>VimspectorPause
nmap <silent><nowait><space>dt <Plug>VimspectorStop
nmap <silent><nowait><space>df <Plug>VimspectorAddFunctionBreakpoint
nmap <silent><nowait><space>dc <Plug>VimspectorToggleConditionalBreakpoint
nmap <silent><nowait><space>do <Plug>VimspectorStepOut
nmap <A-o> <Plug>VimspectorStepOut
nmap <silent><nowait><space>di <Plug>VimspectorStepInto
nmap <A-i> <Plug>VimspectorStepInto
nmap <silent><nowait><space>dq <Plug>VimspectorReset<CR>
nmap <silent><nowait><space>dlc <Plug>VimspectorShowOutput Console<CR>
nmap <silent><nowait><space>dld <Plug>VimspectorShowOutput stderr<CR>
nmap <silent><nowait><space>dlo <Plug>VimspectorShowOutput Vimspector-out<CR>
nmap <silent><nowait><space>dle <Plug>VimspectorShowOutput Vimspector-err<CR>
nmap <silent><nowait><space>dls <Plug>VimspectorShowOutput server<CR>
nmap <silent><nowait><space>dlt <Plug>VimspectorShowOutput Telemetry<CR>
nmap <silent><nowait><space>de :<C-u>VimspectorEval<space>
nmap <silent><nowait><space>dw :<C-u>VimspectorWatch<space>
nmap <A-w> :<C-u>VimspectorWatch<space>

let g:which_key_map1.d = {
			\ 'name' : '+debug',
			\ 'e' : 'eval',
			\ 'w' : 'variable watch',
			\ 's' : 'start or continue',
			\ 't' : 'stop',
			\ 'r' : 'restart',
			\ 'p' : 'pause',
			\ 'b' : 'set breakpoint',
			\ 'c' : 'set condition breakpoint',
			\ 'f' : 'add function breakpoint',
			\ 'n' : 'next',
			\ 'i' : 'step in',
			\ 'o' : 'step out',
			\ 'q' : 'quit',
			\ 'l' :  {
			\ 'name' : '+switch_output',
			\ 'c' : 'Console',
			\ 'd' : 'stderr',
			\ 'o' : 'Vimspector-out',
			\ 'e' : 'Vimspector-err',
			\ 's' : 'server',
			\ 't' : 'Telemetry',
			\},
			\}
```

注意 vimspector 的一些功能暂不支持 neovim，这一点在主页上有说明。不过并不影响使用。以上配置中这些部分就是在 neovim 中用于切换窗口的命令和快捷键。

```vim
nmap <silent><nowait><space>dlc <Plug>VimspectorShowOutput Console<CR>
nmap <silent><nowait><space>dld <Plug>VimspectorShowOutput stderr<CR>
nmap <silent><nowait><space>dlo <Plug>VimspectorShowOutput Vimspector-out<CR>
nmap <silent><nowait><space>dle <Plug>VimspectorShowOutput Vimspector-err<CR>
nmap <silent><nowait><space>dls <Plug>VimspectorShowOutput server<CR>
nmap <silent><nowait><space>dlt <Plug>VimspectorShowOutput Telemetry<CR>
```

到此为止，该插件仍不可以使用，还差最后一步。

该插件本身的配置文件有两种，一是`.gadgets.json`，二是`.vimspector.json`。前面安装适配器的过程中已经自动产生了不少配置。关于这些配置文件的具体内容和关系可以自行研究，这里只介绍如何完成最后一步配置。

在工程项目目录下新建`.vimspector.json`文件。copy 插件主页上给出的示例配置。

以 rust 语言为例，给出的示例配置为

```json
{
  "configurations": {
    "launch": {
      "adapter": "CodeLLDB",
      "configuration": {
        "request": "launch",
        "program": "${workspaceRoot}/target/debug/vimspector_test"
      }
    }
  }
}
```

只需要修改`program`的值为可执行文件路径即可。至此，所有配置均已完成。

最后注意一点，这个配置下插件并不会自动调用编译器编译工程。因此还需要手动编译生成可执行文件。

另外，该插件也可以监听端口，调试进程，有需要的可以自行研究。
