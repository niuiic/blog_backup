---
title: Debug Msp430g2 Project on Linux
date: 2021-03-23 18:26:43
tags:
		- MSP430G2
		- Linux
categories:
		- Embedded
---

# 在 linux 上 对 MSP430G2 系列工程进行调试

Warning : 此方案体验太差，笔者已经弃坑了，有兴趣的可以继续折腾，等待社区推出更好的 gcc。

本文介绍如何在 linux 系统上对 MSP430 程序进行 debug。包括程序的编译、下载、运行、调试以及 vim 编辑器自动补全设置。

## 工具

在本方案中，需要用到的主要工具包括 TI 官方提供的 IDE——CCS，mspdebug，msp430-elf-gdb，vim/neovim。

注意，CCS 的 linux 版本不支持连接 MSP430G2 系列的开发板，否则就没那么多麻烦了。在本方案中，该 IDE 只作为编译工具使用。

TI 官方提供的 msp430-gcc 虽然可以编译程序，但是缺少部分头文件。下面将介绍配置 GCC 的相关内容，但不建议作为编译工具使用。

## 配置

### 安装工具

安装 CCS、mspdebug。很简单，过程略。

关于 CCS 的使用，由于只需要用来做编译器，更好的选择是使用命令行操作，避免开启图形界面，具体上网搜即可。

msp430-elf-gdb 可以从 TI 官方提供的 msp430-gcc 编译工具链中获得，也可以自己编译。自己编译的过程如下。

在 GNU 官网下载最版本 gdb。解压，进入目录。

```shell
# target是架构，不需要修改
# prefix将决定最终安装gdb的位置，可以自行修改
./configure --prefix="${PREFIX}" --target=msp430-elf
make
sudo make install
```

如果要拆卸 gdb，需要进入编译好后的目录中所有的子目录，执行`sudo make uninstall`。

编辑器可以自由选择，本文介绍时使用 neovim。

### msp430-gcc

如果想要尝试 gcc，可以参考以下步骤。

首先，在 TI 官网下载 msp430-gcc 及其 support-files。gcc 下载压缩包即可，不需要下载安装工具。

解压两个下载包。将 support-files 中所有的.h 与.ld 文件复制到 gcc 的 msp430-elf/include 目录以及 msp430-elf/lib 目录下。这里如果想少一点麻烦就不要参考官方教程将文件放到 include/device，直接按前述操作完成即可。

至此，gcc 配置完毕，只是仍然缺少部分头文件。如`delay_cycles`函数未定义。

想要用 gcc 编译，可以进入 msp430gcc 目录，使用`./bin/msp430-elf-gcc -I ./msp430-elf/include -mmcu=msp430g2553 -c main.c`编译。注意，必须指定微处理器的具体型号，且不要指明 lib 路径（设定处理器型号后 gcc 会自动调用链接器，不需要指明，指明后有冲突，这是前面放置头文件操作引起的）。

这样可以成功得到可执行文件。

需要注意的是，如果不介意官网提供的 gcc 版本较低，尽量使用官网的版本。自己编译的 gcc 缺少头文件等问题的情况只会更严重。如 gentoo crossdev 中编译而成的 msp430-elf-gcc，进行上述操作添加头文件后，虽然可以编译程序，但实际上是错误编译，这些可执行文件不可实际运行。这种情况下还需要做更多的处理。

### 编辑器自动补全与语法检查

neovim 可以使用 coc.nvim，并安装 coc-clangd 插件。对于其他编辑器而言，也可以使用类似的 lsp。通用的一点是`compile_commands.json`文件，这决定了 lsp 补全与检查的依据。该文件可以使用工具从 makefile 或 CMakeList.txt 生成。

什么都不会也没有关系，直接写就行，只需要七行即可。

```json
[
  {
    "directory": "工作目录路径",
    "command": "编译指令，可以借用一下ccs内置的gcc，把头文件和微处理器型号写入，可参考上面的gcc编译命令",
    "file": "需要编译的文件，如./main.c"
  }
]
```

将其置于工程目录下即可。

建议将 ccs 安装目录中所有头文件复制到一个目录下，使用`-I`指定该目录即可。对于部分缺少的定义，可以自行在该目录下的头文件中添加，这样也不影响 ccs 编译程序。这里关于缺少的定义稍微解释一下。举个常见的例子，如`__intertupt`。如果你使用它，lsp 会报未定义错误，但是在 ccs 编译器中不会发生，且可以成功编译。查找所有的头文件，确实没有定义。这个时候就可以手动加上，骗过 lsp。如调用了"msp430g2553.h"，则在该头文件末尾加上`define __intertupt`。

## 程序烧录与运行

得到可执行文件后，使用 mspdebug 工具进行烧录。

```
sudo mspdebug rf2500
# 进入mspdebug界面
load your_file
# 或者
prog your_file
# 运行程序
run
# 擦除程序
erase
```

## 程序调试

```
sudo mspdebug rf2500
gdb
# 在另一个终端窗口启动gdb，具体命令看自己的gdb名称
msp430-elf-gdb
# 进入gdb界面
# 监听上面mspdebug提供的调试端口
target remote localhost:2000

# moniter后加的命令相当于mspdebug下执行的命令
moniter prog your_file

file your_file

# 使用continue运行程序，不可使用run
c
# 其他调试自我发挥
```

> 可以使用 gdb 打断点，单步调试等等。但是无法查看变量值，更无法查看寄存器的值。对于调试而言，基本上是个废的。
