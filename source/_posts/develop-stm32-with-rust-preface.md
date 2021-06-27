---
title: Develop Stm32 with Rust Preface
date: 2021-06-19 22:01:37
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 前言

本系列教程全部置于 stm32 专栏。

本文为使用 rust 开发 stm32 系列教程前言。

## Why Rust

1. Rust 特性就不用多介绍了，有个编译器管着有时候比用 C 到处浪把自己整没了好。
2. ST 官方逐渐停止对 C 固件库的更新，使用 MX 感觉没自己写舒服。毕竟它也就生成个初始化代码，虽然看起来挺快，但是实际上自定义 snippets 可以比它快得多。可能对于不熟悉当前开发板的用户来说可以省去一点看参考手册的麻烦。不过老手可能无所谓。
3. 尝鲜吧。
4. 折腾吧（又是和编译器斗智斗勇的一天）。

## 内容

1. 不会介绍单片机原理、各外设原理、数电、模电等。这些都可以找书搞定。
2. 介绍如何搭建 stm32 的开发环境。
3. 给出例程供参考使用。大部分例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。
4. 本教程定位在固件库的层面上。关于 rust 嵌入式底层的玩法请参考[Embedded Book](https://docs.rust-embedded.org/book/)。
5. 所有案例使用的 crate 都已暴露在程序中，去`crates.io`搜索，按照给出的建议写入`Cargo.toml`。主要注意的是各固件库发布的版本对案例程序而言可能较低，建议使用`git`指定仓库，不使用`version`。另外，部分外设，如`can`，需要开启相应的 feature 才可使用。

## 建议

### 硬件

开发板建议选用`stm32f3discovery`。不嫌贵的用`stm32f4discovery`也可以，`f7`就不要上了。因为这两款开发板被`tock os`支持，可以在上面使用这款用 rust 编写的 RTOS。

仿真器搞个 JTAG 接口的 ARM 仿真器就行，ST-LINK 感觉不太稳定（也可能是买到了盗版）。

### 软件

系统的话强烈建议使用 linux。

编辑器其实无所谓，vimer 自然推荐 vim，退一步选个 vscode，IDE 就算了。

使用 openocd 驱动仿真器。

使用 gdb 调试程序。

### 资源

1. stm32 的一堆参考手册
2. [Rust 论坛](https://users.rust-lang.org/)
3. [Tock os](https://www.tockos.org/)（一个产品级的 RTOS）
4. [Discovery Book](https://docs.rust-embedded.org/discovery/index.html)（for stm32f3discovery）
5. [Embedded Book](https://docs.rust-embedded.org/book/)
6. stm32fxxx-hal（固件库）
7. stm32fx（外设库，寄存器编程）
8. [RTIC](https://rtic.rs/0.5/book/en/)（不清楚这是什么的可以想象成 RTOS 的管理调度层）
9. [stm32-rs](https://github.com/stm32-rs/stm32-rs)
