---
title: Use Vim as the Editor of Systemverilog
date: 2021-03-23 16:42:41
tags:
  - Vim
categories:
  - Vim
---

# 使用vim作为systemverilog编辑器

本文介绍如何使用 vim 搭建 systemverilog 编辑环境。功能包括自动补全、语法高亮、语法检查、格式化等。

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

注意，`filetypes`不一定正确。可以新建一个.sv 文件，查看文件类型。比如，在 neovim5 中，文件类型为`verilog_systemverilog`。

选用其他插件的可以在[svls github 主页](https://github.com/dalance/svls)找到相应配置。

svls 的配置文件为`.svls.toml`，该文件放在项目的根目录。配置文件的编写方式非常简单。

```toml
[verilog]
include_paths = ["src/header"]

[option]
linter = true
```

将以上`include_paths`的值修改为要编写的.sv 文件所在目录即可。

至此，完成自动补全与语法检查功能的配置。

关于语法检查功能，可以同时使用 ale 插件。该插件可以通过 iverilog 编译器提供错误信息，两者错误信息并不完全重合。

## 格式化

systemverilog 的格式化需要[verible](https://github.com/google/verible)的支持。verible 为 google 为 systemverilog 开发的一套工具集，其中包含了格式化工具。

verible 提供了.deb 和.rpm 的二进制包，包管理系统兼容该两种打包方式的用户可以直接安装。

其他用户需要自行编译，从 github 上拉取源码后，在源码目录使用`bazel build -c opt //...`编译。注意需要支持 C++11 的 gcc 编译器（clang 暂时无法编译成功）。

编译完成后，使用`bazel run -c opt :install -- path`安装到指定位置。如果安装位置需要 root 权限，则使用`bazel run -c opt :install -- -s path`，务必注意不能使用 sudo。

在 vim 中调用格式化工具的插件选用 neoformat。该插件的安装过程不再赘述。调用格式化程序的配置方式在其文档中有详细说明，这里只给出一个例子。

环境：neovim、linux

创建`~/.local/share/nvim/site/autoload/neoformat/formatters`目录。编写`verilog_systemverilog.vim`，写入以下内容

```vim
function! neoformat#formatters#verilog_systemverilog#enabled() abort
    return ['verible_format']
endfunction

function! neoformat#formatters#verilog_systemverilog#verible_format() abort
    return {
        \ 'exe': '/opt/verible/verilog_format',
        \ }
endfunction
```

注意文件名称是 vim 中 systemverilog 的文件类型。如果不是`verilog_systemverilog`则需要替换文件名及文件中所有出现`verilog_systemverilog`的地方。`exe`需要可执行，即如果格式化程序所在目录不在`$PATH`中，需要填写其绝对路径。

## 总结

以上方案对比 vscode 以及各类 IDE，如 vivado 等，在编辑体验上可以算是完胜。

vscode 中虽然有基于 svls 的插件，以及语言格式化插件，但整体补全能力上比不上高度扩展的 vim。并且仅仅依靠 svls 的错误检查，并不能找出所有错误（语法错误，而非逻辑错误），但 vim 可以再叠加其他的检测，如 ale。

各类 IDE 虽然功能非常强大，甚至可能只需使用图形界面配置就能自动生成 systemverilog 文件，但是在编辑体验上远远比不上前两者。
