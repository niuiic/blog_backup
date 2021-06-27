---
title: Develop Stm32 with Rust stm32f303-horse-race-lamp-with-timer-in-interrupt-mode
date: 2021-06-19 22:21:40
tags:
  - Rust
  - Stm32
categories:
  - [Embedded]
  - [Rust]
  - [Stm32]
---

# 使用 rust 开发 stm32 stm32f303-horse-race-lamp-with-timer-in-interrupt-mode

本系列教程全部置于 stm32 专栏。

本例程参考`stm32fxxx-hal crate`（如`stm32f1xx-hal`）官方例程，并在官方例程的基础上增加了一些注释，修正了一些错误。可以借鉴不同型号的 stm32 例程，毕竟固件库的核是一样的。

```rust
#![no_main]
#![no_std]

use cortex_m_rt::entry;
use panic_halt as _;
use stm32f3::stm32f303;
use stm32f303::{interrupt, Interrupt, NVIC};

// since peripherals is in singleton mode, we need to use static variables
// to share peripheral register structs with interrupt handles.
static mut TIMER: Option<stm32f303::TIM7> = None;
static mut GPIOE: Option<stm32f303::GPIOE> = None;
static mut INDEX: u8 = 0;

unsafe fn get_gpioe() -> &'static mut stm32f303::GPIOE {
    if let Some(ref mut gpioe) = GPIOE {
        &mut *gpioe
    } else {
        panic!()
    }
}

unsafe fn get_timer() -> &'static mut stm32f303::TIM7 {
    if let Some(ref mut timer) = TIMER {
        &mut *timer
    } else {
        panic!()
    }
}

#[entry]
fn main() -> ! {
    let dp = stm32f303::Peripherals::take().unwrap();
    let rcc = &dp.RCC;

    // enable TIM7 interrupt
    unsafe {
        NVIC::unmask(Interrupt::TIM7);
    }

    // init LED
    rcc.ahbenr.modify(|_, w| w.iopeen().set_bit());
    // we will assign gpioe and tim7 to the static variables later
    // so these variables need to be freed before the assign operation
    {
        let gpioe = &dp.GPIOE;
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
    }

    // init TIM7 timer
    {
        let tim7 = &dp.TIM7;
        rcc.apb1enr.modify(|_, w| w.tim7en().set_bit());
        tim7.cr1.modify(|_, w| w.cen().clear_bit());
        tim7.psc.write(|w| w.psc().bits(7_999));
        tim7.arr.write(|w| w.arr().bits(50));

        tim7.dier.modify(|_, w| w.uie().set_bit());
        // enable the counter
        tim7.cr1.modify(|_, w| w.cen().set_bit());
    }

    // set the value of static TIMER and GPIOE
    unsafe {
        GPIOE = Some(dp.GPIOE);
        TIMER = Some(dp.TIM7);
    }
    loop {}
}

#[interrupt]
fn TIM7() {
    let tim7 = unsafe { get_timer() };
    // clear the update interrupt flag of TIM7
    tim7.sr.modify(|_, w| w.uif().clear_bit());

    let gpioe = unsafe { get_gpioe() };
    unsafe {
        if INDEX == 0 {
            gpioe.odr.modify(|_, w| w.odr9().set_bit());
            gpioe.odr.modify(|_, w| w.odr8().clear_bit());
        } else if INDEX == 1 {
            gpioe.odr.modify(|_, w| w.odr10().set_bit());
            gpioe.odr.modify(|_, w| w.odr9().clear_bit());
        } else if INDEX == 2 {
            gpioe.odr.modify(|_, w| w.odr11().set_bit());
            gpioe.odr.modify(|_, w| w.odr10().clear_bit());
        } else if INDEX == 3 {
            gpioe.odr.modify(|_, w| w.odr12().set_bit());
            gpioe.odr.modify(|_, w| w.odr11().clear_bit());
        } else if INDEX == 4 {
            gpioe.odr.modify(|_, w| w.odr13().set_bit());
            gpioe.odr.modify(|_, w| w.odr12().clear_bit());
        } else if INDEX == 5 {
            gpioe.odr.modify(|_, w| w.odr14().set_bit());
            gpioe.odr.modify(|_, w| w.odr13().clear_bit());
        } else if INDEX == 6 {
            gpioe.odr.modify(|_, w| w.odr15().set_bit());
            gpioe.odr.modify(|_, w| w.odr14().clear_bit());
        } else if INDEX == 7 {
            gpioe.odr.modify(|_, w| w.odr8().set_bit());
            gpioe.odr.modify(|_, w| w.odr15().clear_bit());
        }
        INDEX = if INDEX == 7 { 0 } else { INDEX + 1 };
    }
}
```

You can also use the code below. In this example, we define `Peripherals` as a static variable.

```rust
#![no_main]
#![no_std]

use cortex_m_rt::entry;
use panic_halt as _;
use stm32f3::stm32f303;
use stm32f303::{interrupt, Interrupt, NVIC};

static mut PERIPHERALS: Option<stm32f303::Peripherals> = None;
static mut INDEX: u8 = 0;

unsafe fn get_peripheral() -> &'static mut stm32f303::Peripherals {
    if let Some(ref mut peripheral) = PERIPHERALS {
        &mut *peripheral
    } else {
        panic!()
    }
}

#[entry]
fn main() -> ! {
    unsafe {
        let dp = stm32f303::Peripherals::take().unwrap();
        PERIPHERALS = Some(dp);
    }

    let dp = unsafe { get_peripheral() };

    let rcc = &dp.RCC;

    // enable TIM7 interrupt
    unsafe {
        NVIC::unmask(Interrupt::TIM7);
    }

    // init LED
    rcc.ahbenr.modify(|_, w| w.iopeen().set_bit());
    let gpioe = &dp.GPIOE;
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

    // init TIM7 timer
    let tim7 = &dp.TIM7;
    rcc.apb1enr.modify(|_, w| w.tim7en().set_bit());
    tim7.cr1.modify(|_, w| w.cen().clear_bit());
    tim7.psc.write(|w| w.psc().bits(7_999));
    tim7.arr.write(|w| w.arr().bits(50));

    tim7.dier.modify(|_, w| w.uie().set_bit());
    // enable the counter
    tim7.cr1.modify(|_, w| w.cen().set_bit());
    loop {}
}

#[interrupt]
fn TIM7() {
    let dp = unsafe { get_peripheral() };
    let tim7 = &dp.TIM7;
    // clear the update interrupt flag of TIM7
    tim7.sr.modify(|_, w| w.uif().clear_bit());

    let gpioe = &dp.GPIOE;
    unsafe {
        if INDEX == 0 {
            gpioe.odr.modify(|_, w| w.odr9().set_bit());
            gpioe.odr.modify(|_, w| w.odr8().clear_bit());
        } else if INDEX == 1 {
            gpioe.odr.modify(|_, w| w.odr10().set_bit());
            gpioe.odr.modify(|_, w| w.odr9().clear_bit());
        } else if INDEX == 2 {
            gpioe.odr.modify(|_, w| w.odr11().set_bit());
            gpioe.odr.modify(|_, w| w.odr10().clear_bit());
        } else if INDEX == 3 {
            gpioe.odr.modify(|_, w| w.odr12().set_bit());
            gpioe.odr.modify(|_, w| w.odr11().clear_bit());
        } else if INDEX == 4 {
            gpioe.odr.modify(|_, w| w.odr13().set_bit());
            gpioe.odr.modify(|_, w| w.odr12().clear_bit());
        } else if INDEX == 5 {
            gpioe.odr.modify(|_, w| w.odr14().set_bit());
            gpioe.odr.modify(|_, w| w.odr13().clear_bit());
        } else if INDEX == 6 {
            gpioe.odr.modify(|_, w| w.odr15().set_bit());
            gpioe.odr.modify(|_, w| w.odr14().clear_bit());
        } else if INDEX == 7 {
            gpioe.odr.modify(|_, w| w.odr8().set_bit());
            gpioe.odr.modify(|_, w| w.odr15().clear_bit());
        }
        INDEX = if INDEX == 7 { 0 } else { INDEX + 1 };
    }
}
```

The `get_xxx` function used in previous examples is dangerous, you can wrap them in a `cortex_m::interrupt::Mutex` to make it safer. But I suggest you use RTIC instead in the following examples.
