# Pistorm'X
If you don't know about Pistorm, the MC68000 CPU replacement using a raspberry Pi, see here : https://github.com/captain-amygdala/pistorm

This Pistorm'X is a simplified CPU board, where all the logic is integrated inside a single XC94144XL-10TQ100 CPLD with 5V compatible IOs.

It has major differences in the logic implementation to accommodate the slower CPLD and may behave differently than the original Pistorm CPU board. A challenge has been to get rid of the 200MHz clock since the fastest Xilinx part in this series, the 5ns one, is rated for 178MHz max and is overpriced because of the chip shortage. Not using the PI_CLK makes the firmware really different from the original : a standard 10ns XC95144 can now deal with both the M68000 bus cycle synchronously to the 7MHz clock, and the asynchronous communication with the Pi that is just within the 10ns limit. 

The Pistorm'X logic is also provided for the original Pistorm CPU board. See the CPLD/Pistorm subdirectory to try it on your board.

Why you may consider building a Pistorm'X :
- This is even cheaper than the original board thanks to its single chip and 2-layer PCB.
- It is easier to assemble manually : there is only one QFP package, the board is less crowded, with 0805 caps, and the friendly 2-layer PCB with thermal relief makes it less vulnerable to cold joints.
- Maybe this will prove to be a suitable CPU board replacement. Your test contribution can help that.
- It runs with the same Pi software. Except CPLD programming : do not burn Altera bitstream on Xilinx device or vice versa !
- Because everything is reprogrammable in the CPLD, it may do things not possible on the original hardware :
  - Buffering write operations,
  - Installing it at the same time as the 68000 CPU : check the PistormX-68k folder for more info.

Why you should prefer the original CPU board :
- This Pistorm'X is alpha status. So far it is not guaranteed that it will work in your system or support all the features of the original.
- It is not an official board.
- It will probably not be compatible with future improvements or there will be delays to implement them.
- The actual CPLD pinout was chosen only to ease PCB routing and use a cheap 2-layers PCB. Future versions for different targets (A600, A2000...) will probably do the same and require a different CPLD pinout for each board, which means dedicated firmware files.
- The v0.1 board was routed with the actual Pistorm firmware in mind, so actually the 7MHz clock does not take advantage of a Global Clock pin of the CPLD : pinout may also change in next releases of this board.

# Experimental status
This board is experimental, not yet well tested, and might not work with all system revisions and Pi or 68k software or provide the same performance or feature than the original. That it works for me does not mean that it will work for you. For this reason you are welcome to assemble your own and share test reports in the discord channel named "beta-testing-pistormx". And for this same reason this board or derivatives must not be sold to end users : do not sell it and do not buy it yet.

- I am an end user, where can I buy it? Buy an original Pistorm CPU board.
- I am a builder, can I sell it? For now, please test it and report your test results.
- I am a maker, can I build derivatives? For now, please test it and report your test results.

Available firmwares:
- 8 states cycle : follow the complete 8 states 68k bus cycle described in MC68000 user manual.
- 6 states cycle : use a 6 states bus cycle by skipping s5 and s6 states. Similar to the original Pistorm firmware that skip s7 and s0 to increase chip access speed according to SysInfo.
- 6 states cycle write buffer : use CPLD registers as double buffer to releases the Pi bus earlier during write operations ; SysInfo show a tiny increase in CPU performance but not in chip ram access speed.
- 4 states cycle : use a 6 states bus cycle by skipping s0, s1, s5 and s6 states.
- 4 states cycle write buffer : use a 4 states bus cycle and a write buffer ; no real speed increase according to SysInfo, maybe useful in other apps.

Tested so far :
- inside my own Amiga 500 rev8a,
- buptest,
- Musashi based emulator with basic configuration and KS1.3, 3.1 and DiagROM, few demos and games from floppy,
- EMU68 with HDD install of KS3.1, RTG and WHDLoad games, demos.

Os runs stable for hours installing files from floppies or from SDbox. All the many glitches and errors that I found in games and demos (music not in sync, freeze) so far are similar when using the Pistorm'X or the Pistorm.

# Acknowledgements
The board and its firmware are inspired by the original Pistorm : https://github.com/captain-amygdala/pistorm.
I would like to thank Claude Schwarz for designing and open sourcing the Pistorm and for letting other projects like this one use the name and get inspired by the source code.
Thank you also to EDU_ARANA for letting me use his Pistorm logo with some modifications on the PCB silkscreen.
It is not supported by the Pistorm developers, please don't bother them with issues you might have with it.

# Disclaimer
This is a hobbyist project, it comes with no warranty and no support. Also remember that the Amiga machines are about 30 years old and may fail because of such hardware expansions. Use with caution it could burn your Pi, your Amiga, your house.

I publish my work under the CC-BY-NC-SA license. You may build a board for you or your friend but will not sell or buy it commercially because it is experimental. You must keep the original author's name, source repository (https://github.com/f1ac0/PistormX) and licensing conditions even if you modify the product.

If you find it useful and want to reward my hard work : I am always looking for Amiga/Amstrad CPC and such retro hardware to repair and hack, or software licenses for these. Other than that, give to charities and reduce your carbon footprint. 

# BOM
- 1x XC95144XL-10TQ100 CPLD
- 1x 3.3v LDO, either SPX3819M5-L-3-3 or XC6206P332MR or equivalent
- 2x 1uF (or more) 0805 capacitors in C1 and C2
- 6x 100nF 0805 capacitors
- (1x 10k 0805 resistor in R1, not required in my case)
- 64x rounded socket pins. I use pins taken from a socket header. You can omit pins 11,12,13,22,26,27 and 28.
- 1x 2x20 2.54mm female pin header.

# Making it
Components are SMD, and have thin pin pitch. You need to know what you are doing.

Check for shorts at least between 5V, 3.3V, and GND traces before applying power !

CPLD code is generated and built using Xilinx ISE 14.7 IDE. Use the following process properties : opt_mode=Speed; opt_level=High; optimize=Speed; slew=Slow; terminate=Keeper.

The "JTAG" programming port does not need to be soldered since the CPLD can be programmed from the Pi itself, or if you use a separate programmer you can just maintain the connector in place during the few seconds required for programming.

To program it outside of the Amiga using the JTAG port, I use xsvfduino : https://github.com/wschutzer/xsvfduino. When it is already plugged to the motherboard, you must disconnect the 3.3v wire and turn on your system to power the board, otherwise your programmer will try to power the whole system, it will not work, and it might burn.

# Installation on the motherboard
Do NOT install the original CPU on top of the board inside the socket pins : leave it empty. I decided to use these because I previously used them for my IDE-RAM-A500 expansion, they fit well, and are cheaper, shorter and probably stronger than male rounded pins.

Some features use the Pi GPIOs that are connected to the JTAG programming port. You can connect your wires there if you want. For example EMU68 logging should be on TCK (untested).

# Programming the CPLD from the Pi
Instead of using the JTAG port you can program the CPLD from the Pi when it is already installed and powered by the Amiga motherboard.

Long story : see https://linuxjedi.co.uk/2021/11/25/revisiting-xilinx-jtag-programming-from-a-raspberry-pi/amp/. Thank you LinuxJedi for this HowTo.

```
sudo apt install build-essential libusb-dev libftdi-dev libgpiod-dev git cmake
git clone https://github.com/matrix-io/xc3sprog
```
Before building, edit xc3sprog/sysfscreator.cpp and change :
```
IOSysFsGPIO(24, 26, 27, 25)
```
Build:
```
mkdir xc3sprog/build
cd xc3sprog/build
cmake .. -DUSE_WIRINGPI=OFF
make
```
Flash:
```
sudo xc3sprog -c sysfsgpio_creator -v -p 0 pistormx.jed
```

# Using it
See the official Pistorm documentation.

