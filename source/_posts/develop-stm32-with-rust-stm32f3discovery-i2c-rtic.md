---
title: Develop Stm32 with Rust stm32f3discovery-i2c-rtic
date: 2021-06-19 23:00:58
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f3discovery-i2c-rtic

本系列教程全部置于 stm32 专栏。

本例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。

```rust
#![no_main]
#![no_std]

use core::ops::Range;
use cortex_m::asm;
use cortex_m_semihosting::{hprint, hprintln};
use hal::{prelude::*, rcc::RccExt};
use panic_semihosting as _;
use stm32f3xx_hal as hal;

const VALID_ADDR_RANGE: Range<u8> = 0x08..0x78;

#[rtic::app(device = stm32f3xx_hal::pac, peripherals = true)]
const APP: () = {
    struct Resources {}

    #[init]
    fn init(cx: init::Context) {
        let dp: hal::pac::Peripherals = cx.device;
        let mut rcc = dp.RCC.constrain();
        let clocks = rcc.cfgr.freeze(&mut dp.FLASH.constrain().acr);
        let mut gpiob = dp.GPIOB.split(&mut rcc.ahb);

        // Configure I2C
        let mut scl =
            gpiob
                .pb6
                .into_af4_open_drain(&mut gpiob.moder, &mut gpiob.otyper, &mut gpiob.afrl);
        let mut sda =
            gpiob
                .pb7
                .into_af4_open_drain(&mut gpiob.moder, &mut gpiob.otyper, &mut gpiob.afrl);

        scl.internal_pull_up(&mut gpiob.pupdr, true);
        sda.internal_pull_up(&mut gpiob.pupdr, true);

        let mut i2c =
            hal::i2c::I2c::new(dp.I2C1, (scl, sda), 100_000_u32.Hz(), clocks, &mut rcc.apb1);

        hprintln!("Start I2C scanning").unwrap();
        hprintln!("").unwrap();

        // Travers the address, try to write data to the address, test whether the address is
        // writable.
        for addr in 0x00_u8..0x80 {
            if VALID_ADDR_RANGE.contains(&addr) && i2c.write(addr, &[]).is_ok() {
                // If the address is writable, print it.
                hprint!("{:02x}", addr).unwrap();
            } else {
                hprint!("..").unwrap();
            }
            if addr % 0x10 == 0x0f {
                hprintln!("").unwrap();
            }
        }
        hprintln!().unwrap();
        hprintln!("Done!").unwrap();
        loop {
            asm::wfi();
        }
    }
};
```
