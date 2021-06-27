---
title: Develop Stm32 with Rust stm32f303-light-a-LED
date: 2021-06-19 22:13:27
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f303-light-a-LED

本系列教程全部置于 stm32 专栏。

本例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。

```rust
#![no_main]
#![no_std]

use cortex_m_rt::entry;
use panic_halt as _;
use stm32f3::stm32f303;

#[entry]
fn main() -> ! {
    let peripherals = stm32f303::Peripherals::take().unwrap();
    // RCC is the reset and clock control
    // It is used to power on or off every other peripheral
    let rcc = peripherals.RCC;
    // ahbenr is the AHB Peripheral Clock enable register
    // iopeen is the io port e enable control
    rcc.ahbenr.modify(|_, w| w.iopeen().set_bit());
    // write and modify can both work
    // rcc.ahbenr.write(|w| w.iopeen().set_bit());
    let gpioe = &peripherals.GPIOE;
    // moder is the GPIO port mode register
    // we set gpioe9 to output mode
    gpioe.moder.modify(|_, w| w.moder9().output());
    // odr is the GPIO port output data register
    // we set the output of gpioe9
    // now, the north LED is lighting
    gpioe.odr.modify(|_, w| w.odr9().set_bit());
    loop {}
}
```
