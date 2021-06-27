---
title: Develop Stm32 with Rust stm32f3discovery-can-rtic
date: 2021-06-20 08:21:29
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f3discovery-can-rtic

本系列教程全部置于 stm32 专栏。

本例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。

Don't forget to enable `can` feature of `stm32f3xx_hal` crate.

```rust
#![no_main]
#![no_std]

use cortex_m::asm;
use hal::{
    can::{Can, CanFilter, CanFrame, CanId, Filter, Frame, Receiver, Transmitter},
    prelude::*,
    rcc::RccExt,
    watchdog::IndependentWatchDog,
};
use nb::block;
use panic_semihosting as _;
use stm32f3xx_hal as hal;

const ID: u16 = 0b100;

#[rtic::app(device = stm32f3xx_hal::pac, peripherals = true)]
const APP: () = {
    struct Resources {}

    #[init]
    fn init(cx: init::Context) {
        let dp: hal::pac::Peripherals = cx.device;
        let mut rcc = dp.RCC.constrain();
        let mut gpioe = dp.GPIOE.split(&mut rcc.ahb);
        let mut gpioa = dp.GPIOA.split(&mut rcc.ahb);
        let _clocks = rcc
            .cfgr
            .use_hse(32.MHz())
            .sysclk(32.MHz())
            .pclk1(16.MHz())
            .pclk2(16.MHz())
            .freeze(&mut dp.FLASH.constrain().acr);

        // Configure CAN RX and TX pins.
        let rx =
            gpioa
                .pa11
                .into_af9_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrh);
        let tx =
            gpioa
                .pa12
                .into_af9_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrh);

        // Initialize the CAN peripheral
        let can = Can::new(dp.CAN, rx, tx, &mut rcc.apb1);

        // Uncomment the following line to enable CAN interrupts
        // can.listen(Event::Fifo0Fmp);

        let (mut tx, mut rx0, _rx1) = can.split();

        let mut led0 = gpioe
            .pe9
            .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper);
        led0.set_high().unwrap();

        let filter = CanFilter::from_mask(0b100, ID.into());
        rx0.set_filter(filter);

        // Watchdog makes sure this gets restarted periodically if nothing happens
        let mut iwdg = IndependentWatchDog::new(dp.IWDG);
        iwdg.stop_on_debug(&dp.DBGMCU, true);
        iwdg.start(100.milliseconds());

        // Send an initial message!
        asm::delay(100_000);
        let data: [u8; 1] = [0];

        let frame = CanFrame::new_data(CanId::BaseId(ID), &data);

        block!(tx.transmit(&frame)).expect("Cannot send first CAN frame");

        loop {
            let rcv_frame = block!(rx0.receive()).expect("Cannot receive CAN frame");

            if let Some(d) = rcv_frame.data() {
                let counter = d[0].wrapping_add(1);

                if counter % 3 == 0 {
                    led0.toggle().unwrap();
                }

                let data: [u8; 1] = [counter];
                let frame = CanFrame::new_data(CanId::BaseId(ID), &data);

                block!(tx.transmit(&frame)).expect("Cannot send CAN frame");
            }

            iwdg.feed();

            asm::delay(1_000_000);
        }
    }
};
```
