---
title: Build aarch64 Cross Toolchain on Gentoo with Crossdev
date: 2021-03-23 18:23:01
tags:
		- Gentoo
categories:
		- Gentoo
---

# gentoo 使用 crossdev 建立 aarch64 交叉编译链

crossdev 和 aarch64 交叉编译链的安装指令很简单，网上随处可搜到。这里主要指出其中的一个 bug。即在编译 aarch64-linux-gnu glibc 时出现`no such instruction`的 bug。该错误的意思主要是缺少汇编指令。但是并不是 binutils 的问题，而是编译 glibc 时自动选择的编译器为 gcc（应该是遵照了`/etc/portage/make.conf`中的设置，没有自动换过来），而 gcc 在系统上指的是 x86_64 的 gcc。查看是否是该原因引起的错误，看日志文件中`CC`选项。修复该错误只需要在 crossdev 命令前加上`CC=aarch64-unknown-linux-gnu-gcc`。然后在编译`cross-aarch64-unknown-linux-gnu-gcc-stage2`时，再用回 x86_64 的 gcc。
