---
title: Develop Stm32 with Rust stm32f103-adc-with-dma
date: 2021-06-19 22:06:11
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f103-adc-with-dma

本系列教程全部置于 stm32 专栏。

本例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。

```rust
#![no_main]
#![no_std]

use panic_semihosting as _;

use cortex_m::singleton;
use cortex_m_semihosting::hprintln;

use cortex_m_rt::entry;
use stm32f1xx_hal::{adc, pac, prelude::*};

#[entry]
fn main() -> ! {
    let dp = pac::Peripherals::take().unwrap();
    let mut flash = dp.FLASH.constrain();
    let mut rcc = dp.RCC.constrain();
    let clocks = rcc.cfgr.adcclk(2.mhz()).freeze(&mut flash.acr);

    let dma_ch1 = dp.DMA1.split(&mut rcc.ahb).1;

    let adc1 = adc::Adc::adc1(dp.ADC1, &mut rcc.apb2, clocks);

    let mut gpioa = dp.GPIOA.split(&mut rcc.apb2);

    let adc_ch0 = gpioa.pa0.into_analog(&mut gpioa.crl);

    let adc_dma = adc1.with_dma(adc_ch0, dma_ch1);

    // This can only be excuted once.
    let buf = singleton!(: [u16; 8] = [0; 8]).unwrap();

    // adc_dma and buf are moved here.
    let (buf, adc_dma) = adc_dma.read(buf).wait();

    // Consumes the AdcDma struct, restores adc configuration to previous state and
    // returns the Adc struct in normal mode. adc_dma is moved here.
    let (_adc1, _adc_ch0, _dma_ch1) = adc_dma.split();

    let mut voltage = 0.0;

    for i in 0..8 {
        voltage += buf[i] as f32;
    }

    // 12-bit ADC
    voltage = voltage / 8.0 / 4096.0 * 3.3;

    hprintln!("voltage = {}", voltage).unwrap();

    loop {}
}
```
