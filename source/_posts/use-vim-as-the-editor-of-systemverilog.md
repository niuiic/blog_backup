---
title: Use Vim as the Editor of Systemverilog
date: 2021-03-23 16:42:41
tags:
  - Vim
categories:
  - [Vim]
  - [Embedded]
---

# 使用 vim 作为 systemverilog 编辑器

本文介绍如何使用 vim 搭建 systemverilog 编辑环境。功能包括自动补全、语法高亮、语法检查、格式化等。

注意本文内容只是针对 systemverilog 提供最基本编辑体验。关于 vim 的其他功能配置，请见[vim 专栏](https://www.niuiic.top/categories/Vim/)。

## 语法高亮

最新版的 neovim 应该默认支持 systemverilog 语法高亮。如果你的 vim 不行的话可以尝试通过安装`vhda/verilog_systemverilog.vim`插件解决。

## 自动补全与语法检查

自动补全功能使用 lsp。本文选用 svls 作为 systemverilog 的语言服务器。

svls 使用 rust 语言编写，需要 rust 语言环境，使用 rust 包管理器 cargo 安装。或者可以从 snap 商店下载。

选择一款管理调用 lsp 的 vim 插件。本文选用 coc.nvim。在 coc.nvim 的配置文件中添加以下内容。

```json
"languageserver": {
    "svls": {
        "command": "svls",
        "filetypes": ["systemverilog"]
    }
}
```

注意，`filetypes`不一定正确。可以新建一个.sv 文件，查看文件类型。比如，在 neovim5 的某一版本中，文件类型为`verilog_systemverilog`。

选用其他插件的可以在[svls github 主页](https://github.com/dalance/svls)找到相应配置。

svls 的配置文件为`.svls.toml`，该文件放在项目的根目录。配置文件的编写方式非常简单。

```toml
[verilog]
include_paths = ["src/header"]

[option]
linter = true
```

将以上`include_paths`的值修改为要编写的.sv 文件所在目录即可。

关于语法检查功能，可以同时使用 ale 插件。该插件可以通过 iverilog 编译器提供错误信息，两者错误信息并不完全重合。

虽然在`svls`的演示视频中存在 snippets 的补全画面，但是经过试用发现这似乎是其他插件提供的。但是`vim-snippets`插件提供的 snippets 非常不全，因此下面介绍简单的自定义 snippets。

首先，需要`coc-snippets`插件，该插件依赖`coc.nvim`。安装好`coc.nvim`之后，只需要使用`:CocInstall coc-snippets`命令即可安装。具体设置可以参考其[github 主页](https://github.com/neoclide/coc-snippets)。安装该插件后需要同步安装`honza/vim-snippets`来提供 snippets。`SirVer/ultisnips`需要拆卸掉，因为该插件会对自定义的 snippets 文件报错。

接下来，使用`:CocConfig`打开`coc.nvim`配置文件，设置自定义 snippets 文件路径。如`"snippets.userSnippetsDirectory": "/home/niuiic/.config/nvim/snippets"`。（注意这是个 json 文件，最外层需要花括号）

然后就可以在该目录下自定义 snippets 文件，文件名称保持和文件类型相同即可。snippets 语法还是比较复杂的，下面给出一个简单例子，足以实现基本功能。更高级的功能请自行学习。（coc.nvim 提供的自动补全筛选能力已经足够强大，即使是简单的设置也可以带来极佳的体验。更复杂的设置个人觉得没有必要。）

`systemverilog.snippets`

```
# nomal always
snippet alw
	always @(${0}) begin

	end
```

`alw`是缩写，也就是当你打出 alw 时可以调用该 snippets。`${0}`的作用比较复杂，最简单也是对新手来说最实用的作用就是当你添加这一项后，补全 snippets 之后光标会自动停留在这个位置。

如果再加一项，如下。

```
# nomal always
snippet alw
	always @(${1}) begin
		${0}
	end
```

此时光标会停留在`${1}`的位置。

按照上述例子继续补充自己想要的 snippets 即可。注意标准写法中应当是用`endsnippet`的，不过这插件似乎不需要这个，而且加上这一句之后反而会出现在补全内容中，因此还是不加为好。

除了 snippets，svls 能提供的自动补全功能感觉还是差点意思的。继续使用`coc.nvim`定义自动补全库。

新建目录`～/.config/nvim/autoload/coc/source`。在该目录下新建文件`systemverilog.vim`，文件名原则同上。

内容如下。

```
function! coc#source#systemverilog#init() abort
    return {
        \'triggerCharacters': [''],
        \'filetypes' : ['systemverilog'],
        \}
endfunction

function! coc#source#systemverilog#complete(opt, cb) abort
    let items = ['reg', 'wire', 'forever', 'posedge', 'negedge', 'module', 'endmodule', 'initial', 'input', 'output', 'parameter', 'assign', 'integer']
    call a:cb(items)
endfunction
```

在`items`中添加需要补全的关键词即可。注意这里的补全内容不能解析任何换行字符或转译字符，所以关键词放这里，语句放之前的 snippets。

至此，完成自动补全与语法检查功能的配置。

## 格式化

systemverilog 的格式化需要[verible](https://github.com/google/verible)的支持。verible 为 google 为 systemverilog 开发的一套工具集，其中包含了格式化工具。

verible 提供了.deb 和.rpm 的二进制包，包管理系统兼容该两种打包方式的用户可以直接安装。

其他用户需要自行编译，从 github 上拉取源码后，在源码目录使用`bazel build -c opt //...`编译。注意需要支持 C++11 的 gcc 编译器（clang 暂时无法编译成功）。

编译完成后，使用`bazel run -c opt :install -- path`安装到指定位置。如果安装位置需要 root 权限，则使用`bazel run -c opt :install -- -s path`，务必注意不能使用 sudo。

在 vim 中调用格式化工具的插件选用 neoformat。该插件的安装过程不再赘述。调用格式化程序的配置方式在其文档中有详细说明，这里只给出一个例子。

环境：neovim、linux

创建`~/.local/share/nvim/site/autoload/neoformat/formatters`目录。编写`systemverilog.vim`，写入以下内容

```vim
function! neoformat#formatters#systemverilog#enabled() abort
    return ['verible_format']
endfunction

function! neoformat#formatters#systemverilog#verible_format() abort
    return {
        \ 'exe': '/opt/verible/verilog_format',
        \ }
endfunction
```

注意文件名称是 vim 中 systemverilog 的文件类型。如果不是`systemverilog`则需要替换文件名及文件中所有出现`systemverilog`的地方。`exe`需要可执行，即如果格式化程序所在目录不在`$PATH`中，需要填写其绝对路径。

## 总结

以上方案对比 vscode 以及各类 IDE，如 vivado 等，在编辑体验上可以算是完胜。

vscode 中虽然有基于 svls 的插件，以及语言格式化插件，但整体补全能力上比不上高度扩展的 vim。并且仅仅依靠 svls 的错误检查，并不能找出所有错误（语法错误，而非逻辑错误），但 vim 可以再叠加其他的检测，如 ale。

各类 IDE 虽然功能非常强大，甚至可能只需使用图形界面配置就能自动生成 systemverilog 文件，但是在编辑体验上远远比不上前两者。
