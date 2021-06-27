---
title: Develop Stm32 with Rust stm32f303-horse-race-lamp-with-timer-in-pulling-mode
date: 2021-06-19 22:17:14
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f303-horse-race-lamp-with-timer-in-pulling-mode

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
    let rcc = &peripherals.RCC;

    // init leds
    rcc.ahbenr.modify(|_, w| w.iopeen().set_bit());
    let gpioe = &peripherals.GPIOE;
    gpioe.moder.modify(|_, w| {
        w.moder8()
            .output()
            .moder9()
            .output()
            .moder10()
            .output()
            .moder11()
            .output()
            .moder12()
            .output()
            .moder13()
            .output()
            .moder14()
            .output()
            .moder15()
            .output()
    });

    // init TIM6 timer
    // power on TIM6 timer
    rcc.apb1enr.modify(|_, w| w.tim6en().set_bit());
    let tim6 = &peripherals.TIM6;
    // opm : set the timer mode to one pulse mode
    // cen : disable the counter during the configuration
    tim6.cr1.modify(|_, w| w.opm().set_bit().cen().clear_bit());
    // the default clock APB1_CLOCK = 8 MHz
    // PSC = 7999
    // 8 M / (7999 + 1) = 1 k
    // configure the prescaler to have the counter operate at 1 kHz
    // that means the counter will increase on every millisecond
    tim6.psc.write(|w| w.psc().bits(7_999));
    // set counter period
    tim6.arr.write(|w| w.arr().bits(1000));
    // enable the counter
    tim6.cr1.modify(|_, w| w.cen().set_bit());
    let mut i = 0;
    loop {
        if i == 0 {
            gpioe.odr.modify(|_, w| w.odr9().set_bit());
            gpioe.odr.modify(|_, w| w.odr8().clear_bit());
        } else if i == 1 {
            gpioe.odr.modify(|_, w| w.odr10().set_bit());
            gpioe.odr.modify(|_, w| w.odr9().clear_bit());
        } else if i == 2 {
            gpioe.odr.modify(|_, w| w.odr11().set_bit());
            gpioe.odr.modify(|_, w| w.odr10().clear_bit());
        } else if i == 3 {
            gpioe.odr.modify(|_, w| w.odr12().set_bit());
            gpioe.odr.modify(|_, w| w.odr11().clear_bit());
        } else if i == 4 {
            gpioe.odr.modify(|_, w| w.odr13().set_bit());
            gpioe.odr.modify(|_, w| w.odr12().clear_bit());
        } else if i == 5 {
            gpioe.odr.modify(|_, w| w.odr14().set_bit());
            gpioe.odr.modify(|_, w| w.odr13().clear_bit());
        } else if i == 6 {
            gpioe.odr.modify(|_, w| w.odr15().set_bit());
            gpioe.odr.modify(|_, w| w.odr14().clear_bit());
        } else if i == 7 {
            gpioe.odr.modify(|_, w| w.odr8().set_bit());
            gpioe.odr.modify(|_, w| w.odr15().clear_bit());
        }
        // wait until the counter completes one period
        while !tim6.sr.read().uif().bit_is_set() {}
        // clear the update event flag
        tim6.sr.modify(|_, w| w.uif().clear_bit());
        i = if i == 7 { 0 } else { i + 1 };
        // since we select one pulse mode, it's necessary to restart the timer
        tim6.cr1.modify(|_, w| w.cen().set_bit());
    }
}
```
