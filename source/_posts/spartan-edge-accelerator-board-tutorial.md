---
title: Basic Tutorial of Spartan Edge Accelerator Board
date: 2021-06-03 16:57:37
tags:
		- FPGA
		- Arduino
categories:
		- Embedded
---

# Spartan Edge Accelerator Board 入门教程

本文介绍一块 FPGA 开发板——Spartan Edge Accelerator Board。也称 Spartan-7 FPGA 开发板或 SEA-S7。

![develop board](1.png)

## 选择与不选择理由

### 优点

1. 便宜。整板价格在 200-300 元之间，且可以不需要下载器。
2. 性能好。比起几百块级别的入门板性价比相当高。规格参数可以翻阅官方的文档。[英文](https://wiki.seeedstudio.com/Spartan-Edge-Accelerator-Board/) [中文](https://wiki.seeedstudio.com/cn/Spartan-Edge-Accelerator-Board/)
3. 可以使用 vivado。vivado 不兼容 Spartan6（常见的入门板）但兼容 Spartan7。
4. arduino 和 FPGA 的结合体，看起来像低配版的 FPGA ZYNQ（arm + FPGA）。
5. 提供用封装好的 arduino 接口。方便 arduino 用户入门。

### 缺点

1. 没有详细的文档，更没有视频教程。绝对不适合没有任何经验的 FPGA 小白以及自学能力不够强的新手。
2. 比一般的以教学为目的的入门板少了很多外设。

## Hello World

下面以一个 blink 项目为例，介绍该开发板的使用。

> 官方的文档上有入门教程，不过好久没维护了，一些链接也没了，有兴趣折腾的可以搞一下。

### 硬件准备

1. 开发板。
2. 一根 Type-C 数据线。
3. [可选] Platform Cable USB II （JTAG 接口的 FPGA 下载器）。
4. 一张 SD 卡（外加读卡器）。

### 软件准备

1. arduino IDE。
2. vivado（免费的 webpack 版也支持 Spartan-7）。
3. CP2102 USB 驱动，可以前往[这里](https://www.usb-drivers.org/cp2102-usb-to-uart-bridge-driver.html)下载。

### 软硬件设置

首先明确是要将开发板当作独立的 FPGA 使用，所以 arduino 的部分只是辅助。

#### 硬件

首先找到板子上唯一一个跳线帽。这里标有 PWR_MODE，可以设置电源模式。如果将该开发板作为 arduino 的扩展板使用，可以通过设置 PWR_MODE 为 off 来隔离系统电源，同时给两块板供电。现在只是作为独立的 FPGA 使用，暂时不用管。

然后找到跳线帽旁边的一排拨码开关。新买的板子应该在上面有一层塑料膜封着，将其揭开。将 Slave 下的拨码开关向上推，也就是推向 Slave。这里是设置向 FPGA 写入比特流的方式。当前设置为 arduino 部分将 SD 卡中的比特流文件写入 FPGA。这样就不需要下载器。

将 SD 卡格式化为 FAT16 或 FAT32 文件系统。

#### 软件

启动 arduino IDE。在`文件-首选项-附加开发板管理器网址`处设置`https://dl.espressif.com/dl/package_esp32_index.json`。

在`工具-开发板-开发板管理器`中找到 esp32 并下载安装。

安装完成后，在`工具-开发板`中选择`DOIT ESP32 DEVKIT V1`。

现在测试一下是否可以与开发板正常通信。

用 Type-C 线连接开发板与电脑。可以使用设备管理器（windows）或者(`lsusb` linux)查看是否连接上。也可以在 arduino IDE 中查看`工具-端口`，看是否连接上。

> 注意开发板应上电（检查电源开关），驱动程序应安装，Type-C 线应可传数据。

接下来向 arduino 部分中烧录向 FPGA 写入比特流的程序。

下载[已经写好的库](https://github.com/sandrobenigno/spartan-edge-esp32-boot/archive/master.zip)。在 arduino IDE 中通过`项目-加载库-添加.ZIP库`将库导入。

使用`文件-打开`打开`01LoadDefaultBitstream.ino`文件。这就是需要的程序文件。

接下来，将`工具-Upload Speed`设置为 115200。使用`项目-上传`下载程序到开发板。

至此，arduino 辅助下载 FPGA 比特流文件的部分已经完成。

### Blink

下载[官方例程库](https://gitee.com/SEA-S7/SEA)。找到其中的`Hello-World/FPGA/Verilog/HelloWorld-Verilog`。使用 vivado 打开该项目。修改以下文件内容。

`Hello-World.v`

```verilog
`timescale 1ns / 1ps

module Hello_World(
    input clk,
    output reg signal_2
    );

    reg [32:0] m;

    always @(posedge clk) begin
        m = m + 1;
        if (m == 100000000) begin
            signal_2 = signal_2 == 1 ? 0 : 1;
            m = 0;
        end
    end
endmodule
```

`system.xdc`

```
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

set_property IOSTANDARD LVCMOS33 [get_ports {signal_2}]
set_property PACKAGE_PIN J1 [get_ports {signal_2}]
set_property PULLDOWN true [get_ports {signal_2}]
```

直接使用`generate bitstream`生成比特流文件。将位于`HelloWorld-Verilog.runs\impl_1`下的比特流文件`Hello_World.bit`复制到 SD 卡根目录下的`overlay`目录下，并改名为`default.bit`。

断开开发板与电脑的连接，将 SD 卡插入开发板，再连接开发板与电脑。

不出意外的话就可以看到位于右上角的 LED 灯闪烁。

此后如果要写入新的比特流文件，还是需要按照上述操作，将文件放到 SD 卡中然后改名。

这种写入方式非常麻烦。熟悉 arduino 的用户可能可以尝试通过串行通信直接把电脑上的文件传给 FPGA。

鉴于`Platform Cable USB II`的价格并不高(便宜的大概 100 多)。建议嫌麻烦的还是通过`Platform Cable USB II`连接开发板右上角的 JTAG 接口直接用 vivado 下载比特流文件（注意要先把前面的 Slave 设置回来）。

## 总结

初步使用之后个人感觉这块板子还是挺不错的，用来玩一玩谐波分析和图像识别还是挺适合的。

PCB 可以从[官方文档](https://wiki.seeedstudio.com/Spartan-Edge-Accelerator-Board/)处下载。有问题可以到他们的[论坛](https://forum.seeedstudio.com/)提问。
