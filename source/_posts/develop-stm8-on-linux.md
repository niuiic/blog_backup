---
title: Develop Stm8 on Linux
date: 2021-06-23 15:20:26
tags:
  - Linux
  - Stm8
categories:
  - Embedded
---

# 在 linux 上开发 stm8

本文介绍如何在 linux（Gentoo）上开发 stm8。

## 硬件

1. stm8 开发板，比如 stm8s105k4 最小系统板。

2. stlink，USB 的那种总是连不上电脑，建议选择白色 20 针的那种。

3. 连接所需杜邦线。

> 接线时注意 stlink 上单独的 4 针是给 stm8 使用的，但是上面的电源引脚输出电平不对，将线插到 20 针部分的 VCC 引脚上。

## 软件

### sdcc

使用 sdcc 作为编译器。直接搜索如何安装即可。

### stm8-gdb

使用 stm8-gdb 作为调试器。按其[官网](https://stm8-binutils-gdb.sourceforge.io/)的介绍下载源文件。

编译之前先安装好 python3.6。如果是 python3.7 及以上版本则无法正常编译。原因是 gdb8.1 使用的一个 python 函数在 python3.7 中被修改。

将`configure_binutils.sh`文件中最后一行改为`./configure --host=$_HOST --target=stm8-none-elf32 $_PREFIX --program-prefix=stm8- --with-python=python3.6`。

然后按照 README 中的提示进行编译即可。

### openocd

使用 openocd 驱动仿真器。

### 编辑器

编辑器随意，建议 vim 或者 emacs。如果使用 vscode，可以尝试用其 stm8 debugger 插件（似乎是 windows only，没用过，可试一下）。

## 资源

### 库文件

由于权限限制，sdcc 并没有集成 stm8 的库，可以去 st 官网下载。

下载[Library](http://www.st.com/en/embedded-software/stsw-stm8069.html)。

解压后，在解压出来的目录下执行以下命令。

```sh
wget https://raw.githubusercontent.com/gicking/STM8-SPL_SDCC_patch/master/STM8S_StdPeriph_Lib_V2.3.1_sdcc.patch
patch -p0 < STM8S_StdPeriph_Lib_V2.3.1_sdcc.patch
```

然后自己看着用吧。

### 手册

去 st 官网下载参考手册和数据手册即可，另外从卖家那里要个原理图。

## 开发流程

这里不使用库文件，直接用寄存器编程。

首先在数据手册中找到各寄存器对应的内存地址，然后在`main.c`中定义。

```c
#define CLK_CKDIVR *(volatile unsigned char *)0x50C6
#define PD_ODR *(volatile unsigned char *)0x500F
#define PD_IDR *(volatile unsigned char *)0x5010
#define PD_DDR *(volatile unsigned char *)0x5011
#define PD_CR1 *(volatile unsigned char *)0x5012
#define PD_CR2 *(volatile unsigned char *)0x5013
```

sdcc 有自己特殊的定义方式，但是一般 lsp 识别不出来，会误报错，因此就不介绍了。

下面给出完整的`main.c`。

```c
// main.c

#include <stdint.h>

#define setbit(x, n) ((x) |= (1 << (n)));
#define rstbit(x, n) ((x) &= ~(1 << (n)));

#define CLK_CKDIVR *(volatile unsigned char *)0x50C6
#define PD_ODR *(volatile unsigned char *)0x500F
#define PD_IDR *(volatile unsigned char *)0x5010
#define PD_DDR *(volatile unsigned char *)0x5011
#define PD_CR1 *(volatile unsigned char *)0x5012
#define PD_CR2 *(volatile unsigned char *)0x5013

void delay(unsigned long count) {
  while (count--) {
    __asm__("nop");
  }
}

void main() {
  CLK_CKDIVR = 0;
  setbit(PD_DDR, 7);
  setbit(PD_CR1, 7);
  while (1) {
    setbit(PD_ODR, 7);
    delay(100000L);
    rstbit(PD_ODR, 7);
    delay(300000L);
  }
}
```

接下来使用 cmake 来管理项目（简单地写个 makefile 也足够了，这里是为了方便生成`compile_commands.json`给 lsp 使用）。

```cmake
# CMakeLists.txt

cmake_minimum_required(VERSION 3.20)

set(CMAKE_C_COMPILER sdcc)
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_OUTPUT_EXTENSION ".rel")

# Prevent default configuration
set(CMAKE_C_FLAGS_INIT "")
set(CMAKE_EXE_LINKER_FLAGS_INIT "")

# Disable C++
project(Test C)

set(CMAKE_C_FLAGS "-mstm8 --std-sdcc11 --debug --out-fmt-elf")
add_executable(main main.c)
```

`CMAKE_C_FLAGS`设置的参数会影响到调试，不要轻易修改。

接下来编译调试项目。

```sh
mkdir build
cd build
cmake .. -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=on
ninja
```

用 make 替代 ninja 也可以。

```sh
sudo openocd -f interface/stlink-dap.cfg -f target/stm8s105.cfg
```

另开一个终端，再次进入到 build 目录下。

```sh
stm8-gdb
target extended-remote :3333
monitor reset halt
file main.ihx
load
```

建议把每次必用的 gdb 命令写入`debug.gdb`。

```
target extended-remote :3333
monitor reset halt
file main.ihx
load
```

然后使用`stm8-gdb -q -x debug.gdb`。
