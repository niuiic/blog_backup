---
title: Better Use of Rust on Gentoo
date: 2021-04-24 21:26:57
tags:
		- Gentoo
categories:
		- Gentoo
---

# 在 gentoo 上更好地使用 rust

本文介绍在 gentoo 上避开 portage 使用 rust 的方法以及 rust 编译缓存的设置。

## 使用官方 rust

rust 官方提供的 rust 安装方式为`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`。你可以使用该命令安装官方 rust 工具链。但是 gentoo 系统并不会自动识别你安装的 rust。因此在安装一些由 rust 编译的软件时，包管理系统依旧会先编译 rust。之所以不推荐使用系统编译的 rust，主要还是编译耗时太长，对于需要多个版本编译链的用户并不友好。接下来，说明如何使包管理系统识别到用户自己安装的 rust。

首先，执行以下命令。

```shell
sudo mkdir -p /etc/portage/profile/package.provided
```

该目录用于向包管理系统标记已经安装的程序。

编辑`/etc/portage/profile/package.provided/rust`，写入已经存在的程序。

```
dev-lang/rust-1.50.0
virtual/rust-1.50.0
dev-util/cargo-1.50.0
dev-util/rustup-1.23.0
```

注意，必须指明版本，查看当前软件的版本写入即可，之后如果有升级也不必修改，除非软件依赖要求更高版本。

编辑`/etc/portage/profile/profile.bashrc`，写入已安装的这些软件的路径。

```shell
export PATH="/home/yourname/.cargo/bin:$PATH"

STABLE=/home/yourname/.rustup/toolchains/stable-x86_64-unknown-linux-gnu
rustup toolchain link build-stable $STABLE &> /dev/null
rustup default build-stable &> /dev/null
```

建议使用 stable 版本的工具链。另外使用自己的用户名。

至此，包管理系统已经可以自动识别并使用用户自行安装的 rust，如果不放心，你也可以进一步 mask 掉这些包。

## rust 编译缓存

C、C++的编译可以使用 ccache 作为缓存器，这样下次编译时会调用本次的成果，可以大大节省编译时间。对于 rust 而言，这个工具是 sccache。

执行以下命令。

```shell
emerge --ask dev-util/sccache
mkdir -p /var/cache/sccache
chown root:portage /var/cache/sccache
chmod 2775 /var/cache/sccache
```

编辑`/etc/sandbox.d/20sccache`，写入

```
SANDBOX_WRITE="/var/cache/sccache/"
```

编辑`/etc/portage/make.conf`，写入

```
RUSTC_WRAPPER=/usr/bin/sccache
SCCACHE_DIR=/var/cache/sccache
SCCACHE_MAX_FRAME_LENGTH=104857600
```
