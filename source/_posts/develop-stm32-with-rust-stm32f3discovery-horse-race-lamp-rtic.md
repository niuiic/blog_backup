---
title: Develop Stm32 with Rust stm32f3discovery-horse-race-lamp-rtic
date: 2021-06-19 22:31:19
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f3discovery-horse-race-lamp-rtic

本系列教程全部置于 stm32 专栏。

本例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。

The example below has an error that `*const (dyn gpio::private::GpioRegExt + 'static)` cannot be sent between threads safely. This is caused by the field `leds` in struct `Resources`. If you want to fix the error, you have to give up erasing GPIOs, and use the way used in the previous example instead.

If you want to use a value in different tasks with different priority, it must implement `Send` trait to keep the transfer safe. But if you use a value in different tasks with the same priority, there is no need for the value to implement `Send` trait. Here, the `leds` is assigned in `init` in LateResources struct who has the lowest priority and is used in a task named `blinker` whose priority is 1.

```rust
#![no_main]
#![no_std]

use panic_semihosting as _;
use rtic::{app, cyccnt::U32Ext};
use stm32f3xx_hal::{
    gpio::{Gpiox, Output, Pin, PushPull, Ux},
    prelude::*,
};

const PERIOD: u32 = 10_000_000;

#[app(device=stm32f3xx_hal::pac,peripherals=true, monotonic=rtic::cyccnt::CYCCNT)]
const APP: () = {
    struct Resources {
        leds: [Pin<Gpiox, Ux, Output<PushPull>>; 8],
        index: u32,
    }

    #[init(schedule = [blinker])]
    fn init(cx: init::Context) -> init::LateResources {
        let mut core = cx.core;
        core.DWT.enable_cycle_counter();

        let dp: stm32f3xx_hal::pac::Peripherals = cx.device;
        let mut rcc = dp.RCC.constrain();

        let mut gpioe = dp.GPIOE.split(&mut rcc.ahb);
        let mut leds = [
            gpioe
                .pe8
                .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper)
                .downgrade()
                .downgrade(),
            gpioe
                .pe9
                .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper)
                .downgrade()
                .downgrade(),
            gpioe
                .pe10
                .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper)
                .downgrade()
                .downgrade(),
            gpioe
                .pe11
                .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper)
                .downgrade()
                .downgrade(),
            gpioe
                .pe12
                .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper)
                .downgrade()
                .downgrade(),
            gpioe
                .pe13
                .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper)
                .downgrade()
                .downgrade(),
            gpioe
                .pe14
                .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper)
                .downgrade()
                .downgrade(),
            gpioe
                .pe15
                .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper)
                .downgrade()
                .downgrade(),
        ];

        cx.schedule.blinker(cx.start + PERIOD.cycles()).unwrap();
        init::LateResources { leds, index: 0 }
    }

    #[task(resources=[leds,index],schedule=[blinker])]
    fn blinker(cx: blinker::Context) {
        let mut index = cx.resources.index;
        cx.resources.leds[*index as usize].toggle().unwrap();
        *index = if *index == 0 { 7 } else { *index + 1 };
        cx.resources.leds[*index as usize].toggle().unwrap();
        cx.schedule.blinker(cx.scheduled + PERIOD.cycles()).unwrap();
    }

    extern "C" {
        fn EXTI0();
    }
};
```
