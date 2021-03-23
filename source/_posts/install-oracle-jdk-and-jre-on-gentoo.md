---
title: Install Oracle Jdk and Jre on Gentoo
date: 2021-03-23 18:14:01
tags:
		- Gentoo
		- Java
		- Oracle
categories:
		- Gentoo
---

# Gentoo系统安装Oracle jdk和jre

## why not openjdk

openjdk 在部分情况下无法完全替代闭源版本。尤其是在需要完整 javafx 的情况下。

gentoo 提供了具有 javafx USE flag 的 openjdk。不过笔者未能成功开启，应该是与主 profile 冲突。另外也有提供 openjfx，不过该 javafx 属于阉割版，比如没有对 webkit 的支持。

## 通过包管理器安装

gentoo overlay 中有 oracle-jdk-bin 的 ebuild，希望通过包管理系统安装的可以使用。但是由于 oracle 禁止从链接直接获取二进制包。必须手动下载合适版本，放入指定位置后才可编译。

该方案有几个缺点。一是 overlay 上没有提供最新版本。二是由于指定位置实际上是个临时文件夹，也就是说每次 emerge 都会改变位置。然而等你获取提示中的位置信息时，再将下载的文件放入已经无效。笔者未曾遇到过这种问题，偷懒放弃解决。实在解决不了的可以把人家的 ebuild copy 到自己的 overlay 中，改链接到你上传下载的 jdk、jre 的地址也行。

## 直接安装

从 oracle [官网](https://www.oracle.com/java/technologies/javase-downloads.html) 下载 jdk。以 oracle-jdk8u271 为例。

1. 解压。
2. 将其移动到合适位置并赋予权限。

```
tar xvzf XXX
sudo chown -R 777 XXX
mv XXX XXX
```

`XXX`部分自行填写。

3. 配置 java 信息。

编辑`/usr/share/java-config-2/vm/oracle-jdk8u271`。写入

```
VERSION="Oracle-Sun JDK 8u271"
JAVA_HOME="/opt/jdk1.8.0_271"
JDK_HOME="/opt/jdk1.8.0_271"
JAVAC="${JAVA_HOME}/bin/javac"
PATH="${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin"
ROOTPATH="${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin"
LDPATH="${JAVA_HOME}/jre/lib/amd64/:${JAVA_HOME}/jre/lib/amd64/native_threads/:${JAVA_HOME}/jre/lib/amd64/xawt/:${JAVA_HOME}/jre/lib/amd64/server/"
MANPATH="/opt/icedtea-bin-8.2.2.1/man"
PROVIDES_TYPE="JDK JRE"
PROVIDES_VERSION="1.8"
# Taken from sun.boot.class.path property
BOOTCLASSPATH="${JAVA_HOME}/jre/lib/resources.jar:${JAVA_HOME}/jre/lib/rt.jar:${JAVA_HOME}/jre/lib/jsse.jar:${JAVA_HOME}/jre/lib/jce.jar:${JAVA_HOME}/jre/lib/charsets.jar"
GENERATION="2"
ENV_VARS="JAVA_HOME JDK_HOME JAVAC PATH ROOTPATH LDPATH MANPATH"
VMHANDLE="oracle-jdk8"
BUILD_ONLY="FALSE"
```

注意修改版本号。

4. 将 jdk 文件夹软链接到`/usr/lib/jvm`。

如`ln -s /opt/jdk1.8.0_271/ /usr/lib/jvm/oracle-jdk8u271`。

5. 设置 java 版本。

```
// 查看当前可用的java虚拟机。
eselect java-vm list
// 设置虚拟机，不可使用sudo。
eselect java-vm set user number
// 或者
eselect java-vm set system number
```

其他 linux 版本可以通过`java-config -L`查看，`java-config set number`设置。（该操作对 gentoo 无效）
