# Pistorm'X
This is a simplified board for the Pistorm where all the logic is integrated inside a single XC94144XL-10TQ100 5V compatible CPLD.

It has differences in the logic implementation to accommodate the slower CPLD and may present slight differences with the original Pistorm. It is not yet well tested and might not work with all Amiga revisions and software.

- This Pistorm'X is pre-alpha, tested only on my own A500 rev8a board. Use with caution it could burn your Pi, your Amiga, your house.
- This Pistorm'X is even cheaper than the Pistorm thanks to its single chip and 2-layer PCB.
- The Pistorm'X is easier to assemble manually : there is only one QFP package, the board is less crowded, and the friendly 2-layer PCB with thermal relief makes it less vulnerable to cold joints.
- Maybe this can be as powerful and feature rich as the Pistorm. So far I tested, with success, only basic confs and only the Musashi based emulator. Still it is not guaranteed that it will support all the features of the Pistorm.
- For now, it runs the same software on the Pi than the Pistorm. Except CPLD programming : do not burn Altera bitstream on Xilinx device or vice versa !
- Because everything is reprogrammable in the CPLD, it may do things not possible on the original hardware. Because of this future versions could require different Pi software.
- There are now two versions of the firmware : the simple one - and the one with write buffers that releases the pi bus a bit earlier during writes. Sysinfo show a tiny increase in CPU performance but not in chip ram access speed :(.

# Acknowledgements
The board and its firmware are inspired by the original Pistorm : https://github.com/captain-amygdala/pistorm. However both are really different.
It is not supported by the original creators, please don't bother them with issues you might have because of it.

# Disclaimer
This is a hobbyist project, it comes with no warranty and no support. Also remember that the Amiga machines are about 30 years old and may fail because of such hardware expansions.

I publish my work under the CC-BY-NC-SA license. You may build a board for you or your friend but not sell it commercially without its author's consent ; do not buy it on auction sites. You must keep the original author's name, source and licensing conditions even if you modify the product. When more tested and if Pistorm authors are OK, it may be contributed to their repository.

If you find it useful and want to reward my hard work : I am always looking for Amiga/Amstrad CPC hardware to repair and hack, or software licences for these. Please contact me.

# BOM
- 1x XC95144XL-10TQ100 CPLD
- 1x 3.3v LDO, either SPX3819M5-L-3-3 or XC6206P332MR
- 2x 1uF (or more) 0805 capacitors
- 6x 100nF 0805 capacitors
- 1x 10k 0805 resistor (optional?)
- 64x rounded socket pins. I use pins taken from a socket header.
- 1x 2x20 2.54mm female pin header.

# Making it
Components are SMD, and have thin pin pitch. You need to know what you are doing.

Check for shorts at least between 5V, 3.3V, and GND traces before applying power !

CPLD code is generated and built using Xilinx ISE 14.7 IDE. Use the following process properties : opt_mode=Speed; opt_level=High; optimize=Speed; slew=Slow; terminate=Keeper.


The "JTAG" programming port does not need to be soldered since the CPLD can be programmed from the Pi itself, or you can just maintain the connector in place during the few seconds required for programming.

To program it outside of the Amiga using the JTAG port, I use xsvfduino : https://github.com/wschutzer/xsvfduino. When it is already plugged to the motherboard, you must disconnect the 3.3v wire and turn on your system to power the board, otherwise your programmer will try to power the whole system, it will not work, and it might burn.

# Installation on the motherboard
Do NOT install the original CPU on top of the board inside the socket pins : leave it empty. I decided to use these because I previously used them for my IDE-RAM-A500 expansion, they fit well, and are cheaper, shorter and probably stronger than male rounded pins.

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
