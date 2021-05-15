---
title: Use Realvnc on Manjaro on rpi4
date: 2021-05-15 21:58:56
tags:
  - Raspberry Pi
  - Manjaro
  - Realvnc
categories:
  - Raspberry Pi
---

# 在安装 manjaro 系统的树莓派上使用 realvnc

本文主要介绍如何在树莓派 4 上的 manjaro 或 arch 系统上使用 realvnc。如果设置不成功，也可以参考我的[另一篇文章](https://www.niuiic.top/2021/05/15/install-manjaro-on-rpi4/)使用 tigervnc 代替。

## 安装

```
yay -S aur/realvnc-vnc-server-aarch64
```

## 配置

注意，以下步骤是我在折腾时用到的，不一定全部有用，但设置完成后应该可以达到效果。

1. 设置`~/.vnc/config.d/vncserver-x11`文件，将`Authentication=SystemAuth`改为`Authentication=VncAuth`。如果原本没有，直接写上就行。
2. 使用`sudo vncpasswd -service`设置密码。
3. 设置开机启动 vnc。
   `sudo systemctl enable vncserver-x11-serviced.service sudo systemctl enable vncserver-virtuald.service`
4. 安装一个驱动。`yay -S xf86-video-dummy`
5. 修改`/etc/X11/xorg.conf.d/10-headless.conf`为以下内容。

```
Section "Monitor"
        Identifier "dummy_monitor"
        HorizSync 28.0-80.0
        VertRefresh 48.0-75.0
        Modeline "1920x1080" 172.80 1920 2040 2248 2576 1080 1081 1084 1118
EndSection

Section "Device"
        Identifier "dummy_card"
        VideoRam 256000
        Driver "dummy"
EndSection

Section "Screen"
        Identifier "dummy_screen"
        Device "dummy_card"
        Monitor "dummy_monitor"
        SubSection "Display"
        EndSubSection
EndSection
```

6. 允许用户使用`system-xorg`。`vncinitconfig -enable-system-xorg`。输出提示该发行版不支持 system-xorg。不用管他，继续设置就行。
7. 这里是设置分辨率，是最关键的一步。熟悉 vnc 的应该知道如果 vncserver 不知道分辨率就不能显示。而通过`raspi-config`修改分辨率在这两个系统上是无效的。因此需要修改`/etc/X11/vncserver-virtual-dummy.conf`，写入`gtf 1920 1080 60`。
