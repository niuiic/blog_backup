---
title: Install rpm/deb Packages on Gentoo
date: 2021-03-23 18:28:40
tags:
		- Gentoo
categories:
		- Gentoo
---

# 在 gentoo 系统上“安装” deb/rpm 包

## 安装原理

众所周知，与本系统包管理体系不相容的安装包不能安装在系统上。但这里的情况分两种。

第一种，安装包内可执行文件编译时对应的架构与你的系统不同。比如你不能将 arm 架构下的软件直接跑在 amd64 的系统上。这种情况属于无解，除非自己做一个中间层。

第二种，仅仅是安装包的打包方式不同。如 deb 和 rpm。对于这种情况，完全可以将安装包拆解，然后手动将解压出来的文件放到该放的位置。这样，软件依旧可以运行，也就变相地完成了”安装“。但这并不意味着所有安装包都可以采用这种方式安装，需要解决的最大问题就是依赖。

## 安装流程

这里以 utools 为例，仅介绍安装流程，不包括如何补全依赖。

该软件只提供了 deb 安装包。

首先获得 deb 安装包。

然后，解压安装包。

解压后可以看到两个目录，control 和 data。data 目录下有 usr 和 opt 两个子目录。显然，这里存放了应该被放入系统 usr 和 opt 目录下的文件。

一般这种软件都会自动创建一个快捷方式，即.desktop 文件。先找到这个文件。utools 的 utools.desktop 文件（已修改）如下。

```
[Desktop Entry]
Name=uTools
Exec=/opt/utools/data/opt/uTools/utools
Terminal=false
Type=Application
Icon=/opt/utools/data/usr/share/icons/hicolor/512x512/apps/utools.png
StartupWMClass=uTools
Comment=你的生产力工具集
Categories=System;
```

上面的文件内容是修改后的。修改之前，你可以通过`Exec`这一行看到可执行文件的位置。

找到可执行文件，直接在当前目录下运行一下，如`./utools`。如果软件可以跑起来，那基本上可以确定该软件不缺依赖，且可以直接通过相对位置找到它的配置文件等文件。对于这样的软件，建议不要直接将文件放到 usr 和 opt 下，因为这样将很难维护该软件。可以直接将整个解压出来的目录放到/opt 目录下，如/opt/utools。

将.desktop 文件修改后，放到`~/.local/share/applications`目录或者`/usr/share/applications`目录下。一般`/usr/share/applications`目录必是存放.desktop 文件的目录，前者可能因为系统或设置不同而不同。注意必须把文件修改好之后再放入。如果先放再修改，可能修改会无效，这可能是桌面环境设置造成的问题。

至此，该软件安装已经完成。

整个步骤中最关键的一步是运行可执行文件时可以运行起来，如果不能，就需要手动补全依赖或者排查其他问题。

此外，一些系统上有一些包转换工具，如 arch，可以使用特定的软件将 deb 包等转化为 arch 的安装包。如果存在该类软件（gentoo 系统由于发行源代码，可以说不存在安装包，所以也不会有这种工具），尽量采用这种方式。如果想要或者更好的维护体验，可以自己写个 ebuild。
