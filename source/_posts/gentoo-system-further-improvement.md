---
title: Gentoo System Further Improvement
date: 2020-08-08 09:44:38
tags:
		- Gentoo
categories:
		- Gentoo
---

[Gentoo 教程目录](https://www.niuiic.top/2020/08/06/gentoo-tutorials-directory/)

# Gentoo 系统完善

本文介绍 gentoo 系统的进一步完善。主要包括一些软件的安装和一些系统配置。

## 添加 gentoo-zh overlay

gentoo-zh 包含了许多国内常用的软件。

```
emerge eselect-repository
eselect repository add gentoo-zh git https://github.com/microcai/gentoo-zh
eix-sync
# 或者可以直接使用layman
```

如果同步时发生错误`Main gentoo tree does not appear to have changed: exiting`，可以`rm -rf /var/db/repos/*`或者`eix-sync -a`解决。

## 字体配置

- 安装 fontconfig

添加 USE flag`static-libs`

`emerge media-libs/fontconfig`

更多配置见[gentoo wiki fontdconfig](https://wiki.gentoo.org/wiki/Fontconfig)。

- 安装字体（不需要全部安装）

```
emerge media-fonts/font-isas-misc
emerge media-fonts/arphicfonts
emerge media-fonts/opendesktop-fonts
emerge media-fonts/wqy-zenhei
emerge media-fonts/zh-kcfonts
```

- 激活字体

```
# 查看字体配置文件
eselect fontconfig list
# 激活上面安装的字体
eselect fontconfig enable number
```

- （可选）将区域改为中文

```
# 列出可用的区域
eselect locale list
# 选择中文区域的编号
eselect locale set 5
```

- 设置桌面使用中文语言

值得注意的是 kde 桌面不能完全汉化。如果你不能接受，干脆用全英文。

```
nvim ~/.xprofile

export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:en_US
```

## 输入法

这里选用 fcitx5 作为输入法。

- 安装输入法

```
# 编辑/etc/portage/package.accept_keywords/fcitx5，加入

=app-i18n/fcitx5-999999999 **
=app-i18n/kcm-fcitx5-99999999 **
=app-i18n/fcitx5-qt-9999999999 **
app-i18n/fcitx5-chinese-addons
=app-i18n/libime-99999999 **
=x11-libs/xcb-imdkit-99999999999 **
=app-i18n/cldr-emoji-annotation-9999 **
=app-i18n/fcitx5-gtk-999999999 **
```

```
emerge boost
emerge xcb-imdkit cldr-emoji-annotation fcitx5 kcm-fcitx5 fcitx5-qt fcitx5-chinese-addons libime fcitx5-gtk
```

其中`app-text/enchant-1.6.1-r1`编译失败的解决方案为设置 CC 和 CXX 为

```
CC=x86_64-pc-linux-gnu-gcc
CXX=x86_64-pc-linux-gnu-g++
```

libime 如果编译失败，可尝试修改`=app-i18n/libime-99999999 **`为`app-i18n/libime`（`fcitx5-chinese-addons`失败同理）。

```
# 修改~/.xprofile

export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS="@im=fcitx"

```

```
mkdir ~/.config/autostart
cp /usr/share/applications/fcitx5.desktop ~/.config/autostart

# 自启动也可以在系统设置 start and shutdown 中设置
```

- 安装主题

先关闭 fcitx5

```
mkdir -p ~/.local/share/fcitx5/themes/Material-Color

# 以hosxy/Fcitx5-Material-Color为例

git clone https://github.com/hosxy/Fcitx5-Material-Color.git ~/.local/share/fcitx5/themes/Material-Color

cd ~/.local/share/fcitx5/themes/Material-Color

ln -sf ./panel-teal.png panel.png

ln -sf ./highlight-teal.png highlight.png

# 修改~/.config/fcitx5/conf/classicui.conf

Vertical Candidate List=False
PerScreenDPI=True
Theme=Material-Color
```

更多配置可以直接在`kcm-fcitx5`中配置。

## tlp

```
eselect repository add tlp git https://github.com/dywisor/tlp-portage

# 修改/etc/portage/package.accept_keywords/tlp

app-laptop/tlp
sys-power/linux-x86-power-tools

# 安装

emerge tlp
systemctl enable tlp
```

## zsh

```
emerge zsh
# 设置zsh为默认shell
chsh -s /bin/zsh
# 查看当前shell
echo $SHELL
# 安装oh-my-zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
# 配置oh-my-zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

nvim ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=’fg=20’

nvim ~/.zshrc
# 设置主题
ZSH_THEME="ys"
# 设置插件
plugins=(git z zsh-syntax-highlighting zsh-autosuggestions extract vi-mode)

source ~/.zshrc
```

## 键盘映射

```
emerge xmodmap
xmodmap -pke > ~/.Xmodmap
# 修改 ~/.Xmodmap，具体配置自行查询。
xmodmap ~/.Xmodmap # 用ssh连接是无法启动的，需要在主机上执行
```

### 触控板手势配置

```
sudo gpasswd -a $USER input
emerge x11-misc/libinput-gestures
libinput-gestures-setup autostart

# 查看dev-libs/libinput和x11-drivers/xf86-input-libinput以及x11-misc/xdotool是否缺失，缺则补

mkdir /etc/X11/xorg.conf.d
cp /usr/share/X11/xorg.conf.d/40-libinput.conf /etc/X11/xorg.conf.d/40-libinput.conf
cp /etc/libinput-gestures.conf ~/.config/libinput-gestures.conf
# 修改 ~/.config/libinput-gestures.conf，具体配置自行查询。
```

## grub 主题

[下载 grub 主题](https://www.gnome-look.org/browse/cat/109/)

将主题包解压后放在`/boot/grub/themes`下。

```
# 修改/etc/default/grub

GRUB_THEME="/boot/grub/themes/主题包名/theme.txt"
GRUB_GFXMODE="1920x1080x32"

# 更新配置

grub-mkconfig -o /boot/grub/grub.cfg
```

## 启用 snap

- 添加 USE flag

```
sys-apps/systemd policykit apparmor
sys-libs/libseccomp static-libs
```

- 开启测试分支

```
sys-libs/libapparmor
sys-apps/apparmor
app-emulation/snapd
sec-policy/apparmor-profiles
```

- 安装包

```
emerge sys-apps/systemd
emerge sys-apps/apparmor
```

- 修改 grub 配置

```
nvim /etc/default/grub
# 添加
GRUB_CMDLINE_LINIX_DEFAULT="apparmor=1 security=apparmor"

grub-mkconfig -o /boot/grub/grub.cfg
```

- 安装 snap

```
layman -a snapd
eix-sync
# 内核需要开启CONFIG_SECURITY_APPARMOR
# 如果前面采用的是自动编译，则可以将此项加入/usr/src/linux/.config，再重新编译内核
emerge --ask app-emulation/snapd

sudo systemctl enable --now snapd
sudo systemctl enable --now snapd.socket
sudo systemctl enable --now snapd.apparmor
```

- snap 加速

```
sudo systemctl edit snapd

[Service]
Environment="http_proxy=http://127.0.0.1:port"
Environment="https_proxy=http://127.0.0.1:port"

sudo systemctl daemon-reload
sudo systemctl restart snapd
```
