---
title: Gentoo Kool Desktop Environment Installation
date: 2020-08-08 00:44:23
tags:
		- Gentoo
categories:
		- Gentoo
---

[Gentoo 教程目录](https://www.niuiic.top/2020/08/06/gentoo-tutorials-directory/)

# Gentoo KDE 桌面安装

本文以 kde 为例，介绍 gentoo 系统桌面安装流程。

kde 桌面的安装可参考[gentoo wiki](https://wiki.gentoo.org/wiki/KDE/)。

## 基本桌面环境安装

参考上面的链接，安装`kde-plasma`以及应用程序包。

```
systemctl enable sddm
```

## 安装使用 NetworkManager

- 安装

参考[gentoo wiki](https://wiki.gentoo.org/wiki/NetworkManager)。

- 允许用户使用

```
gpasswd -a <user_name> plugdev
```

- 开机启动

```
systemctl enable NetworkManager
```

重启，测试是否可以进入图形界面。

下一篇：[Gentoo System Further Improvement](https://www.niuiic.top/2020/08/08/gentoo-system-further-improvement/)
