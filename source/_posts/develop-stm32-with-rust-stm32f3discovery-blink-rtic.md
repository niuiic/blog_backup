---
title: Develop Stm32 with Rust stm32f3discovery-blink-rtic
date: 2021-06-19 22:26:17
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f3discovery-blink-rtic

本系列教程全部置于 stm32 专栏。

本例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。

```rust
#![no_main]
#![no_std]

// Use panic_semihosting instead of panic_halt.
use panic_semihosting as _;
use rtic::{app, cyccnt::U32Ext};
use stm32f3xx_hal::{
    gpio::{gpioe::PE10, Output, PushPull},
    prelude::*,
};

const PERIOD: u32 = 10_000_000;


// This is the entry of the program.
// monotonic is needed for schedule API
#[app(device=stm32f3xx_hal::pac,peripherals=true, monotonic=rtic::cyccnt::CYCCNT)]
const APP: () = {
    // This is the resource which will be shared in interrupt functions.
    struct Resources {
        led: PE10<Output<PushPull>>,
    }

    // The init function will be executed first with interrupts disabled.
    // The idle function will be executed after init function with interrupts enabled.
    // We don't use the function here.
    // When no idle function is declared, the runtime sets the SLEEPONEXIT bit and then
    // sends the microcontroller to sleep after running init.

    #[init(schedule = [blinker])]
    fn init(cx: init::Context) -> init::LateResources {
        let mut core = cx.core;
        core.DWT.enable_cycle_counter();

        // Do not use pac::Peripherals::take().unwrap() to create the device handle.
        let dp: stm32f3xx_hal::pac::Peripherals = cx.device;
        let mut rcc = dp.RCC.constrain();

        let mut gpioe = dp.GPIOE.split(&mut rcc.ahb);
        let mut pe10 = gpioe
            .pe10
            .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper);

        pe10.set_high().unwrap();

        cx.schedule.blinker(cx.start + PERIOD.cycles()).unwrap();
        init::LateResources { led: pe10 }
    }

    #[task(resources=[led],schedule=[blinker])]
    fn blinker(cx: blinker::Context) {
        cx.resources.led.toggle().unwrap();
        cx.schedule.blinker(cx.scheduled + PERIOD.cycles()).unwrap();
    }

    extern "C" {
        fn EXTI0();
    }
};
```
