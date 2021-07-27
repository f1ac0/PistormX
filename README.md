# Pistorm'X
This is a recreated board for the Pistorm using a 5V compatible Xilinx CPLD. This allows to integrate all the logic inside the single XC94144XL.

It is not yet tested and might not work. It might require 5ns CPLD and reducing the PI_CLK frequency inside the pi software.
Obviously, flashing the CPLD from within the pistorm software require some changes that are not yet documented. Sources to implement it might be RGBtoHDMI https://github.com/hoglet67/RGBtoHDMI and XC3SPROG https://github.com/matrix-io/xc3sprog

# Acknowledgements
The board is inspired from the official Pistorm RevB hardware and the firmware is adapted from the original one : https://github.com/captain-amygdala/pistorm
It is not supported by the original creators, please don't bother them with issues you might have because of it.

# Disclaimer
This is a hobbyist project, it comes with no warranty and no support. Also remember that the Amiga machines are about 30 years old and may fail because of such hardware expansions.

I publish my work under the CC-BY-NC-SA license.

If you find it useful and want to reward my hard work : I am always looking for Amiga/Amstrad CPC hardware to repair and hack, please contact me.

# BOM
- 1x XC95144XL CPLD
- 1x 3.3v LDO, either SPX3819M5-L-3-3 or XC6206P332MR
- 2x 1uF (or more) 0805 capacitors
- 6x 100nF 0805 capacitors
- 1x 10k 0805 resistor (optional?)
- 64x rounded socket pins, for CPU pass-through connection. I use pins taken from a socket header.
- 1x 2x20 2.54mm female pin header.

# Making it
Components are SMD, and have thin pin pitch. You need to know what you are doing.

Check for shorts at least between 5V, 3.3V, and GND traces before applying power !

The programming port does not need to be soldered since it needs to be programmed just once : you can just hold it in place during the few seconds required for programming.

CPLD code is generated and built into xsvf using Xilinx ISE 14.7 IDE then iMPACT.

There are several methods to program the XC95144XL. I personally use xsvfduino : https://github.com/wschutzer/xsvfduino. I advise you program it when unplugged from the motherboard, or by powering it from the motherboard ; otherwise your programmer might burn trying to power the whole system.

# Using it
See the official Pistorm documentation
