---
title: Develop Stm32 Project with Rust Environment
date: 2021-03-23 18:19:56
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 搭建开发环境

本系列教程全部置于 stm32 专栏。

本文介绍如何用 rust 语言开发 stm32。开发平台为 linux（gentoo）。

## 硬件准备

本文使用的芯片为 STM32F103C8T6。该芯片性价比较高，价格低廉，适合入门学习。需要注意的是该款芯片为国产仿品，在烧录的时候需要对软件进行一定修改。

仿真器选用 STLINK V2。也可以选择 jlink。后者连接似乎更加稳定，不过使用外设时需要更加小心。

连接时只需要按板子上的标注把相同的引脚连起来即可。

此外需要至少四根母对母杜邦线。

## 软件准备

### 安装 rust

步骤极为简单，建议选用 beta 或者 nightly 版本工具链。

添加对相应架构的支持。

```
rustup target add thumbv6m-none-eabi thumbv7m-none-eabi thumbv7em-none-eabi thumbv7em-none-eabihf
```

### openocd

用于驱动仿真器。直接搜索如何安装即可。

对以上芯片，需要进行如下修改。

找到 openocd 的安装目录，将`/scripts/target/stm32f1x.cfg`中的`set _CPUTAPID 0x1ba01477`修改为`set _CPUTAPID 0x2ba01477`。

### arm-none-eabi 工具链

对 gentoo 而言，直接使用 crossdev 进行配置即可。其中 gdb 建议下载源码编译。其他 linux 版本需要搜索如何安装。

gdb 编译步骤如下。

```
# 进入源码目录
./configure --prefix="${PREFIX}" --target=arm-none-eabi
make
sudo make install
```

如果要拆卸，`cd`进入编译后的各个目录，执行`sudo make uninstall`即可。

crossdev 安装 arm-none-eabi 工具链步骤如下。

```
# 首先安装crossdev

# 编辑/etc/portage/make.conf，写入
PORTDIR_OVERLAY="${PORTDIR_OVERLAY} /usr/local/portage"

# 编译安装工具链
sudo crossdev -s4 -t arm-none-eabi
# 如果软件编译失败，查看原因为masked by: corruption，则
# 编辑/var/db/repos/localrepo-crossdev/metadata/layout.conf，写入
masters = gentoo
thin-manifests = true
# 编辑/etc/portage/repos.conf/crossdev.conf，写入
[crossdev]
location = /var/db/repos/localrepo-crossdev
priority = 10
masters = gentoo
auto-sync = no

# 编译时需要使用gcc作为编译器，编译newlib时，需要把/etc/portage/make.conf中
# COMMON_FLAGS="-march=native -O2 -pipe"注释掉
```

### stlink

stlink 是仿真器的驱动，在连接中可能需要。

### gdbgui（可选）

gdb gui 程序，便于调试。

## blink

新建项目`cargo new rusty-blink`。

`Cargo.toml`如下

```toml
[package]
name = "rusty-blink"
version = "0.1.0"
authors =
edition = "2018"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[profile.release]
opt-level = 'z' # turn on maximum optimizations. We only have 64kB
lto = true      # Link-time-optimizations for further size reduction

[dependencies]
cortex-m = "^0.6.3"      # Access to the generic ARM peripherals
cortex-m-rt = "^0.6.12"  # Startup code for the ARM Core
embedded-hal = "^0.2.4"  # Access to generic embedded functions (`set_high`)
panic-halt = "^0.2.0"    # Panic handler

# Access to the stm32f103 HAL.
[dependencies.stm32f1xx-hal]
# Bluepill contains a 64kB flash variant which is called "medium density"
features = ["stm32f103", "rt", "medium"]
version = "^0.6.1"
```

在项目根目录下新建项目配置`mkdir .cargo`。其中由于使用 lld 进行链接后会丢失调试信息，因此将 linker 指定为 gcc。runner 是执行`cargo run`之后自动执行的命令，此处为自动开启 gdb 并加载文件。

```
# .cargo/config
[build]
target = "thumbv7m-none-eabi"

[target.'cfg(all(target_arch = "arm", target_os = "none"))']
runner = 'gdbgui -g arm-none-eabi-gdb'

[target.thumbv7m-none-eabi]
rustflags = [
	"-C", "linker=arm-none-eabi-gcc",
	"-C", "link-arg=-Wl,-Tlink.x",
	"-C", "link-arg=-nostartfiles",
]
```

### 程序

在项目根目录下新建`memory.x`。

```
/* memory.x - Linker script for the STM32F103C8T6 */
MEMORY
{
  /* Flash memory begins at 0x80000000 and has a size of 64kB*/
  FLASH : ORIGIN = 0x08000000, LENGTH = 64K
  /* RAM begins at 0x20000000 and has a size of 20kB*/
  RAM : ORIGIN = 0x20000000, LENGTH = 20K
}
```

一般网上售卖的该款芯片应当是 64K 和 20K，如果有偏差需要按实际情况填写。

在 src 下新建`main.rs`。该程序仅用于测试，效果为绿灯闪烁。

```rust
// src/main.rs

#![no_std]
#![no_main]

use cortex_m_rt::entry; // The runtime
use embedded_hal::digital::v2::OutputPin; // the `set_high/low`function
use stm32f1xx_hal::{delay::Delay, pac, prelude::*}; // STM32F1 specific functions
#[allow(unused_imports)]
use panic_halt; // When a panic occurs, stop the microcontroller
#[entry]
fn main() -> ! {
    let dp = pac::Peripherals::take().unwrap();
    let cp = cortex_m::Peripherals::take().unwrap();
    let mut rcc = dp.RCC.constrain();
    let mut gpioc = dp.GPIOC.split(&mut rcc.apb2);
    let mut led = gpioc.pc13.into_push_pull_output(&mut gpioc.crh);
    let mut flash = dp.FLASH.constrain();
    let clocks = rcc.cfgr.sysclk(8.mhz()).freeze(&mut flash.acr);
    let mut delay = Delay::new(cp.SYST, clocks);
    loop {
        led.set_high().ok();
        delay.delay_ms(1_000_u16);
        led.set_low().ok();
        delay.delay_ms(1_000_u16);
    }
}
```

### 烧录与调试

```
# 连接仿真器
openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg
# 如果仿真器选用jlink，则命令为openocd -f interface/jlink.cfg -f target/stm32f1x.cfg
# 出现以下信息为连接成功
Info : stm32f1x.cpu: hardware has 6 breakpoints, 4 watchpoints

# 编译并开启gdb
cargo run

# 在gdb窗口执行以下命令
target remote :3333
moniter reset halt
load
continue
```

此时如果程序持续执行，应当可以在板子上看到绿灯闪烁。如果停在断点处，就再 continue。

更进一步可以直接在 gdb 开启时自动执行以上命令。

将`runner`改为`runner = 'arm-none-eabi-gdb -q -x debug.gdb'`。在项目根目录下新建`debug.gdb`，写入以下内容。

```
target remote :3333

set backtrace limit 32

monitor reset halt

load
```
