---
title: Develop Stm32 with Rust stm32f3discovery-serial-rtic
date: 2021-06-19 22:55:04
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f3discovery-serial-rtic

本系列教程全部置于 stm32 专栏。

本例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。

Since `tx`, `tx_buf`, `tx_channel` will be moved in use, I have not found a way to use USART with DMA and Interrupt.

## Serial

```rust
#![no_main]
#![no_std]

use hal::{pac, prelude::*, serial::Serial};
use panic_semihosting as _;
use rtic::app;
use stm32f3xx_hal as hal;

#[app(device = stm32f3xx_hal::pac, peripherals = true)]
const APP: () = {
    struct Resources {}

    #[init]
    fn init(cx: init::Context) {
        let dp: pac::Peripherals = cx.device;
        let mut rcc = dp.RCC.constrain();
        let clock = rcc
            .cfgr
            .sysclk(48_u32.MHz())
            .freeze(&mut dp.FLASH.constrain().acr);
        let mut gpioa = dp.GPIOA.split(&mut rcc.ahb);

        let pins = (
            gpioa
                .pa9
                .into_af7_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrh),
            gpioa
                .pa10
                .into_af7_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrh),
        );

        let mut serial = Serial::usart1(dp.USART1, pins, 9600_u32.Bd(), clock, &mut rcc.apb2);

        let mut send: u8 = 'a' as u8;

        serial.write(send).unwrap();

        send = 'b' as u8;

        // Wait for the first send operation complete.
        cortex_m::asm::delay(10000000);

        // serial can be used multiple times.
        serial.write(send).unwrap();

        let (mut tx, _rx) = serial.split();

        cortex_m::asm::delay(10000000);

        // tx can also be used multiple times.
        tx.write(send).unwrap();

        cortex_m::asm::delay(10000000);

        tx.write(send).unwrap();
    }

    #[idle]
    fn idle(_cx: idle::Context) -> ! {
        loop {
            cortex_m::asm::nop();
        }
    }
};
```

## Serial with DMA

```rust
#![no_main]
#![no_std]

use cortex_m::singleton;
use cortex_m_semihosting::hprintln;
use hal::{pac, prelude::*, serial::Serial};
use panic_semihosting as _;
use rtic::app;
use stm32f3xx_hal as hal;

#[app(device = stm32f3xx_hal::pac, peripherals = true)]
const APP: () = {
    struct Resources {}

    #[init]
    fn init(cx: init::Context) {
        let dp: pac::Peripherals = cx.device;
        let mut rcc = dp.RCC.constrain();
        let clock = rcc
            .cfgr
            .sysclk(48_u32.MHz())
            .freeze(&mut dp.FLASH.constrain().acr);
        let mut gpioa = dp.GPIOA.split(&mut rcc.ahb);

        let pins = (
            gpioa
                .pa9
                .into_af7_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrh),
            gpioa
                .pa10
                .into_af7_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrh),
        );

        let serial = Serial::usart1(dp.USART1, pins, 9600_u32.Bd(), clock, &mut rcc.apb2);

        let (tx, rx) = serial.split();

        let dma1 = dp.DMA1.split(&mut rcc.ahb);

        let tx_buf = singleton!(:[u8;8]=*b"hello321").unwrap();

        let rx_buf = singleton!(:[u8;8]=[0;8]).unwrap();

        let (tx_channel, rx_channel) = (dma1.ch4, dma1.ch5);

        // tx, tx_buf, tx_channel will be moved here.
        // The data will be sent here.
        let sending = tx.write_all(tx_buf, tx_channel);
        // The data will not be read here.
        let receiving = rx.read_exact(rx_buf, rx_channel);

        // tx, tx_buf, tx_channel are regenerated here.
        // Method `wait` waits for the send operation complete.
        let (_tx_buf, _tx_channel, _tx) = sending.wait();
        // Wait for data to be received.
        let (rx_buf, _rx_channel, _rx) = receiving.wait();

        for i in 0..rx_buf.len() {
            hprintln!("{}", rx_buf[i] as char).unwrap();
        }
    }

    #[idle]
    fn idle(_cx: idle::Context) -> ! {
        loop {
            cortex_m::asm::nop();
        }
    }
};
```

## Serial with Interrupt

```rust
#![no_main]
#![no_std]

use cortex_m_semihosting::hprintln;
use hal::{
    gpio::{self, PushPull, AF7},
    pac::USART1,
    prelude::*,
    rcc::RccExt,
    serial::{Event, Serial},
};

use panic_semihosting as _;
use stm32f3xx_hal as hal;

type SerialType = Serial<
    USART1,
    (
        gpio::gpioa::PA9<AF7<PushPull>>,
        gpio::gpioa::PA10<AF7<PushPull>>,
    ),
>;

#[rtic::app(device = stm32f3xx_hal::pac, peripherals = true)]
const APP: () = {
    struct Resources {
        serial: SerialType,
    }

    #[init]
    fn init(cx: init::Context) -> init::LateResources {
        let dp: hal::pac::Peripherals = cx.device;
        let mut rcc = dp.RCC.constrain();
        let clocks = rcc
            .cfgr
            .sysclk(48_u32.MHz())
            .freeze(&mut dp.FLASH.constrain().acr);
        let mut gpioa = dp.GPIOA.split(&mut rcc.ahb);

        let pins = (
            gpioa
                .pa9
                .into_af7_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrh),
            gpioa
                .pa10
                .into_af7_push_pull(&mut gpioa.moder, &mut gpioa.otyper, &mut gpioa.afrh),
        );

        let mut serial = Serial::usart1(dp.USART1, pins, 9600_u32.Bd(), clocks, &mut rcc.apb2);

        serial.listen(Event::Rxne);

        init::LateResources { serial }
    }

    #[task(binds = USART1_EXTI25, resources = [serial])]
    fn serial(cx: serial::Context) {
        let serial: &mut SerialType = cx.resources.serial;

        if serial.is_rxne() {
            serial.unlisten(Event::Rxne);
            match serial.read() {
                Ok(byte) => {
                    serial.write(byte).unwrap();
                    serial.listen(Event::Tc);
                    // This will cause a few millisecond to execute the function.
                    // And this will result in partial data not being received.
                    // hprintln!("{}", byte as char).unwrap();
                }

                Err(_error) => {
                    hprintln!("read error").unwrap();
                }
            }
        }

        if serial.is_tc() {
            serial.unlisten(Event::Tc);
            serial.listen(Event::Rxne);
        }
    }
};
```
