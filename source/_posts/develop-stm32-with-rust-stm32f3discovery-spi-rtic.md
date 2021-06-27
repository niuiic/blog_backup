---
title: Develop Stm32 with Rust stm32f3discovery-spi-rtic
date: 2021-06-20 08:18:21
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f3discovery-spi-rtic

本系列教程全部置于 stm32 专栏。

本例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。

Since `tx`, `tx_buf`, `tx_channel` will be moved in use, I have not found a way to use USART with DMA and Interrupt.

```rust
#![no_main]
#![no_std]

use cortex_m_semihosting::hprintln;
use hal::{
    prelude::*,
    rcc::RccExt,
    spi::{Mode, Spi},
};
use panic_semihosting as _;
use stm32f3xx_hal as hal;

#[rtic::app(device = stm32f3xx_hal::pac, peripherals = true)]
const APP: () = {
    struct Resources {}

    #[init]
    fn init(cx: init::Context) {
        let dp: hal::pac::Peripherals = cx.device;
        let mut rcc = dp.RCC.constrain();
        let clocks = rcc
            .cfgr
            .use_hse(8_u32.MHz())
            .sysclk(48_u32.MHz())
            .pclk1(24_u32.MHz())
            .freeze(&mut dp.FLASH.constrain().acr);
        let mut gpioa = dp.GPIOA.split(&mut rcc.ahb);

        let sck =
            gpioa
                .pa5
                .into_af5_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrl);
        let miso =
            gpioa
                .pa6
                .into_af5_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrl);
        let mosi =
            gpioa
                .pa7
                .into_af5_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrl);

        let spi_mode = Mode {
            polarity: hal::spi::Polarity::IdleLow,
            phase: hal::spi::Phase::CaptureOnFirstTransition,
        };

        // The type parameter `WORD` needed by method spi1 is not specified here,
        // you can just ignore the error, and it will be specified in use.
        let mut spi = Spi::spi1(
            dp.SPI1,
            (sck, miso, mosi),
            spi_mode,
            3_000_000_u32.Hz(),
            clocks,
            &mut rcc.apb2,
        );

        let msg_send: [u8; 8] = [0xD, 0xE, 0xA, 0xD, 0xB, 0xE, 0xE, 0xF];
        let mut msg_sending = msg_send;
        let msg_received = spi.transfer(&mut msg_sending).unwrap();
        // Connect pin pa7 and pin pa6 together, you will see the received data is the
        // same as transmitted data.
        hprintln!("{:?}", msg_send).unwrap();
        hprintln!("{:?}", msg_received).unwrap();
    }
};
```
