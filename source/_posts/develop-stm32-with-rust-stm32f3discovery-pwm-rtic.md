---
title: Develop Stm32 with Rust stm32f3discovery-pwm-rtic
date: 2021-06-19 22:38:50
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f3discovery-pwm-rtic

本系列教程全部置于 stm32 专栏。

本例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。

```rust
#![no_main]
#![no_std]

use panic_semihosting as _;
use rtic::app;
use stm32f3xx_hal::{pac, prelude::*, pwm::tim2, rcc::RccExt};

#[app(device = stm32f3xx_hal::pac, peripherals = true)]
const APP: () = {
    struct Resources {}

    #[init]
    fn init(cx: init::Context) {
        let dp: pac::Peripherals = cx.device;
        let mut rcc = dp.RCC.constrain();

        let mut flash = dp.FLASH.constrain();
        let clocks = rcc.cfgr.sysclk(16_u32.MHz()).freeze(&mut flash.acr);

        let mut gpiob = dp.GPIOB.split(&mut rcc.ahb);
        let pb10 =
            gpiob
                .pb10
                .into_af1_push_pull(&mut gpiob.moder, &mut gpiob.otyper, &mut gpiob.afrh);

        let tim2_channels = tim2(dp.TIM2, 160_000, 50_u32.Hz(), &clocks);

        let mut tim2_ch3 = tim2_channels.2.output_to_pb10(pb10);
        tim2_ch3.set_duty(tim2_ch3.get_max_duty() / 4); // 25% duty cycle
        tim2_ch3.enable();
    }
};
```
