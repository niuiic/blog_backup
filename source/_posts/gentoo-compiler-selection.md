---
title: Gentoo Compiler Selection
date: 2020-08-05 22:50:35
tags:
        - Gentoo
categories:
        - Gentoo
---

[Gentoo教程目录](https://www.niuiic.top/2020/08/06/gentoo-tutorials-directory/)

# Gentoo 编译器选择

本文介绍构建 gentoo 系统的编译器选择方案，及一些尤其引起的 bug 的解决方案，不涉及选择编译器的专业观点。

## 简介

众所周知 Gentoo 系统完全在本地构建。因此编译器的选择很大程度上决定了编译系统的耗时以及整个系统的性能。

用于构建整个 Gentoo 系统的编译器只推荐两个，gcc 与 clang。

gcc 由 GNU 出品，与 GNU linux 自然匹配度更高。因此选择 gcc 作为编译器是最稳妥的方案。

clang 被苹果公司支持，近年来发展速度迅速，也具备许多 gcc 不具备的特性。但 clang 编译 linux 系统尚不稳定。

目前，绝大多数使用 clang 编译出错的 bug 已有解决方案。但部分软件，比如 gcc、linux 内核等必须使用 gcc 构建。因此即便你选择 clang 作为主编译器，也必须保留 gcc 作为辅助编译器。

## 使用 gcc 作为主编译器

gcc 是 gentoo 的默认编译器，且比较稳定，这里不作太多说明。

只是需要注意一点，测试分支的 gcc 存在许多不稳定因素，可能会造成编译错误。考虑到编译器对于系统的重要性，强烈建议保留稳定分支的 gcc。

- gcc 版本选择

```
# 查看系统中的gcc版本
gcc-config --list-profiles
# 选择需要的gcc
gcc-config number
# 刷新配置
source /etc/profile
```

## 使用 clang 作为主编译器

详见[gentoo wiki](https://wiki.gentoo.org/wiki/Clang)

关于 clang 的安装，可以参考上面的链接。这里主要介绍将 clang 作为主编译器的必要配置。

首先，在`make.conf`中作如下设置。

```
CC = clang
CXX = clang++
```

此时，clang 已经成为系统的默认编译器。接下来设置备选方案，即当软件无法用 clang 编译时，使用 gcc 编译。

在`/etc/portage/env`目录下创建`compiler-gcc`，写入

```
CC = gcc
CXX = g++
```

然后在`/etc/portage/package.env`文件中写入如`sys-devel/gcc compiler-gcc`的内容，即可将该包的编译器设置为 gcc。

这一步可以通过`app-portage/flaggie`工具自动完成。其指令为`flaggie app-foo/bar +compiler-gcc`。

至此，配置完毕。当发现 clang 无法编译某软件而 gcc 可行时只需将其加入上述文件即可。

## 编译选项

这里的编译选项主要指优化选项。为提高系统性能，你可以设置编译优化选项。但由此带来的问题是编译时间大大增长，更容易遇到 bug，过多的或者不合理的优化选项导致性能反而下降。

这里不介绍配置优化选项的具体内容，只通过大致的感受给出一个建议。基于亲身体会，优化与不优化差别并不大，至少以人的感官很难感觉出来。因此这里建议新手不要开启优化选项，至少是过多的优化选项，除非你是为了折腾。

就前文提到的 gcc 备选方案的配置，你也可以将其运用到为具体的包选择性开启优化选项。比如编辑`/etc/portage/env/compiler-gcc-flto`。

```
CC="gcc"
CXX="g++"
CFLAGS="-flto -march=native -O2 -pipe"
CXXFLAGS="${CFLAGS}"
AR="gcc-ar"
NM="gcc-nm"
RANLIB="gcc-ranlib"
```

再在`/etc/portage/package.env`中设置包的编译方案即可。

下一篇：[Gentoo Compile Error Handling](https://www.niuiic.top/2020/08/06/gentoo-compile-error-handling/)
